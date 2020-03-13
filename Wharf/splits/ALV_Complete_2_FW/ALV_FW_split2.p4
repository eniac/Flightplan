/*
Split of ALV_Complete.p4
Nik Sultana, UPenn, March 2020
*/

#if !defined(TARGET_BMV2)
#error Currently unsupported target
#endif

#include "targets.h"
#include "EmptyBMDefinitions.p4"
#include "Memcached_extern.p4"
#include "FEC.p4"
#include "FEC_Classify.p4"
#include "Compression.p4"

#define WIDTH_PORT_NUMBER 9

control ALV_Route(inout headers_t hdr, inout booster_metadata_t m, inout metadata_t meta) {
    action mac_forward_set_egress(bit<WIDTH_PORT_NUMBER> port) {
        meta.egress_spec = port;
    }

    table mac_forwarding {
        key = {
            hdr.eth.dst : exact;
        }
        actions = {
            mac_forward_set_egress;
            NoAction;
        }
    }

    bit<32> dst_gateway_ipv4 = 0;

    action ipv4_forward(bit<32> next_hop, bit<WIDTH_PORT_NUMBER> port) {
        meta.egress_spec = port;
        dst_gateway_ipv4 = next_hop;
        hdr.ipv4.ttl = hdr.ipv4.ttl - 1;
    }

    table ipv4_forwarding {
        key = {
            hdr.ipv4.dst : ternary;
        }
        actions = {
            ipv4_forward;
            NoAction;
        }
    }

    action arp_lookup_set_addresses(bit<48> mac_address) {
        hdr.eth.src = hdr.eth.dst;
        hdr.eth.dst = mac_address;
    }

    table next_hop_arp_lookup {
        key = {
            dst_gateway_ipv4 : exact;
        }
        actions = {
            arp_lookup_set_addresses;
            NoAction;
        }
    }

    apply {
        if (hdr.eth.isValid()) {
            if (mac_forwarding.apply().hit) return;
            if (hdr.ipv4.isValid() &&
                  hdr.ipv4.ttl > 1 &&
                  ipv4_forwarding.apply().hit) {
                if (next_hop_arp_lookup.apply().hit) return;
            }
        }
        drop();
    }
}


parser CompleteParser(packet_in pkt, out headers_t hdr, inout booster_metadata_t m, inout metadata_t meta) {
    state start {
        FecParser.apply(pkt, hdr);
        transition accept;
    }
}

#include "FPRuntime.p4"

