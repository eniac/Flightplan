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

/*************************************/
/* Target-specific Header for Tofino */
/*************************************/

/*field_type egress_spec_t {
    eg_ucast_port : 9 // unicast port id
    eg_queue : 6; // cos (priority group)
    eg_mcast_group1 : 16; // multicast group id1 (key for the mcast replication table)
    eg_mcast_group2 : 16; // multicast group id2 (key for the mcast replication table)
    copy_to_cpu : 1; // flag
    cos_for_copy_to_cpu : 3; 
}*/ /* obsolete */

/* It's unclear whether we should model this in P4.
field_type clone_spec_t {
    ingress_mirror_id : 10;
    egress_mirror_id : 10;
    truncation_len : 14;
}
*/

header_type intrinsic_metadata_t {
    fields {
        /* Mandatory */
        ingress_port : 9; // read only. ingress physical port id. must be presented to BM 
        packet_length : 16; // read only
        //egress_spec : sizeof(egress_spec_t) // must be presented to BM // obsolete
        eg_ucast_port : 32; // unicast port id
        eg_queue : 6; // cos (priority group)
        eg_mcast_group1 : 16; // multicast group id1 (key for the mcast replication table)
        eg_mcast_group2 : 16; // multicast group id2 (key for the mcast replication table)
        copy_to_cpu : 1; // flag
        cos_for_copy_to_cpu : 3; 
        egress_port : 32; // egress physical port id. available only in the egress pipe, and must be presented to the egress deparser
        egress_instance : 16; // read only. instance id of a replicated packet. available only in the egress pipe
        instance_type : 2; // read only. original, ingress cloned, egress cloned, or recirculated
        parser_status : 8; // read only
        parser_error_location : 8; // read only
        
        /* Tofino-specifics */
        global_version_num : 32; // read only
        ingress_global_timestamp : 48; // read only. time snapshot taken by the ingress parser
        egress_global_timestamp : 48; // read only. time snapshot taken by the egress parser. available only in the egress pipe
        ingress_mac_timestamp : 48; // read only. arrival time at ingress MAC (for 1588)
        // The following hash values are deliberately made separte from egress_spec because the ingress pipe will need 
        // to explicitly populate the values in these fields at the flow level on a per-packet basis.
        // Note anything that needs per-packet update can't be handled via an argument to an action.
        mcast_hash1 : 13; // must be presented to BM
        mcast_hash2 : 13; // must be presented to BM
        deflect_on_drop : 1; // must be presented to BM
        meter1 : 3; // must be presented to BM
        meter2 : 3; // must be presented to BM
        enq_qdepth : 19; // read only. q depth at the packet enqueue time. available only in the egress.
        enq_congest_stat : 2; // read only. q congestion status at the packet enqueue time. available only in the egress.
        enq_timestamp : 32; // read only. time snapshot taken when the packet is enqueued. available only in the egress.
        deq_qdepth : 19; // read only. q depth at the packet dequeue time. available only in the egress.
        deq_congest_stat : 2; // read only. q congestion status at the packet dequeue time. available only in the egress.
        deq_timedelta : 32; // read only. time delta between the packet's enqueue and dequeue time. available only in the egress.
        //clone_spec : sizeof(clone_spec_t);
    }
}

metadata intrinsic_metadata_t intrinsic_metadata;

#define EGSPEC_UCAST_CPU_PORT 0xFF00000000
#define EGSPEC_NULL_PORT 0x0000000000
