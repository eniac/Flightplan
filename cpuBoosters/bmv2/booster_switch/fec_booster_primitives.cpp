#ifdef FEC_BOOSTER

#include <bm/bm_sim/actions.h>
#include <bm/bm_sim/calculations.h>
#include <bm/bm_sim/core/primitives.h>
#include <bm/bm_sim/counters.h>
#include <bm/bm_sim/meters.h>
#include <bm/bm_sim/packet.h>
#include <bm/bm_sim/phv.h>
#include <bm/bm_sim/switch.h>
#include <bm/bm_sim/logger.h>
#include <bm/spdlog/spdlog.h>
#include <arpa/inet.h>
#include <time.h>

#include "booster_primitives.hpp"
#include "simple_switch.h"
#include "fecBoosters/fecP4/fecEncodeBooster.hpp"
#include "fecBoosters/fecP4/fecDecodeBooster.hpp"
#include "fecBoosters/fecBooster.h"
#include "fecBoosters/fecP4/fecP4.hpp"

/**
 * NOTE: the booster switch provides four functions for creating new packets:
 *
 * - enqueue_booster_packet(src, buffer, len) Ties the new packet to the source packet,
 *   so it will be send out immediately preceding the source.
 *   Buffer must contain deparsed headers
 *
 * - output_booster_packet(src, buffer, len) Outputs the booster packet immediately,
 *   and does not wait for the source to be sent. Useful if the source may be dropped.
 *   Buffer must contain deparsed headers
 *
 * - deparse_booster_packet(src, buffer, len) Copies the headers from the source packet,
 *   and sends the new packet to the deparser.
 *   Buffer must *not* contain a copy of the headers
 *
 * - recirculate_booster_packet(src, payload, len) Copies headers from the source packet,
 *   and recirculates the packet back to ingress
 *   Buffer must *not* contain a copy of the headers
 */

#include <iostream>
#include <fstream>
#define PACKET_LENGTH_REG_IDX 0

template <typename... Args>
using BoosterExtern = boosters::BoosterExtern<Args...>;
using bm::Switch;
using bm::PHV;
using bm::Packet;
using bm::Data;
using bm::Field;
using bm::Header;
using bm::MeterArray;
using bm::CounterArray;
using bm::RegisterArray;
using bm::NamedCalculation;
using bm::HeaderStack;

class update_fec_state : public BoosterExtern<const Data &, const Data &, const Data &,
                                              Data &, Data &> {
    using BoosterExtern::BoosterExtern;

    void operator ()(const Data &tclass_d, const Data &k_d, const Data &h_d,
                     Data &block_id_d, Data &packet_idx_d) {
        int egress_port = phv->get_field("standard_metadata.egress_spec").get_int();

        uint8_t tclass = tclass_d.get<uint8_t>();
        uint8_t k = k_d.get<uint8_t>();
        uint8_t h = h_d.get<uint8_t>();
        set_fec_params(tclass, k, h);


        uint8_t block_id = get_fec_block_id(tclass, egress_port);
        uint8_t packet_idx = get_fec_frame_idx(tclass, egress_port);

        BMLOG_DEBUG("Tclass {:03b} egress {} has block id {:d}, packet idx {:d}", 
                tclass, egress_port, block_id, packet_idx);

        block_id_d.set(block_id);
        packet_idx_d.set(packet_idx);

        advance_packet_idx(tclass, egress_port);
        egress_port = phv->get_field("standard_metadata.egress_spec").get_int();
        BMLOG_DEBUG("Egress port is now {}", egress_port);
    }
};


class set_port_status : public BoosterExtern<const Data &> {
    using BoosterExtern::BoosterExtern;

    void operator ()(const Data &port_d) {
        uint8_t port = port_d.get<uint8_t>();

        BMLOG_DEBUG("Setting port status for port {:1d}", port);
        set_fec_port_status(port);
    }
};


class get_port_status: public BoosterExtern<const Data &, Data &> {
    using BoosterExtern::BoosterExtern;

    void operator ()(const Data &port_d, Data &faulty_d) {
        uint8_t port = port_d.get<uint8_t>();

        bool faulty = get_fec_port_status(port);
        faulty_d.set(faulty);
        BMLOG_DEBUG("Port status for port {:1d} is {:1d}", port, faulty)
    }
};

