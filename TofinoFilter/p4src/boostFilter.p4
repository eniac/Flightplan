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

#define STOP_BOOSTING 0x4242

#define BOOST_ETYPE 0x4444


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
    fecPacketGid : 8;
    fecPacketId : 8;
    // fecChunkId : 8;
    originalEtherDst : 48;
    originalEtherSrc : 48;
    originalEtherType : 16;
  }
}
header boost_header_t boost_header;

header_type boost_md_t {
  fields {
    monitoringActive : 1;
    boostStopped : 1;
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

  if (ethernet.etherType == STOP_BOOSTING){
    apply(stopBoostingTable);
  }
  else{
    apply(checkBoostingTable);
    // Only boosting switches for now.
    boostingIngress();
  }
}

// Ingress for a switch with booster attached. 
control boostingIngress {
  if (boost_md.monitoringActive == 1){
    monitoringPipeline();
  }

  // Make forwarding decision so booster logic can use it. 
  forwardingPipeline();

  // if boosting is not stopped.
  if (boost_md.boostStopped == 0) {
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
}


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
// -------------------------------------------------------------



// ----------------- Boosting monitoring logic -----------------
control monitoringPipeline {
  if (ig_intr_md_from_parser_aux.ingress_parser_err == 0x1000){
    apply(invalidFCSCountTable);
  }
}

table invalidFCSCountTable {
    actions {countPortErrors; }
    size : 32;
}
action countPortErrors(){
  fcsErrorReg_alu.execute_stateful_alu(ig_intr_md.ingress_port);
}

action estimateFlowErrors(){
  // count min sketch over IP 5-tuples.
}

register fcsErrorReg {
    width : 32;
    instance_count : 4096;
}
blackbox stateful_alu fcsErrorReg_alu{
    reg : fcsErrorReg;
    condition_lo : ig_intr_md_from_parser_aux.ingress_parser_err == 0x1000;
    update_lo_1_predicate: condition_lo;
    update_lo_1_value: register_lo + 1;
}
// -------------------------------------------------------------



// -------------------------- Boosting Actuation logic ---------

table startBoostingTable {
  actions { startBoosting; }
}
action startBoosting(){
  enableBoost_alu.execute_stateful_alu(0);
  modify_field(boost_md.boostStopped, 0);
}


table stopBoostingTable {
  actions { stopBoosting; }
}
action stopBoosting(){
  disableBoost_alu.execute_stateful_alu(0);
  modify_field(boost_md.boostStopped, 1);
}

table checkBoostingTable {
  actions { checkBoosting; }
}
action checkBoosting(){
  checkBoost_alu.execute_stateful_alu(0);
}

register boostStatus_reg {
    width : 8;
    instance_count : 1;
}
blackbox stateful_alu enableBoost_alu{
    reg : boostStatus_reg;
    update_lo_1_value : 0;
}
blackbox stateful_alu disableBoost_alu{
    reg : boostStatus_reg;
    update_lo_1_value : 1;
}
blackbox stateful_alu checkBoost_alu {
    reg : boostStatus_reg;  
    output_value: register_lo;
    output_dst: boost_md.boostStopped;
}
// -------------------------------------------------------------



// ------------------ boosting admission control logic -----------------
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
  // counting. 
  apply(incPidTable);
  if (boost_header.fecPacketId == 0){
    apply(incGidTable);
  }
  else{
    apply(loadGidTable);
  }
}
table addBoostHeaderTable {
  actions {addBoostHeader;}
  size : 1;
}
action addBoostHeader() {
  add_header(boost_header);
}

action setBoostHeader_BOOST_TOFPGA() {
  modify_field(boost_header.originalEtherDst, ethernet.dstAddr);
  modify_field(boost_header.originalEtherSrc, ethernet.srcAddr);
  modify_field(boost_header.originalEtherType, ethernet.etherType);
  modify_field(ethernet.etherType, BOOST_ETYPE);
  modify_field(boost_header.boostStatus, BOOST_FROMFPGA);
  modify_field(ig_intr_md_for_tm.ucast_egress_port, slice_md.boostPort);
}

action incPid(){
    fecPacketId_alu.execute_stateful_alu(0);
}

action incGid(){
    gidReg_alu.execute_stateful_alu(0);
    modify_field(ig_intr_md_for_tm.mcast_grp_a, slice_md.boostPort);      
}

action loadGid(){
  gitReg_loadAlu.execute_stateful_alu(0);
}



table boostPreprocTable {
  actions {setBoostHeader_BOOST_TOFPGA;}
  size : 32;
}


register gidReg {
    width : 8;
    instance_count : 1;
}
blackbox stateful_alu gidReg_alu{
    reg : gidReg;
    update_lo_1_value : register_lo + 1;
    output_value: register_lo;
    output_dst: boost_header.fecPacketGid;
}


table incGidTable {
  actions {incGid;}
  size : 1;
}

blackbox stateful_alu gitReg_loadAlu{
    reg : gidReg;
    output_value: register_lo;
    output_dst: boost_header.fecPacketGid;
}

table loadGidTable {
  actions {loadGid;}
  size : 1;
}



register fecPacketId {
    width : 8;
    instance_count : 1;
}
blackbox stateful_alu fecPacketId_alu{
    reg : fecPacketId;
    condition_lo : register_lo > 3;
    update_lo_1_predicate: condition_lo;
    update_lo_1_value: 0; 
    update_lo_2_predicate: not condition_lo;
    update_lo_2_value: register_lo + 1;

    output_value: register_lo;
    output_dst: boost_header.fecPacketId;
}

table incPidTable {
  actions {incPid;}
  size : 1;
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

action correctEthHdr(){
  modify_field(ethernet.etherType, boost_header.originalEtherType);
}

action removeBoostHeader(){
  remove_header(boost_header);
}

table unboostPostProcTable {
  actions {correctEthHdr; }
  size : 32;
}
table removeBoostHeaderTable {
  actions {removeBoostHeader; }
  size : 32;
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
