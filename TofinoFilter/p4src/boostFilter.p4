/*

*/

#include <tofino/intrinsic_metadata.p4>
#include <tofino/constants.p4>

#define BOOST_INFLIGHT 0x2121
#define BOOST_FROMFPGA 0x4242

#define BOOST_TOFPGA 0x8484
#define UNBOOST_TOFPGA 0xA5A5

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
  }
}


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
  monitoringPipeline();

  // Make forwarding decision so booster logic can use it. 
  forwardingPipeline();

  // If packet is directly from booster, forward and do post-processing.
  // FORWARD --> POSTPROC.
  if (ethernet.etherType == BOOST_FROMFPGA){
    postProcessingPipeline();
  }
  else {
    // if packet was boosted at some prior point in the path, this is the sink. 
    // FORWARD -> UNBOOST.
    if (ethernet.etherType == BOOST_INFLIGHT){
      unboostPipeline();
    }
    // If it's unboosted, make forwarding decision then attempt to boost. 
    // FORWARD -> ADMISSION --> BOOST.
    else {
      admissionControlPipeline();
      if (boost_md.boostFlag == 1){
        boostPipeline();
      }
    }
  }
}

// -------------------------- Monitoring logic -----------------
control setSwitchIdPipeline {
  apply(setSwitchIdTable);
}
table setSwitchIdTable {
    reads   { ig_intr_md.ingress_port : exact; }
    actions {setSwitchId; }
}
action setSwitchId(switchId, boostPort) {
  modify_field(slice_md.switchId, switchId);
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
    actions { set_egr; nop; }
    size : 288;
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
      ig_intr_md.ingress_port : exact; 
    }
    actions { set_egr; nop; }
    size : 288;
}
// Set egress port for an ingress port. 
action set_egr(egress_spec) {
    modify_field(ig_intr_md_for_tm.ucast_egress_port, egress_spec);
}
action nop() {}

// -------------------------------------------------------------


// ------------------ boosting post-proc logic -----------------
control postProcessingPipeline {
  apply(postProcTable);
}
table postProcTable {
  actions {setBoostHeader_BOOST_INFLIGHT; }
  size : 288;
}
action setBoostHeader_BOOST_INFLIGHT() {
  modify_field(ethernet.etherType, BOOST_INFLIGHT);
}

// -------------------------------------------------------------

// ------------------ admission control logic -----------------
control admissionControlPipeline {
  // apply(boostPolicyTable); // Check if this class of traffic is allowed. 
  apply(boostEndpointTable); // Check if boosting to this endpoint is enabled. 
}
// coarse grained system table to turn on or off boosting circuits.
table boostEndpointTable {
  reads { 
    ethernet.dstAddr : exact;
  }
  actions {
    setBoostFlag;
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
  apply(boostPreprocTable);
}
table boostPreprocTable {
  actions {setBoostHeader_BOOST_TOFPGA; }
  size : 288;
}
action setBoostHeader_BOOST_TOFPGA() {
  modify_field(ethernet.etherType, BOOST_TOFPGA);
  modify_field(ig_intr_md_for_tm.ucast_egress_port, slice_md.boostPort);
}
// -------------------------------------------------------------


// ------------------ unboosting pre-proc logic ---------------
control unboostPipeline {
  apply(unboostPreprocTable);
}
table unboostPreprocTable {
  actions {setBoostHeader_UNBOOST_TOFPGA; }
  size : 288;
}
action setBoostHeader_UNBOOST_TOFPGA() {
  modify_field(ethernet.etherType, UNBOOST_TOFPGA);
}
// -------------------------------------------------------------