template <typename... Args>
class fec_encode_core : public BoosterExtern<Header &, const Data &, const Data &, Args...> {
    // Inherit constructor
    using BoosterExtern<Header &, const Data &, const Data &, Args...>::BoosterExtern;

protected:
    void core(Header &fec_h, const Data &k_d, const Data &h_d, Header *fp_h) {
        if (this->is_generated()) {
            if (fp_h != nullptr) {
                fp_h->mark_valid();
            }
            return;
        }
        Packet &packet = this->get_packet();
        PHV *phv = packet.get_phv();
        int egress_port = phv->get_field("standard_metadata.egress_spec").get_int();
        BMLOG_DEBUG("Attempting fec encode of pkt with egress {}", egress_port);
        int ingress_port = packet.get_ingress_port();

        if (fp_h != nullptr)
            fp_h->mark_invalid();

        // Must save packet state so it can be restored after deparsing
        const Packet::buffer_state_t packet_in_state = packet.save_buffer_state();

        // Get the FEC header, and mark it invalid so it won't show up in
        // the serialized packet
        struct fec_header *fec = boosters::deparse_header<struct fec_header>(fec_h);
        bool is_fec_valid = fec_h.is_valid();
        fec_h.mark_invalid();

        auto deparser = this->get_p4objects()->get_deparser("deparser");
        // Deparse the packet and get the packet state so it can be restored later
        deparser->deparse(&packet);
        //const Packet::buffer_state_t packet_in_state = this->deparse_packet();

        char *buff = packet.data();
        size_t buff_size = packet.get_data_size();

        // Retrieves the integers corresponding to the passed-in values
        uint8_t k = k_d.get<uint8_t>();
        uint8_t h = h_d.get<uint8_t>();

        // Set up the function that will forwaard the packet
        // (egress_port is ignored here -- can be obtained from the template packet)
        auto forwarder = [&](const u_char *payload, size_t len, int egress_port) {
            (void)egress_port;
            this->generate_packet((const char*)payload, len, ingress_port);
        };
        // Does the actual external work
        fec_encode_p4_packet((u_char *)buff, buff_size, fec, egress_port, k, h, 2000, forwarder);

        BMLOG_DEBUG("Fec index {:d}", fec->index);
        this->reparse_packet(packet_in_state);
        packet.restore_buffer_state(packet_in_state);
        if (is_fec_valid)
            fec_h.mark_valid();

        if (fp_h != nullptr)
            fp_h->mark_valid();

        // Must set buffer size in fec header explicitly
        uint16_t buff_size_16 = buff_size;
        BMLOG_DEBUG("Set packet length to {:d}", buff_size_16);
        phv->get_field("fec.packet_len").set(htons(buff_size_16));
    }

    void timeout_handler () {
        auto forwarder = [&](const u_char *payload, size_t len, int egress_port) {
            this->output_packet((const char *)payload, len, egress_port);
        };
        fec_encode_timeout_handler(forwarder);
    }
    // TODO: FIX BY BRINGING IN NEW PERIODIC SEMANTICS
    // Placing this call inside the class only registers it only
    // when the class is instantiated (i.e. only if the extern is used)
    // REGISTER_PERIODIC_CALL(timeout_handler);
};

/** FEC encode without flightplan header */
class fec_encode : public fec_encode_core<> {
    using fec_encode_core::fec_encode_core;

    void operator ()(Header &fec_h, const Data &k_d, const Data &h_d) {
        core(fec_h, k_d, h_d, nullptr);
    }
};

/** FEC encode with flightplan header */
class fec_encode_fp : public fec_encode_core<Header &> {
    using fec_encode_core::fec_encode_core;

    void operator ()(Header &fec_h, const Data &k_d, const Data &h_d, Header &fp_h) {
        core(fec_h, k_d, h_d, &fp_h);
    }
};

template <typename ...Args>
class fec_decode_core : public BoosterExtern<Header &, const Data &, const Data &, Args...> {
    // Inherit constructor
    using BoosterExtern<Header &, const Data &, const Data &, Args...>::BoosterExtern;

protected:
    void core(Header &fec_h, const Data &k_d, const Data &h_d, Header *fp_h) {
        if (this->is_generated()) {
            boosters::printHeader(fec_h);
            if (fp_h != nullptr) {
                fp_h->mark_valid();
            }
            return;
        }
        Packet &packet = this->get_packet();
        int ingress_port = packet.get_ingress_port();

        if (fp_h != nullptr)
            fp_h->mark_invalid();

        // Must save packet state so it can be restored after deparsing
        const Packet::buffer_state_t packet_in_state = packet.save_buffer_state();

        bool is_fec_valid = fec_h.is_valid();
        fec_h.mark_invalid();

        // Deparse packet so valid headers are available in packet.data()
        auto deparser = this->get_p4objects()->get_deparser("deparser");
        deparser->deparse(&packet);

        char *buff = packet.data();

        // Deparses the fec header so it can be read in c++
        struct fec_header *fec = boosters::deparse_header<struct fec_header>(fec_h);
        BMLOG_DEBUG("Fec index {:d}", fec->index);

        // Retrieves the integers corresponding to k and h
        uint8_t k = k_d.get<uint8_t>();
        uint8_t h = h_d.get<uint8_t>();

        // Set up function that will forward the packets 
        auto forwarder = [&](const u_char *payload, size_t len) {
            this->generate_packet((const char*)payload, len, ingress_port);
        };

        auto dropper = [&]() {
            // Mark to drop
            this->get_field("standard_metadata.egress_spec").set(511);
            if (this->get_phv().has_field("intrinsic_metadata.mcast_grp")) {
                this->get_field("intrinsic_metadata.mcast_grp").set(0);
            }
            BMLOG_DEBUG("Marked to drop decoded packet");
        };

        int packet_len_offset = fec_h.get_header_type().get_field_offset("packet_len");
        if (packet_len_offset < 0) {
            BMLOG_DEBUG("Cannot find packet_len field in FEC header!");
            boosters::printHeader(fec_h);
            return;
        }
        auto packet_len_f = fec_h.get_field(packet_len_offset);
        uint16_t pkt_len = ntohs(packet_len_f.get<uint16_t>());

        fec_decode_p4_packet((const u_char*)buff, (size_t)pkt_len, fec, ingress_port, k, h, forwarder, dropper);
        this->reparse_packet(packet_in_state);
        if (is_fec_valid)
            fec_h.mark_valid();
        if (fp_h != nullptr)
            fp_h->mark_valid();
    }
};

