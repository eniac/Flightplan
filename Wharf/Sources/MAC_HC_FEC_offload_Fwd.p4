#ifndef MAC_FEC_ENC_OFFLOAD_FWD_P4_
#define MAC_FEC_ENC_OFFLOAD_FWD_P4_

#include "targets.h"
#include "Parsing.p4"
#include "FEC.p4"
#include "FEC_Classify.p4"

//struct bmv2_meta_t {}

parser BMParser(packet_in pkt, out headers_t hdr,
                inout booster_metadata_t m, inout metadata_t meta) {
    state start {
        FecParser.apply(pkt, hdr);
        transition accept;
    }
}

control MAC_FEC_Forwarder(inout headers_t hdr, inout booster_metadata_t m, inout metadata_t meta) {
    bit<4> next_dataplane = 0;
    bit<48> dst_mac = 0;

    action set_egress(bit<9> port) {
        SET_EGRESS(meta, port);
    }

    action do_drop() {
        drop();
    }

    action strip_fp_hdr(bit<9> port) {
         hdr.fp.setInvalid();
         SET_EGRESS (meta, port);
    }

    table fec_forward {
        key = {
           next_dataplane : exact;
       }
       actions = {set_egress; do_drop; }
       default_action = do_drop;
    }

    table MAC_fwd_dst {
        key = {
            dst_mac : exact;
        }
        actions = { strip_fp_hdr ; NoAction; }
        default_action = NoAction;
    }

    table MAC_fwd_host {
        key = {
            dst_mac : exact;
        }
        actions = { strip_fp_hdr ; NoAction; }
        default_action = NoAction;
    }

    action set_fwd_seg(bit<9> port){
        hdr.fp.to_segment = 2;
        SET_EGRESS (meta, port);
    }

    action set_seg(bit<9> port){
        hdr.fp.to_segment = 1;
        SET_EGRESS (meta, port);
    }

    table forward_segment {
        key = {
            hdr.eth.dst : exact;
        }
        actions = {set_fwd_seg; set_seg; }
    }

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
            return;
        }

        if (!hdr.fp.isValid()){
            hdr.fp.setValid();
            hdr.fp.src = hdr.eth.src;
            hdr.fp.dst = hdr.eth.dst;
            hdr.fp.type = ETHERTYPE_FLIGHTPLAN;

            forward_segment.apply();
        }


       if(hdr.fp.isValid()){

          if(hdr.fp.to_segment != 1 ) {
              if(hdr.fp.to_segment == 5 ){
             //  hdr.fp.setInvalid();
                 dst_mac = hdr.eth.dst;
                 MAC_fwd_dst.apply();
              } else {
                 next_dataplane = hdr.fp.to_segment;
                 fec_forward.apply();
              }

//          return;

        } else {

                 dst_mac = hdr.eth.dst;
                 MAC_fwd_host.apply();
        }

//       return;

     }
      //return;

#if defined (FEC_BOOSTER)
        // If we received an FEC update, then update the table.
        bit<1> is_ctrl;
        FECController.apply(hdr, meta, is_ctrl);
        if (is_ctrl == 1) {
            drop();
            return;
        }
#endif

    }
}


V1Switch(BMParser(), NoVerify(), MAC_FEC_Forwarder(), NoEgress(), NoCheck(), FecDeparser()) main;

#endif // MAC_FEC_ENC_OFFLOAD_FWD_P4_
