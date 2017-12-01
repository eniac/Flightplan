/*

*/

#include <tofino/intrinsic_metadata.p4>
#include <tofino/constants.p4>
#include <tofino/stateful_alu_blackbox.p4>

#define BOOST_INFLIGHT 0x1
#define BOOST_FROMFPGA 0x2
#define BOOST_TOFPGA 0x3
#define UNBOOST_FROMFPGA 0x4
#define UNBOOST_TOFPGA 0x5

#define BOOST_ETYPE 0x4242

header_type ethernet_t {
  fields {
    dstAddr : 48;
    srcAddr : 48;
    etherType : 16;
  }
}
header ethernet_t ethernet;

parser start {
  return parse_ethernet;
}

parser parse_ethernet {
  extract(ethernet);
  return select(latest.etherType) {
    BOOST_ETYPE: parse_boost;
    default: ingress;
  }
}

parser parse_boost {
  extract(boost_header);
  return ingress;
}

// Header for source booster with FEC. Not used yet.
// header_type boost_header_t {
//   fields {
//     groupId : 8; // to booster.
//     packetId : 8; // to booster.
//     // outPort : 8; // from booster. Can booster select output port?
//   }
// }

header_type slice_md_t {
  fields {
    switchId : 8; // Id of the virtual switch.
    boostPort : 9; // Local booster. 
    mcastId : 16;
  }
}

header_type boost_header_t {
  fields {
    boostStatus : 8;
    originalEtherType : 16;
  }
}
header boost_header_t boost_header;

header_type boost_md_t {
  fields {
    boostFlag : 1; // Boosting enabled?
  }
}

// header boost_header_t boost_header;
metadata slice_md_t slice_md;
metadata boost_md_t boost_md;

control ingress {
  // Select switch based on port. 
  // Only used in forwarding pipeline. 
  setSwitchIdPipeline();
  // Only boosting switches for now.
  boostingIngress();
}

// Ingress for a switch with booster attached. 
control boostingIngress {
  // monitoringPipeline();

  // Make forwarding decision so booster logic can use it. 
  forwardingPipeline();

  // if this is a boosted packet. 
  if (valid(boost_header)){
    // if the packet has just been boosted, do post-processing.
    if (boost_header.boostStatus == BOOST_FROMFPGA){
      boostPostProcPipeline();
    }
    // if it's just been unboosted, also do post-processing.
    else {
      if (boost_header.boostStatus == UNBOOST_FROMFPGA){
        unboostPostProcPipeline();
      }
      else {
        // if not just boosted and not just unboosted, check unboost policy
        // (todo, just unboost for now)
        unboostPipeline();
      }
    }
  }
  // if its not a boosted packet, attempt to boost. 
  else {
    admissionControlPipeline();
    // add boost header. 
    if (boost_md.boostFlag == 1){
      boostPipeline();
    }
  }
}


  // // Debug. Count packets arriving at switch ID 2.
  // if (slice_md.switchId == 2){
  //   apply(countPacketTable);
  // }




// -------------------------- switch id logic -----------------
control setSwitchIdPipeline {
  apply(setSwitchIdTable);
}
table setSwitchIdTable {
    reads   { ig_intr_md.ingress_port : exact; }
    actions {setSwitchId; }
}
action setSwitchId(switchId, boostPort) {
  modify_field(slice_md.switchId, switchId);
  modify_field(slice_md.mcastId, switchId);
  modify_field(slice_md.boostPort, boostPort);
}
// -------------------------------------------------------------

// -------------------------- Monitoring logic -----------------
control monitoringPipeline {
  if (ig_intr_md_from_parser_aux.ingress_parser_err == 0x1000){
    apply(invalidFCS_table);
  }
}

table invalidFCS_table {
    reads   { ig_intr_md.ingress_port : exact; }
    actions { nop; }
    size : 32;
}
// -------------------------------------------------------------

// -------------------------- Forwarding logic -----------------
control forwardingPipeline {
  apply(forwardingTable);

}
// Modified for slicing. Add rules for each switch ID. 
table forwardingTable {
    reads   { 
      slice_md.switchId : exact;
      ethernet.dstAddr : exact;
      // ig_intr_md.ingress_port : exact; 
    }
    actions { unicast; nop; broadcast;}
    size : 32;
}
// Set egress port based on dmac
action unicast(egress_spec) {
    modify_field(ig_intr_md_for_tm.ucast_egress_port, egress_spec);
}

