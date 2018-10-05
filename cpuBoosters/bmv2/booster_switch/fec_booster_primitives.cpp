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
using ActionPrimitive = bm::ActionPrimitive<Args...>;
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


class update_fec_state : public ActionPrimitive<const Data &, const Data &, const Data &,
                                                Data &, Data &> {
    void operator ()(const Data &tclass_d, const Data &k_d, const Data &h_d,
                     Data &block_id_d, Data &packet_idx_d) {
        int egress_port = phv->get_field("standard_metadata.egress_spec").get_int();

        uint8_t tclass = tclass_d.get<uint8_t>();
        uint8_t k = k_d.get<uint8_t>();
        uint8_t h = h_d.get<uint8_t>();
        set_fec_params(tclass, k, h);


        uint8_t block_id = get_fec_block_id(tclass, egress_port);
        uint8_t packet_idx = get_fec_frame_idx(tclass, egress_port);

        BMLOG_DEBUG("Tclass {:03b} has block id {:d}, packet idx {:d}", tclass, block_id, packet_idx);

        block_id_d.set(block_id);
        packet_idx_d.set(packet_idx);

        advance_packet_idx(tclass, egress_port);
    }
};

REGISTER_PRIMITIVE(update_fec_state);

class set_port_status : public ActionPrimitive<const Data &> {
    void operator ()(const Data &port_d) {
        uint8_t port = port_d.get<uint8_t>();

        BMLOG_DEBUG("Setting port status for port {:1d}", port);
        set_fec_port_status(port);
    }
};

REGISTER_PRIMITIVE(set_port_status);

class get_port_status: public ActionPrimitive<const Data &, Data &> {
    void operator ()(const Data &port_d, Data &faulty_d) {
        uint8_t port = port_d.get<uint8_t>();

        bool faulty = get_fec_port_status(port);
        faulty_d.set(faulty);
        BMLOG_DEBUG("Port status for port {:1d} is {:1d}", port, faulty)
    }
};

REGISTER_PRIMITIVE(get_port_status);

/**
 * Version of fec_encode extern which automatically finds headers
 */
class fec_encode : public ActionPrimitive<Header &, const Data &, const Data &> {

    void operator ()(Header &fec_h, const Data &k_d, const Data &h_d) {
        Packet &packet = this->get_packet();
        PHV *phv = packet.get_phv();
        int egress_port = phv->get_field("standard_metadata.egress_spec").get_int();

        bool is_fec_valid = fec_h.is_valid();
        fec_h.mark_invalid();
        // Retrieve the headers which are valid and not metadata
        std::vector<Header *>hdrs;
        boosters::get_valid_headers(packet, hdrs);
        if (is_fec_valid) {
            fec_h.mark_valid();
        }

        // Stores the serialized packet and valid headers in `*buff`
        size_t buff_size;
        u_char *buff = boosters::serialize_with_headers(packet, buff_size, hdrs);
        // Deparses the fec header so it can be read in c++;
        struct fec_header *fec = boosters::deparse_header<struct fec_header>(fec_h);

        // Retrieves the integers corresponding to the passed-in values
        uint8_t k = k_d.get<uint8_t>();
        uint8_t h = h_d.get<uint8_t>();

        // Set up the function that will forwaard the packet
        // (egress_port is ignored here -- can be obtained from the template packet)
        auto forwarder = [&](const u_char *payload, size_t len, int egress_port) {
            (void)egress_port;
            SimpleSwitch::get_instance()->enqueue_booster_packet(packet, payload, len);
        };
        // Does the actual external work
        fec_encode_p4_packet(buff, buff_size, fec, egress_port, k, h, 2000, forwarder);

        BMLOG_DEBUG("Fec index {:d}", fec->index);
        // Replaces the deserialized headers back to the packet
        boosters::replace_headers(packet, buff, hdrs);
        boosters::replace_headers(packet, (u_char*)fec, fec_h);
        BMLOG_DEBUG("Fec index after: {:d}", phv->get_field("fec.packet_index").get_int());

        /* For some reason setting directly in the header doesn't work. Must be done through phv
        int packet_len_offset = fec_h.get_header_type().get_field_offset("packet_len");
        if (packet_len_offset < 0) {
            BMLOG_DEBUG("Cannot find packet_len field in FEC header!");
            boosters::printHeader(fec_h);
            return;
        }
        auto packet_len_f = fec_h.get_field(packet_len_offset);
        packet_len_f.set(htons(buff_size_16));
        */
        uint16_t buff_size_16 = buff_size;
        BMLOG_DEBUG("Set packet length to {:d}", buff_size_16);
        phv->get_field("fec.packet_len").set(htons(buff_size_16));
    }

    static void timeout_forwarder(const u_char *payload, size_t len, int egress_port) {
        SimpleSwitch::get_instance()->output_booster_packet(egress_port, payload, len);
    }

    static void timeout_handler () {
        fec_encode_timeout_handler(timeout_forwarder);
    }

    // Placing this call inside the class only registers it only
    // when the class is instantiated (i.e. only if the extern is used)
    REGISTER_PERIODIC_CALL(timeout_handler);
};

