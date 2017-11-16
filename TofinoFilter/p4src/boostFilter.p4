/*
Copyright 2013-present Barefoot Networks, Inc. 

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

#include <tofino/intrinsic_metadata.p4>
#include <tofino/constants.p4>

#define IN_BOOSTCIRCUIT 0x2121
#define ENTER_BOOSTCIRCUIT 0x4242

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

parser_exception p4_pe_checksum {
  return ingress;
}

// Header for to booster. 
header_type boost_header_t {
  fields {
    groupId : 8; // to booster.
    packetId : 8; // to booster.
    // outPort : 8; // from booster. Can booster select output port?
  }
}

header_type boost_scratch_t {
  fields {
    boostFlowFlag : 1; // Route this flow through booster?
    boostCircuitFlag : 1; // Route this circuit through booster?
    boostCircuitId : 8; // ID of this boosting circuit.
  }
}

header boost_header_t boost_header;
metadata boost_scratch_t boost_md;

// Common actions. 
// Set egress port for an ingress port. 
action set_egr(egress_spec) {
    modify_field(ig_intr_md_for_tm.ucast_egress_port, egress_spec);
}
action nop() {}


// Main ingress that handles optional boosting. 
control ingress {
  boostingIngress();
}



// --------- Forwarding pipeline. ------------
control forwardPipeline {
  apply(forwardTable);
}
table forwardTable {
    reads   { ig_intr_md.ingress_port : exact; }
    actions { set_egr; nop; }
    size : 288;
}

// --------- Boost policy pipeline. ------------

// check if boosting applies to packet. 
control checkBoostPolicy {
  // check fine grained policy.
  apply(boostPolicyTable);

  // check if circuit is enabled. 
  apply(boostCircuitTable);
}

// fine grained policy table to select the flows to boost.
table boostPolicyTable {
  reads { 
    ethernet.srcAddr : exact; 
    ethernet.dstAddr : exact;
  }
  actions {
    nop; setBoostFlowFlag;
  }
}

action setBoostFlowFlag(){
  modify_field(boost_md.boostFlowFlag, 1);
}

// coarse grained system table to turn on or off boosting circuits.
table boostCircuitTable {
  reads { 
    ethernet.dstAddr : exact;
  }
  actions {
    setBoostCircuitFlag;
  }
}
// Todo: this should look in a register. 
// Circuits should be highly dynamic? 
action setBoostCircuitFlag() {
  modify_field(boost_md.boostCircuitFlag, 1);
}

// --------- Boost preprocessing pipeline. ------------

control doBoosting {
    // get packet ct. 
    apply (getPacketId);
    // get batch number.
    apply (getBatchId);
    // tag packet, add header.
    // set egress port to booster. 
}

table getPacketId {
  actions {
    updatePacketId;
  }
}

action updatePacketId(){
  nop();
}

table getBatchId { 
  actions {
    updateBatchId;
  }
}

action updateBatchId(){
  nop();
}


table invalidFCS_table {
    reads   { ig_intr_md.ingress_port : exact; }
    actions { set_egr; nop; }
    size : 288;
}

control boostingIngress {
  if (ig_intr_md_from_parser_aux.ingress_parser_err == 0x1000){
    apply(invalidFCS_table);
  }
  // If packet is in a boosted circuit, forward without modification.
  if (ethernet.etherType == IN_BOOSTCIRCUIT){
    // todo: check if this is the termination of a boosting circuit.
    forwardPipeline();
  }
  // If packet is entering a boosted circuit, forward without modification. 
  else {
    if (ethernet.etherType == ENTER_BOOSTCIRCUIT){
      // todo: let booster select output port? 
      forwardPipeline();
    }
    // If packet is not in, or entering, a boosted circuit, check if it should be boosted. 
    else {
      // Check the policy for boosting to determine if the flow should get boosted.
      checkBoostPolicy();
      // If the flow should get boosted, and the destination is on a boosted circuit, do the boosting.
      if (boost_md.boostFlowFlag == 1){
        if (boost_md.boostCircuitFlag == 1){
          doBoosting();
      // Otherwise, if the policy check fails (either flow or circuit), do not boost. Just forward.
        } else { forwardPipeline();}
      } else { forwardPipeline();}
    }
  }
}