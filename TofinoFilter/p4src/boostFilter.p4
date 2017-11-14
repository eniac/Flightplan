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

// Set egress port for an ingress port. 
action set_egr(egress_spec) {
    modify_field(ig_intr_md_for_tm.ucast_egress_port, egress_spec);
}

action nop() {
}


table boostTable {
  reads   { ig_intr_md.ingress_port : exact; }
  actions { set_egr; nop;}
  size : 288;
}


table forwardTable {
    reads { ethernet.dstAddr : exact; }
    actions { set_egr; nop; }
    size : 288;
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

// Ingress that handles optional boosting. 
control ingress {
  boostingIngress();
}

control forwardPipeline {
  // regular forwarding. L2, whatever.
  apply(forwardTable);
}

// check if boosting applies to packet. 
control checkBoostPolicy {
  // check fine grained policy.
  apply(boostPolicyTable);

  // check if circuit is enabled. 
  apply(boostCircuitTable);
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




control doBoosting {
    // get packet ct. 
    apply (getPacketId);
    // get batch number.
    apply (getBatchId);
    // tag packet, add header.
    // set egress port to booster. 
}

control boostingIngress {
  // if boosted before it got here, forward normally. 
  if (ethernet.etherType == IN_BOOSTCIRCUIT){
    // todo: check if this is the termination of a boosting circuit.
    forwardPipeline();
  }
  // if ethertype == from_booster, forward normally. 
  else {
    if (ethernet.etherType == ENTER_BOOSTCIRCUIT){
      // todo: let booster select output port? 
      forwardPipeline();
    }
    // if its not pre boosted, and not from the booster, attempt to boost. 
    else {
      // Check the policy for boosting to determine if the flow should get boosted.
      checkBoostPolicy();
      if (boost_md.boostFlowFlag == 1){
        if (boost_md.boostCircuitFlag == 1){
          doBoosting();
          // don't call forward here -- packet will go to booster, return, then be forwarded.
        } else { forwardPipeline();}
      } else { forwardPipeline();}
    }
  }
}