#ifndef BOOSTER_PRIMITIVES_HPP_
#define BOOSTER_PRIMITIVES_HPP_

#include <bm/bm_sim/phv.h>
#include <bm/bm_sim/packet.h>
#include <bm/bm_sim/logger.h>

#ifdef FEC_BOOSTER
#include "rse.h"
#endif

namespace boosters {

void init_boosters();

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
