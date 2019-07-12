#ifndef MAC_HC_FWD_P4_
#define MAC_HC_FWD_P4_

#include "targets.h"
#include "Compression.p4"
#include "EmptyBMDefinitions.p4"
#include "Forwarding.p4"
#include "FEC.p4"
#include "FEC_Classify.p4"

parser BMParser(packet_in pkt, out headers_t hdr,
                inout booster_metadata_t m, inout metadata_t meta) {
    state start {
        FecParser.apply(pkt, hdr);
        transition accept;
    }
}

control MAC_Forwarder(inout headers_t hdr, inout booster_metadata_t m, inout metadata_t meta) {

        bit<4> next_dataplane = 0;
        bit<1> compressed_link = 0;
        bit<1> forward = 0;

    action set_fp_egress(bit<9> port) {
        SET_EGRESS(meta, port);
    }
   
    table flightplan_forward { 
        key = {
            next_dataplane : exact;
       }
       actions = {set_fp_egress; NoAction; }
       default_action = NoAction;
    }
    
#if defined(COMPRESSION_BOOSTER)
    CompressedLink() ingress_compression;
    CompressedLink() egress_compression;
#endif

#if defined(FEC_BOOSTER)
    bit<FEC_K_WIDTH> k = 0;
    bit<FEC_H_WIDTH> h = 0;
    bit<24> proto_and_port = 0;
    FEC_Classify() classification;
    FecClassParams() decoder_params;
    FecClassParams() encoder_params;
#endif

    apply {
        if (!hdr.eth.isValid()) {
            drop();
        }

        if(hdr.fp.isValid()){
              hdr.fp.to_segment = 1 + hdr.fp.to_segment;
              next_dataplane = hdr.fp.to_segment;
              flightplan_forward.apply();
        }
        else {
           drop();
        }


#if defined(FEC_BOOSTER)
         // If lossy link, then FEC decode.
         if (hdr.fec.isValid()) {
             decoder_params.apply(hdr.fec.traffic_class, k, h);
             hdr.eth.type = hdr.fec.orig_ethertype;
             hdr.fp.setInvalid();
             FEC_DECODE(hdr.fec, k, h);
             hdr.fp.setValid();
             hdr.fp.type = ETHERTYPE_FLIGHTPLAN;
             hdr.fp.to_segment = 4;
             if (hdr.fec.packet_index >= k) {
                 drop();
                 return;
             }
             hdr.fec.setInvalid();
             return;
         }
#endif

#if defined(COMPRESSION_BOOSTER)
        // If multiplexed link, then header decompress.
        ingress_compression.apply(meta.ingress_port, compressed_link);
        if (compressed_link == 1) {
            hdr.fp.setInvalid();
            header_decompress(forward);
            if (forward == 0) {
                drop();
                return;
            }
//            hdr.eth.type = ETHERTYPE_WHARF;
            hdr.fp.setValid();
            hdr.fp.type = ETHERTYPE_FLIGHTPLAN;
            hdr.fp.to_segment = 4;
        }
#endif

#if defined(COMPRESSION_BOOSTER)
        compressed_link = 0;
        // If heading out on a multiplexed link, then header compress.

        egress_compression.apply(meta.egress_spec, compressed_link);
        if (compressed_link == 1) {
            hdr.fp.setInvalid();
            header_compress(forward);
            if (forward == 0) {
                drop();
                return;
            }
//            hdr.eth.type = ETHERTYPE_WHARF;
            hdr.fp.setValid();
            hdr.fp.type = ETHERTYPE_FLIGHTPLAN;
            hdr.fp.to_segment = 3;
        }
#endif


#if defined(FEC_BOOSTER)
         bit<1> faulty = 1;

         // If heading out on a lossy link, then FEC encode.
         //get_port_status(meta.egress_spec, faulty);
         //if (faulty == 1) {
             if (hdr.tcp.isValid()) {
                 proto_and_port = hdr.ipv4.proto ++ hdr.tcp.dport;
             } else if (hdr.udp.isValid()) {
                 proto_and_port = hdr.ipv4.proto ++ hdr.udp.dport;
             } else {
                 proto_and_port = hdr.ipv4.proto ++ (bit<16>)0;
             }

             classification.apply(hdr, proto_and_port);
             if (hdr.fec.isValid()) {
                 encoder_params.apply(hdr.fec.traffic_class, k, h);
                 update_fec_state(hdr.fec.traffic_class, k, h,
                                  hdr.fec.block_index, hdr.fec.packet_index    );
                 hdr.fec.orig_ethertype = hdr.eth.type;
                 hdr.fp.setInvalid();
                 FEC_ENCODE(hdr.fec, k, h);
                 hdr.eth.type = ETHERTYPE_WHARF;
                 hdr.fp.setValid();
                 hdr.fp.type = ETHERTYPE_FLIGHTPLAN;
                 hdr.fp.to_segment = 5;
             }
        // }
 #endif


   }
}


V1Switch(BMParser(), NoVerify(), MAC_Forwarder(), NoEgress(), NoCheck(), FecDeparser()) main;

#endif // MAC_HC_FWD_P4_