// flood to group based on ingress port number. 
action broadcast() {
    modify_field(ig_intr_md_for_tm.mcast_grp_a, ig_intr_md.ingress_port);  
}

action nop() {}

// Need 1 multicast group per input port for flooding --> this must be done _after_ post processing?
// // miss --> flood to the multicast group associated with this vswitch. 
// action l2_miss(){
//     modify_field(ig_intr_md_for_tm.mcast_grp_a, slice_md.mcastId);  
// }


// -------------------------------------------------------------



// ------------------ admission control logic -----------------
control admissionControlPipeline {
  // apply(boostPolicyTable); // Check if this class of traffic is allowed. 
  apply(admissionControlTable); // Check if boosting to this endpoint is enabled. 
}
// coarse grained system table to turn on or off boosting circuits.
table admissionControlTable {
  reads { 
    ethernet.srcAddr : exact;
    ethernet.dstAddr : exact;
  }
  actions {
    setBoostFlag; nop;
  }
}
// Todo: this should look in a register. 
// Circuits should be highly dynamic? 
action setBoostFlag() {
  modify_field(boost_md.boostFlag, 1);
}
// -------------------------------------------------------------

// ------------------ boosting pre-proc logic -----------------
control boostPipeline {
  // Add boost header.
  apply(addBoostHeaderTable);
  // Set boost header. 
  apply(boostPreprocTable);
}
table addBoostHeaderTable {
  actions {addBoostHeader;}
  size : 1;
}
action addBoostHeader() {
  add_header(boost_header);
}

table boostPreprocTable {
  actions {setBoostHeader_BOOST_TOFPGA;}
  size : 32;
}
action setBoostHeader_BOOST_TOFPGA() {
  modify_field(boost_header.originalEtherType, ethernet.etherType);
  modify_field(ethernet.etherType, BOOST_ETYPE);
  modify_field(boost_header.boostStatus, BOOST_FROMFPGA);
  modify_field(ig_intr_md_for_tm.ucast_egress_port, slice_md.boostPort);
}
// -------------------------------------------------------------

// ------------------ boosting post-proc logic -----------------
control boostPostProcPipeline {
  apply(boostPostProcTable);
}
table boostPostProcTable {
  actions {setBoostHeader_BOOST_INFLIGHT; }
  size : 32;
}
action setBoostHeader_BOOST_INFLIGHT() {
  modify_field(boost_header.boostStatus, BOOST_INFLIGHT);
}

// -------------------------------------------------------------




// ------------------ unboosting pre-proc logic ---------------
control unboostPipeline {
  apply(unboostPreprocTable);
}
table unboostPreprocTable {
  actions {setBoostHeader_UNBOOST_TOFPGA; }
  size : 32;
}
action setBoostHeader_UNBOOST_TOFPGA() {
  modify_field(boost_header.boostStatus, UNBOOST_FROMFPGA);
  modify_field(ig_intr_md_for_tm.ucast_egress_port, slice_md.boostPort);
}
// -------------------------------------------------------------

// ------------------ unboosting post-proc logic ---------------
control unboostPostProcPipeline {
  // correct ethernet header.
  apply(unboostPostProcTable);
  // remove boosting header.
  apply(removeBoostHeaderTable);
}
table unboostPostProcTable {
  actions {correctEthHdr; }
  size : 32;
}
action correctEthHdr(){
  modify_field(ethernet.etherType, boost_header.originalEtherType);
}
table removeBoostHeaderTable {
  actions {removeBoostHeader; }
  size : 32;
}
action removeBoostHeader(){
  remove_header(boost_header);
}


// -------------------------------------------------------------

// debugging ---------------------------------------------------
register counterReg {
    width : 32;
    instance_count : 256;
}
blackbox stateful_alu inc_counter{
    reg : counterReg;
    update_lo_1_value : register_lo + 1;
}
action countPacket(){
    inc_counter.execute_stateful_alu(slice_md.switchId);
}
table countPacketTable {
  actions {countPacket;}
  size : 1;
}
// -------------------------------------------------------------