REGISTER_PRIMITIVE(fec_encode);

class fec_decode : public ActionPrimitive<Header &, const Data &, const Data &> {

    void operator ()(Header &fec_h, const Data &k_d, const Data &h_d) {
        Packet &packet = get_packet();
        PHV *phv = packet.get_phv();
        int ingress_port = phv->get_field("standard_metadata.ingress_port").get_int();

        bool is_fec_valid = fec_h.is_valid();
        fec_h.mark_invalid();
        // Retrieve the headers which are valid and not metadata
        std::vector<Header *>hdrs;
        boosters::get_valid_headers(packet, hdrs);
        if (is_fec_valid) {
            fec_h.mark_valid();
        }

        // Stores the serialized packet and valid headers in `*buff`
        size_t buff_size;
        u_char *buff = boosters::serialize_with_headers(packet, buff_size, hdrs);

        BMLOG_DEBUG("Fec index before: {:d}", phv->get_field("fec.packet_index").get_int());
        // Deparses the fec header so it can be read in c++
        struct fec_header *fec = boosters::deparse_header<struct fec_header>(fec_h);
        BMLOG_DEBUG("Fec index {:d}", fec->index);

        // Retrieves the integers corresponding to k and h
        uint8_t k = k_d.get<uint8_t>();
        uint8_t h = h_d.get<uint8_t>();

        // Set up function that will forward the packets 
        auto forwarder = [&](const u_char *payload, size_t len) {
            SimpleSwitch::get_instance()->recirculate_booster_packet(packet, payload, len);
        };

        auto dropper = [&]() {
            // Mark to drop
            get_field("standard_metadata.egress_spec").set(511);
            if (get_phv().has_field("intrinsic_metadata.mcast_grp")) {
                get_field("intrinsic_metadata.mcast_grp").set(0);
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

        fec_decode_p4_packet(buff, (size_t)pkt_len, fec, ingress_port, k, h, forwarder, dropper);

        // Replace the deserialized headers back into the packet
        boosters::replace_headers(packet, buff, hdrs);
        boosters::replace_headers(packet, (u_char*)fec, fec_h);
    }
};

REGISTER_PRIMITIVE(fec_decode);

/**
 * Copy_modified accepts an index, a width, and a value.
 * It copies `width` bytes from `value` into location `index` of a copy of the payload,
 * then enqueues the newly modified (copied) packet for deparsing.
 */
class copy_modified : public ActionPrimitive<const Data &, const Data &, const Data &> {

    void operator ()(const Data &idx_d, const Data &width_d, const Data &value_d) {
        Packet &packet = get_packet();

        // Retrieve the value of the passed in data
        uint8_t idx = idx_d.get<uint8_t>();
        uint8_t width = width_d.get<uint8_t>();
        std::string value = value_d.get_string();

        size_t payload_size = packet.get_data_size();
        if (payload_size <= idx + width) {
            BMLOG_DEBUG("Payload size {} is smaller than max modification index {}",
                        payload_size, idx + width);
            return;
        }

        // Create a copy of the payload, modifying the appropriate bits
        u_char new_payload[payload_size];
        memcpy(new_payload, packet.data(), payload_size);
        memcpy(&new_payload[idx], value.c_str(), width);

        // Send the new packet to the deparser for output
        SimpleSwitch::get_instance()->deparse_booster_packet(packet, new_payload, payload_size);
    }
};

REGISTER_PRIMITIVE(copy_modified);

class random_drop : public ActionPrimitive<const Data &, const Data &> {

    int packet_idx = 0;
    int drop_idx = 0;

    void operator ()(const Data &n1_d, const Data &n2_d) {
        int n1 = n1_d.get_int();
        int n2 = n2_d.get_int();

        if (packet_idx == 0) {
            drop_idx = rand() % n1;
            BMLOG_DEBUG("Setting drop index to {}/{}", drop_idx, n1 + n2);
        }

        if (drop_idx == packet_idx) {
            // Mark to drop
            get_field("standard_metadata.egress_spec").set(511);
            if (get_phv().has_field("intrinsic_metadata.mcast_grp")) {
                get_field("intrinsic_metadata.mcast_grp").set(0);
            }
            BMLOG_DEBUG("Dropping packet {}", packet_idx);
        }

        packet_idx = (packet_idx + 1) % (n1 + n2);
    }
};

REGISTER_PRIMITIVE(random_drop);

class print_headers : public ActionPrimitive<> {
    void operator ()() {
        Packet &packet = get_packet();
        PHV *phv = packet.get_phv();
        for (auto it = phv->header_begin(); it != phv->header_end(); it++) {
            boosters::printHeader(*it);
        }
    }
};

REGISTER_PRIMITIVE(print_headers);

#endif //FEC_BOOSTERS

// dummy function, which ensures that this unit is not discarded by the linker
// it is being called by the constructor of SimpleSwitch
// the previous alternative was to have all the primitives in a header file (the
// primitives could also be placed in simple_switch.cpp directly), but I need
// this dummy function if I want to keep the primitives in their own file
int import_fec_booster_primitives() {
  return 0;
}