// NOTE based on the MyIngress implementation in https://github.com/p4lang/tutorials/blob/76a9067deaf35cd399ed965aa19997776f72ec55/exercises/firewall/solution/firewall.p4#L189
#define BLOOM_FILTER_ENTRIES 4096
#define BLOOM_FILTER_BIT_WIDTH 1
typedef bit<9>  egressSpec_t;
typedef bit<48> macAddr_t;
typedef bit<32> ip4Addr_t;
control ALV_FW(inout headers_t hdr,
                  inout booster_metadata_t user_metadata,
                  inout metadata_t meta) {

    register<bit<BLOOM_FILTER_BIT_WIDTH>>(BLOOM_FILTER_ENTRIES) bloom_filter_1;
    register<bit<BLOOM_FILTER_BIT_WIDTH>>(BLOOM_FILTER_ENTRIES) bloom_filter_2;
    bit<32> reg_pos_one; bit<32> reg_pos_two;
    bit<1> reg_val_one; bit<1> reg_val_two;
    bit<1> direction;

    action compute_hashes(ip4Addr_t ipAddr1, ip4Addr_t ipAddr2, bit<16> port1, bit<16> port2){
       //Get register position
       hash(reg_pos_one, HashAlgorithm.crc16, (bit<32>)0, {ipAddr1,
                                                           ipAddr2,
                                                           port1,
                                                           port2,
                                                           hdr.ipv4.proto},
                                                           (bit<32>)BLOOM_FILTER_ENTRIES);

       hash(reg_pos_two, HashAlgorithm.crc32, (bit<32>)0, {ipAddr1,
                                                           ipAddr2,
                                                           port1,
                                                           port2,
                                                           hdr.ipv4.proto},
                                                           (bit<32>)BLOOM_FILTER_ENTRIES);
    }

    action set_direction(bit<1> dir) {
        direction = dir;
    }

    table check_ports {
        key = {
            meta.ingress_port: exact;
            meta.egress_spec: exact;
        }
        actions = {
            set_direction;
            NoAction;
        }
        size = 1024;
        default_action = NoAction();
    }

    #include "FPProcessState.p4"

    apply {
      if (!hdr.fp.isValid()) {
        drop(); // We're not expecting other traffic
      } else {
        #include "FPCheckFeedback.p4"
        deserialise_metadata(hdr, meta);

        if (2 == hdr.fp.to_segment) {
            direction = 0; // default
            if (check_ports.apply().hit) {
                // test and set the bloom filter
                if (direction == 0) {
                    compute_hashes(hdr.ipv4.src, hdr.ipv4.dst, hdr.tcp.sport, hdr.tcp.dport);
                }
                else {
                    compute_hashes(hdr.ipv4.dst, hdr.ipv4.src, hdr.tcp.dport, hdr.tcp.sport);
                }
                // Packet comes from internal network
                if (direction == 0){
                    // If there is a syn we update the bloom filter and add the entry
                    bit<1> syn = (bit<1>)((hdr.tcp.flags & 0b10) >> 1);
                    if (syn == 1){
                        bloom_filter_1.write(reg_pos_one, 1);
                        bloom_filter_2.write(reg_pos_two, 1);
                    }
                }
                // Packet comes from outside
                else if (direction == 1){
                    // Read bloom filter cells to check if there are 1's
                    bloom_filter_1.read(reg_val_one, reg_pos_one);
                    bloom_filter_2.read(reg_val_two, reg_pos_two);
                    // only allow flow to pass if both entries are set
                    if (reg_val_one != 1 || reg_val_two != 1){
                        drop();
                    }
                }
            }
            init_computation(hdr);
            set_computation_order(hdr, computation_continuing, 2, 3);
        } else {
           assert(FALSE == computation_continuing);
           hdr.fp.state = hdr.fp.state | InvalidCodeFlow;
        }
      }

      #include "FPPostComputation.p4"
    }
}

