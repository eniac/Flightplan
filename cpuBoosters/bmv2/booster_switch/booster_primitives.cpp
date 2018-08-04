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

class get_fec_state : public ActionPrimitive<const Data &, Data &, Data &> {
    void operator ()(const Data &tclass_d, Data &block_id_d, Data &packet_idx_d) {
        int egress_port = phv->get_field("standard_metadata.egress_spec").get_int();
        uint8_t tclass = tclass_d.get<uint8_t>();

        uint8_t block_id = get_fec_block_id(tclass, egress_port);
        uint8_t packet_idx = get_fec_frame_idx(tclass, egress_port);

        BMLOG_DEBUG("Tclass {:03b} has block id {:d}, packet idx {:d}", tclass, block_id, packet_idx);

        block_id_d.set(block_id);
        packet_idx_d.set(packet_idx);
    }
};

REGISTER_PRIMITIVE(get_fec_state);

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

char *serialize_headers(char *buff) { return buff; }

template <typename T = Header&, typename... H>
char *serialize_headers(char *buff, T &hdr1, H&... h) {
    if (hdr1.is_valid()) {
        hdr1.deparse(buff);
        buff += hdr1.get_nbytes_packet();
    }
    return serialize_headers(buff, h...);
}

size_t hdr_size() { return 0; }

template <typename T = Header &, typename... H>
size_t hdr_size(T &hdr1, H&...h) {
    size_t hdr1_size = hdr1.is_valid() ? hdr1.get_nbytes_packet() : 0;
    return hdr1_size + hdr_size(h...);
}

template <typename T = Header&, typename... H>
u_char *serialize_with_headers(const Packet &packet, size_t &size, H&... h) {
    size_t payload_size = packet.get_data_size();
    size = payload_size + hdr_size(h...);
    u_char *buff = new u_char[size];
    char *payload = serialize_headers((char*)buff, h...);
    memcpy(payload, packet.data(), payload_size);
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

void replace_header(PHV *, char *){}

template <typename T = Header &, typename ... H>
void replace_header(PHV *phv, char *buff, T &hdr1, H &...h) {
    if (hdr1.is_valid()) {
        hdr1.extract(buff, *phv);
        buff += hdr1.get_nbytes_packet();
    }
    replace_header(phv, buff, h...);
}

template <typename ... Hdrs>
void replace_headers(Packet &packet, u_char *buff, Hdrs& ... h) {
    PHV *phv = packet.get_phv();
    char *hdr_buff = (char *)buff;
    replace_header(phv, hdr_buff, h...);
    delete[] buff;
}

template <typename T>
T get_field_by_name(const Header &hdr, const std::string field_name) {
    int offset = hdr.get_header_type().get_field_offset(field_name);
    return hdr.get_field(offset).get<T>();
}

/**
 * Version of fec_encode extern that can accept variable numbers of headers as arguments
 */
template <typename... Arguments>
class var_fec_encode : public ActionPrimitive<Header &, const Data &, const Data &, Arguments...> {

    void operator ()(Header &fec_h, const Data &k_d, const Data &h_d, Arguments... headers) {
        Packet &packet = this->get_packet();
        PHV *phv = packet.get_phv();
        int egress_port = phv->get_field("standard_metadata.egress_spec").get_int();

        // Stores the serialized packet and ethernet/ip headers in `*buff`
        size_t buff_size;
        u_char *buff = serialize_with_headers(packet, buff_size, headers...);

        struct fec_header *fec = deparse_header<struct fec_header>(fec_h);

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

        // Replaces the deserialized headers back to the packet
        replace_headers(packet, buff, headers...);
        replace_headers(packet, (u_char*)fec, fec_h);
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

/** Specialization of fec_encode extern to accept exactly four headers */
using fec_encode = var_fec_encode<Header &, Header &, Header &, Header&>;

REGISTER_PRIMITIVE(fec_encode);

class fec_decode : public ActionPrimitive<Header &, Header &,
                                          const Data &, const Data &> {

    void operator ()(Header &eth_h, Header &fec_h,
                     const Data &k_d, const Data &h_d) {
        Packet &packet = get_packet();
        PHV *phv = packet.get_phv();
        int ingress_port = phv->get_field("standard_metadata.ingress_port").get_int();

        // Stores the serialized packet and ethernet/ip headers in *buff
        size_t buff_size;
        u_char *buff = serialize_with_headers(packet, buff_size, eth_h);

        struct fec_header *fec = deparse_header<struct fec_header>(fec_h);

        // Retrieves the integers corresponding to k and h
        uint8_t k = k_d.get<uint8_t>();
        uint8_t h = h_d.get<uint8_t>();

        // Set up function that will forward the packets (egress port is unused here)
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

        fec_decode_p4_packet(buff, buff_size, fec, ingress_port, k, h, forwarder, dropper);

        // Replace the deserialized headers back into the packet
        replace_headers(packet, buff, eth_h);
        replace_headers(packet, (u_char*)fec, fec_h);
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


// dummy function, which ensures that this unit is not discarded by the linker
// it is being called by the constructor of SimpleSwitch
// the previous alternative was to have all the primitives in a header file (the
// primitives could also be placed in simple_switch.cpp directly), but I need
// this dummy function if I want to keep the primitives in their own file
int import_booster_primitives() {
  return 0;
}
