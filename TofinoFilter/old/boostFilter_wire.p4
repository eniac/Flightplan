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


// Booster port: 144
// Traffic ports: 128, 136

#define BOOSTPORT 144
control ingress {
  // if packet is from booster port, forward normally. 
  if (ig_intr_md.ingress_port == BOOSTPORT){
    apply(forwardTable);    
  }
  // else, send to booster.
  else{
    apply(boostTable);    
  }

}