control Crosspod(inout headers_t hdr, inout booster_metadata_t m, inout metadata_t meta) {

    bit<1> run_program_ingress = 0;
    bit<1> run_program_egress = 0;

    action run_Complete_ingress() {
      run_program_ingress = 1;
    }

    table check_run_Complete_ingress {
        key = {
            meta.ingress_port : exact;
        }
        actions = {
            run_Complete_ingress;
            NoAction;
        }
    }

    action run_Complete_egress() {
      run_program_egress = 1;
    }

    table check_run_Complete_egress {
        key = {
            meta.egress_spec : exact;
        }
        actions = {
            run_Complete_egress;
            NoAction;
        }
    }

#if defined(FEC_BOOSTER)
    bit<FEC_K_WIDTH> k = 0;
    bit<FEC_H_WIDTH> h = 0;
    bit<24> proto_and_port = 0;
    FEC_Classify() classification;
    FecClassParams() decoder_params;
    FecClassParams() encoder_params;
#endif

#if defined(COMPRESSION_BOOSTER)
    CompressedLink() ingress_compression;
    CompressedLink() egress_compression;
#endif

    #include "FPProcessState.p4"

    apply {
      if (!hdr.fp.isValid()) {
        drop(); // We're not expecting other traffic
      } else {
        #include "FPCheckFeedback.p4"
        deserialise_metadata(hdr, meta);

        if (2 == hdr.fp.to_segment) {
            hdr.fp.setInvalid();
#if defined(FEC_BOOSTER)
            // If we received an FEC update, then update the table.
            bit<1> is_ctrl;
            FECController.apply(hdr, meta, is_ctrl);
            if (is_ctrl == 1) {
                drop();
                return;
            }
#endif

            bit<1> compressed_link = 0;
            bit<1> forward = 0;

#if defined(FEC_BOOSTER)
            // If lossy link, then FEC decode.
            if (hdr.fec.isValid()) {
                decoder_params.apply(hdr.fec.traffic_class, k, h);
                hdr.eth.type = hdr.fec.orig_ethertype;
                FEC_DECODE(hdr.fec, k, h);
                if (hdr.fec.isValid() && hdr.fec.packet_index >= k) {
                    drop();
                    return;
                }
                hdr.fec.setInvalid();
            }
#endif

#if defined(COMPRESSION_BOOSTER)
            // If multiplexed link, then header decompress.
            ingress_compression.apply(meta.ingress_port, compressed_link);
            if (compressed_link == 1) {
                header_decompress(forward);
                if (forward == 0) {
                    drop();
                    return;
                }
            }
#endif

#if defined(MEMCACHED_BOOSTER)
            // If Memcached REQ/RES then pass through the cache.
            if (hdr.udp.isValid()) {
                if (hdr.udp.dport == 11211 || hdr.udp.sport == 11211) {
                    memcached(forward);
                    if (forward == 0) {
                        drop();
                        return;
                    }
                }
            }
#endif
            init_computation(hdr);
            set_computation_order(hdr, computation_continuing, 2, 3);
        } else if (4 == hdr.fp.to_segment) {
            hdr.fp.setInvalid();
#if defined(COMPRESSION_BOOSTER)
            bit<1> compressed_link = 0;
            bit<1> forward = 0;
            // If heading out on a multiplexed link, then header compress.
            egress_compression.apply(meta.egress_spec, compressed_link);
            if (compressed_link == 1) {
                header_compress(forward);
                if (forward == 0) {
                    drop();
                    return;
                }
            }
#endif

#if defined(FEC_BOOSTER)
            bit<1> faulty = 0;

            // If heading out on a lossy link, then FEC encode.
            get_port_status(meta.egress_spec, faulty);
            if (faulty == 1) {
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
                                     hdr.fec.block_index, hdr.fec.packet_index);
                    hdr.fec.orig_ethertype = hdr.eth.type;
                    FEC_ENCODE(hdr.fec, k, h);
                    hdr.eth.type = ETHERTYPE_WHARF;
                }
            }
#endif
            init_computation(hdr);
            set_computation_order(hdr, computation_continuing, 4, 5);
        } else {
           assert(FALSE == computation_continuing);
           hdr.fp.state = hdr.fp.state | InvalidCodeFlow;
        }
      }

      #include "FPPostComputation.p4"
    }
}

control ComputeCheck(inout headers_t hdr, inout booster_metadata_t m) {
    apply {
        update_checksum(
            hdr.ipv4.isValid(),
            { hdr.ipv4.version,
              hdr.ipv4.ihl,
              hdr.ipv4.tos,
              hdr.ipv4.len,
              hdr.ipv4.id,
              hdr.ipv4.flags,
              hdr.ipv4.frag,
              hdr.ipv4.ttl,
              hdr.ipv4.proto,
              hdr.ipv4.src,
              hdr.ipv4.dst },
            hdr.ipv4.chksum, HashAlgorithm.csum16);
    }
}

control ProcessEgress(inout headers_t hdr, inout booster_metadata_t m, inout metadata_t meta) {
  apply {
    #include "FPRuntimeEgress.p4"
  }
}

V1Switch(CompleteParser(), NoVerify(), ALV_FW(), ProcessEgress()/*NoEgress()*/, ComputeCheck(), FecDeparser()) main;
