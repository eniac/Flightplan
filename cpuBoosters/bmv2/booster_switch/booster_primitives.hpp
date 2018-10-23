#ifndef BOOSTER_PRIMITIVES_HPP_
#define BOOSTER_PRIMITIVES_HPP_

#include <bm/bm_sim/phv.h>
#include <bm/bm_sim/packet.h>
#include <bm/bm_sim/actions.h>
#include <bm/bm_sim/logger.h>

#include "simple_switch.h"

#define REGISTER_BOOSTER_EXTERN(extern_name, sswitch_p) \
    bm::ActionOpcodesMap::get_instance()->register_primitive( \
        #extern_name, \
        [sswitch_p]() { return std::unique_ptr<bm::ActionPrimitive_>( \
                               new extern_name(sswitch_p)); })

namespace boosters {

template <typename... Args>
class BoosterExtern : public bm::ActionPrimitive<Args...> {
protected:
    using bm::ActionPrimitive<Args...>::get_packet;

    SimpleSwitch *sswitch;

    void generate_packet(const char *payload, size_t len,
                        int ingress_port, int egress_port = -1) {
        assert(sswitch);
        Packet &input = this->get_packet();
        auto booster_pkt = sswitch->create_booster_packet(
            &input, ingress_port, payload, len
        );
        if (egress_port != -1) {
            booster_pkt->get_phv()->get_field("standard_metadata.egress_spec").set(egress_port);
        }
        if (input.last_node != nullptr) {
            BMLOG_DEBUG("New booster packet insertion");
            booster_pkt->next_node = input.last_node;
        } else {
            BMLOG_DEBUG("No specified entry point for booster packet");
        }
        sswitch->insert_booster_packet(std::move(booster_pkt));

    }

    void output_packet(const char *payload, size_t len, int egress_port) {
        assert(sswitch);
        auto booster_pkt = sswitch->create_booster_packet(
            nullptr, 0, payload, len
        );
        booster_pkt->set_egress_port(egress_port);
        sswitch->output_booster_packet(std::move(booster_pkt));
    }

public:
    BoosterExtern(SimpleSwitch *sswitch) : sswitch{sswitch} {}

};

void import_booster_externs(SimpleSwitch *sswitch);

using bm::PHV;
using bm::Header;
using bm::Packet;
using bm::Field;

void printHeader(const Header &hdr);

// Necessary for variadic template expansion
char *serialize_headers(char *buff);
size_t hdr_size();
void replace_header(PHV *, char *);

template <typename T = Header&, typename... H>
char *serialize_headers(char *buff, T &hdr1, H&... h) {
    if (hdr1.is_valid()) {
        hdr1.deparse(buff);
        buff += hdr1.get_nbytes_packet();
    }
    return serialize_headers(buff, h...);
}


template <typename T = Header &, typename... H>
size_t hdr_size(T &hdr1, H&...h) {
    size_t hdr1_size = hdr1.is_valid() ? hdr1.get_nbytes_packet() : 0;
    return hdr1_size + hdr_size(h...);
}

/** For use in with variadic externs, accepts a variable number of headers to serialize */
template <typename T = Header&, typename... H>
u_char *serialize_with_headers(const Packet &packet, size_t &size, H&... h) {
    size_t payload_size = packet.get_data_size();
    size = payload_size + hdr_size(h...);
    u_char *buff = new u_char[size];
    char *payload = serialize_headers((char*)buff, h...);
    memcpy(payload, packet.data(), payload_size);
    return buff;
}

u_char *serialize_with_headers(const Packet &packet, size_t &size, std::vector<Header *>hdrs);

void deserialize_with_headers(Packet &packet,  u_char *buff, std::vector<Header *>hdrs);

void get_valid_headers(Packet &packet, std::vector<Header *>&hdrs);

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


template <typename T = Header &, typename ... H>
void replace_header(PHV *phv, char *buff, T &hdr1, H &...h) {
    if (hdr1.is_valid()) {
        hdr1.extract(buff, *phv);
        buff += hdr1.get_nbytes_packet();
    }
    replace_header(phv, buff, h...);
}

template <typename... Hdrs>
void replace_headers(Packet &packet, u_char *buff, Header &h1, Hdrs& ... h) {
    PHV *phv = packet.get_phv();
    char *hdr_buff = (char *)buff;
    replace_header(phv, hdr_buff, h1, h...);
    delete[] buff;
}

void replace_headers(Packet &packet, u_char *buff, std::vector<Header *>hdrs);

template <typename T>
T get_field_by_name(const Header &hdr, const std::string field_name) {
    int offset = hdr.get_header_type().get_field_offset(field_name);
    return hdr.get_field(offset).get<T>();
}

} // namespace boosters
#endif // BOOSTER_PRIMITIVES_HPP_
