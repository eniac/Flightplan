#ifndef BOOSTER_PRIMITIVES_HPP_
#define BOOSTER_PRIMITIVES_HPP_

#include <bm/bm_sim/phv.h>
#include <bm/bm_sim/packet.h>

namespace boosters {

using bm::PHV;
using bm::Header;
using bm::Packet;

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

u_char *serialize_with_headers(const Packet &packet, size_t &size, std::vector<Header *>hdrs) {
    size_t payload_size = packet.get_data_size();
    size = payload_size;
    for (auto hdr : hdrs) {
        size += hdr->get_nbytes_packet();
    }
    u_char *buff = new u_char[size];
    char *hdr_buff = (char*)buff;
    for (auto hdr : hdrs) {
        hdr->deparse(hdr_buff);
        hdr_buff += hdr->get_nbytes_packet();
    }
    memcpy(hdr_buff, packet.data(), payload_size);
    return buff;
}

void get_valid_headers(Packet &packet, std::vector<Header *>&hdrs) {
    PHV *phv = packet.get_phv();
    std::map<bm::header_type_id_t, Header *> ids;
    for (auto it = phv->header_begin(); it != phv->header_end(); it++) {
        Header &hdr = *it;
        auto &type = hdr.get_header_type();
        auto id = type.get_type_id();

        auto id_it = ids.find(id);
        if (id_it != ids.end()) {
            if (!hdr.is_valid()) {
                BMLOG_DEBUG("Removing {} from valid", hdr.get_name());
                ids.erase(id_it);
            } else {
                BMLOG_DEBUG("Duplicate ok hdr: {}", hdr.get_name());
                // Need to take the second copy of the header!
                ids[id] = &hdr;
            }
        } else {
            if (hdr.is_valid() && !hdr.is_metadata()) {
                BMLOG_DEBUG("Hdr {} is valid", hdr.get_name());
                ids[id] = &hdr;
            }
        }
    }
    for (auto id_it : ids) {
        hdrs.push_back(id_it.second);
    }
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

template <typename... Hdrs>
void replace_headers(Packet &packet, u_char *buff, Header &h1, Hdrs& ... h) {
    PHV *phv = packet.get_phv();
    char *hdr_buff = (char *)buff;
    replace_header(phv, hdr_buff, h1, h...);
    delete[] buff;
}

void replace_headers(Packet &packet, u_char *buff, std::vector<Header *>hdrs) {
    PHV *phv = packet.get_phv();
    char *hdr_buff = (char*)buff;
    for (auto hdr : hdrs) {
        hdr->extract(hdr_buff, *phv);
        hdr_buff += hdr->get_nbytes_packet();
    }
    delete[] buff;
}

template <typename T>
T get_field_by_name(const Header &hdr, const std::string field_name) {
    int offset = hdr.get_header_type().get_field_offset(field_name);
    return hdr.get_field(offset).get<T>();
}

} // namespace boosters
#endif // BOOSTER_PRIMITIVES_HPP_