/** FEC decode without flightplan header */
class fec_decode : public fec_decode_core<> {
    // Inherit the constructor
    using fec_decode_core::fec_decode_core;

    void operator()(Header &fec_h, const Data &k_d, const Data &h_d) {
        core(fec_h, k_d, h_d, nullptr);
    }
};

/** FEC decode with flightplan header */
class fec_decode_fp : public fec_decode_core<Header &> {
    // Inherit the constructor
    using fec_decode_core::fec_decode_core;

    void operator ()(Header &fec_h, const Data &k_d, const Data &h_d, Header &fp_h) {
        core(fec_h, k_d, h_d, &fp_h);
    }
};

class random_drop : public BoosterExtern<const Data &, const Data &, const Data &> {
    using BoosterExtern::BoosterExtern;

    std::vector<int> packet_idx = {0,0,0,0,0,0,0,0};
    std::vector<int> drop_idx = {0,0,0,0,0,0,0,0};

    void operator ()(const Data &n1_d, const Data &n2_d, const Data &egress_d) {
        int n1 = n1_d.get_int();
        int n2 = n2_d.get_int();
        int egress = egress_d.get_int();

        if (packet_idx[egress] == 0) {
            drop_idx[egress] = n2 + rand() % n1;
            BMLOG_DEBUG("Setting drop index to {}/{}", drop_idx[egress], n1 + n2);
        }

        if (drop_idx[egress] == packet_idx[egress]) {
            // Mark to drop
            get_field("standard_metadata.egress_spec").set(511);
            if (get_phv().has_field("intrinsic_metadata.mcast_grp")) {
                get_field("intrinsic_metadata.mcast_grp").set(0);
            }
            BMLOG_DEBUG("Dropping packet {}", packet_idx[egress]);
        }

        packet_idx[egress] = (packet_idx[egress] + 1) % (n1 + n2);
    }
};


class print_headers : public BoosterExtern<> {
    using BoosterExtern::BoosterExtern;

    void operator ()() {
        Packet &packet = get_packet();
        PHV *phv = packet.get_phv();
        for (auto it = phv->header_begin(); it != phv->header_end(); it++) {
            boosters::printHeader(*it);
        }
    }
};


#endif //FEC_BOOSTERS

// dummy function, which ensures that this unit is not discarded by the linker
// it is being called by the constructor of SimpleSwitch
// the previous alternative was to have all the primitives in a header file (the
// primitives could also be placed in simple_switch.cpp directly), but I need
// this dummy function if I want to keep the primitives in their own file
int import_fec_booster_primitives(SimpleSwitch *sswitch) {
  if (rse_init() != 0) {
      printf("ERROR initializing RSE\n");
      exit(-1);
  }
  REGISTER_BOOSTER_EXTERN(update_fec_state, sswitch);
  REGISTER_BOOSTER_EXTERN(set_port_status, sswitch);
  REGISTER_BOOSTER_EXTERN(get_port_status, sswitch);
  REGISTER_BOOSTER_EXTERN(fec_encode, sswitch);
  REGISTER_BOOSTER_EXTERN(fec_encode_fp, sswitch);
  REGISTER_BOOSTER_EXTERN(fec_decode, sswitch);
  REGISTER_BOOSTER_EXTERN(fec_decode_fp, sswitch);
  REGISTER_BOOSTER_EXTERN(random_drop, sswitch);
  REGISTER_BOOSTER_EXTERN(print_headers, sswitch);
  return 0;
}
