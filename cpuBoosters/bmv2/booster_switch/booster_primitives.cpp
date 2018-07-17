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

#include "simple_switch.h"
#include "fec_boosters/fecP4/fecEncodeBooster.hpp"
#include "fec_boosters/fecP4/fecDecodeBooster.hpp"
#include "fec_boosters/fecBooster.h"

/**
 * NOTE: the booster switch provides three functions for creating new packets:
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

namespace sswitch_runtime {
    SimpleSwitch *get_switch();
} // namespace sswitch_runtime

namespace {

void printHeader(const Header &hdr) {
    for (int i=0; i < hdr.get_header_type().get_num_fields(); i++) {
        BMLOG_DEBUG("{}, {}", i, hdr.get_header_type().get_num_fields());
        std::string name = hdr.get_field_name(i);
        const Field &field = hdr.get_field(i);
        std::stringstream ss;
        ss << std::setw(16) << std::setfill('0') << std::hex << field.get_uint64();
        std::string hexstr = ss.str();;
        BMLOG_DEBUG("Hdr field {}, name {}, val {}", i, name, hexstr);
    }
}

} // namespace

class get_fec_state : public ActionPrimitive<const Data &, Data &, Data &> {
    void operator ()(const Data &tclass_d, Data &block_id_d, Data &packet_idx_d) {
        uint8_t tclass = tclass_d.get<uint8_t>();

        uint8_t block_id = get_fec_block_id(tclass);
        uint8_t packet_idx = get_fec_frame_idx(tclass);

        BMLOG_DEBUG("Tclass {:03b} has block id {:d}, packet idx {:d}", tclass, block_id, packet_idx);

        block_id_d.set(block_id);
        packet_idx_d.set(packet_idx);
    }
};

REGISTER_PRIMITIVE(get_fec_state);

u_char *serialize_with_headers(const Packet &packet, size_t &size, std::vector<Header *>headers) {
    size_t payload_size = packet.get_data_size();
    size = payload_size;
    for (auto h : headers) {
        if (h->is_valid()) {
            size += h->get_nbytes_packet();
        }
    }
    u_char *buff = new u_char[size];
    char *hdr_buff = (char*)buff;
    for (auto h : headers) {
        if (h->is_valid()) {
            h->deparse(hdr_buff);
            hdr_buff += h->get_nbytes_packet();
        }
    }
    memcpy(hdr_buff, packet.data(), payload_size);
    return buff;
}

template <typename T>
T *deparse_header(Header &header) {
    size_t size = header.get_nbytes_packet();
    if (size != sizeof(T)) {
        BMLOG_DEBUG("WARNING: Sizes do not match for deparsed header");
    }
    char *buff = new char[size];
    header.deparse(buff);
    return (T*)buff;
}

void replace_headers(Packet &packet, u_char *buff, std::vector<Header *> headers) {
    PHV *phv = packet.get_phv();
    char *hdr_buff = (char*)buff;
    for (auto h : headers) {
        if (h->is_valid()) {
            h->extract(hdr_buff, *phv);
            hdr_buff += h->get_nbytes_packet();
        }
    }
    delete[] buff;
}

template <typename T>
T get_field_by_name(const Header &hdr, const std::string field_name) {
    int offset = hdr.get_header_type().get_field_offset(field_name);
    return hdr.get_field(offset).get<T>();
}

class fec_encode : public ActionPrimitive<Header &, Header &, Header &,
                                          const Data &, const Data &> {
    void operator ()(Header &eth_h, Header &ip_h, Header &fec_h,
                     const Data &k_d, const Data &h_d) {
        Packet &packet = get_packet();

        // Stores the serialized packet and ethernet/ip headers in `*buff`
        size_t buff_size;
        u_char *buff = serialize_with_headers(packet, buff_size, {&eth_h, &ip_h});

        struct fec_header *fec = deparse_header<struct fec_header>(fec_h);

        // Retrieves the integers corresponding to the passed-in values
        uint8_t k = k_d.get<uint8_t>();
        uint8_t h = h_d.get<uint8_t>();

        // Set up the function that will forwaard the packet
        auto forwarder = [&](const u_char *payload, size_t len) {
            sswitch_runtime::get_switch()->enqueue_booster_packet(packet, payload, len);
        };
        // Does the actual external work
        fec_encode_p4_packet(buff, buff_size, fec, k, h, forwarder);

        // Replaces the deserialized headers back to the packet
        replace_headers(packet, buff, {&eth_h, &ip_h});
        replace_headers(packet, (u_char*)fec, {&fec_h});
    }
};

REGISTER_PRIMITIVE(fec_encode);


class fec_decode : public ActionPrimitive<Header &, Header &,
                                          const Data &, const Data &> {

    void operator ()(Header &eth_h, Header &fec_h,
                     const Data &k_d, const Data &h_d) {
        Packet &packet = get_packet();

        // Stores the serialized packet and ethernet/ip headers in *buff
        size_t buff_size;
        u_char *buff = serialize_with_headers(packet, buff_size, {&eth_h});

        struct fec_header *fec = deparse_header<struct fec_header>(fec_h);

        // Retrieves the integers corresponding to k and h
        uint8_t k = k_d.get<uint8_t>();
        uint8_t h = h_d.get<uint8_t>();

        // Set up function that will forward the packets
        auto forwarder = [&](const u_char *payload, size_t len) {
            sswitch_runtime::get_switch()->output_booster_packet(packet, payload, len);
        };

        fec_decode_p4_packet(buff, buff_size, fec, k, h, forwarder);

        // Replace the deserialized headers back into the packet
        replace_headers(packet, buff, {&eth_h});
        replace_headers(packet, (u_char*)fec, {&fec_h});
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
        sswitch_runtime::get_switch()->deparse_booster_packet(packet, new_payload, payload_size);
    }
};

REGISTER_PRIMITIVE(copy_modified);

// dummy function, which ensures that this unit is not discarded by the linker
// it is being called by the constructor of SimpleSwitch
// the previous alternative was to have all the primitives in a header file (the
// primitives could also be placed in simple_switch.cpp directly), but I need
// this dummy function if I want to keep the primitives in their own file
int import_booster_primitives() {
  return 0;
}
