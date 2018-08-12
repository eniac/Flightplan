#include "booster_primitives.hpp"

using namespace boosters;

void boosters::init_boosters() {
#ifdef FEC_BOOSTER
    if (rse_init() != 0) {
        printf("ERROR Initializing RSE\n");
        exit(-1);
    }
#endif
}

/** TODO IMP: static functions should go in .cpp rather than defining as static in headers */
void boosters::printHeader(const Header &hdr) {
    auto &type = hdr.get_header_type();
    bool meta = hdr.is_metadata();

    for (int i=0; i < hdr.get_header_type().get_num_fields(); i++) {
        std::string name = hdr.get_field_name(i);
        const Field &field = hdr.get_field(i);
        BMLOG_DEBUG("Hdr {}) name {}, valid {}, hidden {}, meta {}",
                    i, name, hdr.is_valid(), type.get_finfo(i).is_hidden, meta);
        int nbits = field.get_nbits();
        if (field.get_arith_flag()) {
            std::stringstream ss;
            ss << std::setw((nbits + 3) / 4) << std::setfill('0') << std::hex << field.get_uint64();
            std::string hexstr = ss.str();;
            BMLOG_DEBUG("Hex: {}", hexstr);
        } else {
            BMLOG_DEBUG("Arith flag off...");
        }
    }
}

// Necessary for variadic template expansion
char *boosters::serialize_headers(char *buff) { return buff; }
size_t boosters::hdr_size() { return 0; }
void boosters::replace_header(PHV *, char *){}


u_char *boosters::serialize_with_headers(const Packet &packet, size_t &size, std::vector<Header *>hdrs) {
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

void boosters::deserialize_with_headers(Packet &packet,  u_char *buff, std::vector<Header *>hdrs) {
    size_t payload_size = packet.get_data_size();
    PHV *phv = packet.get_phv();
    char *hdr_buff = (char*)buff;
    for (auto hdr : hdrs) {
        hdr->extract(hdr_buff, *phv);
        hdr_buff += hdr->get_nbytes_packet();
    }

    memcpy(packet.data(), hdr_buff, payload_size);
    delete[] buff;
}
  

void boosters::get_valid_headers(Packet &packet, std::vector<Header *>&hdrs) {
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

void boosters::replace_headers(Packet &packet, u_char *buff, std::vector<Header *>hdrs) {
    PHV *phv = packet.get_phv();
    char *hdr_buff = (char*)buff;
    for (auto hdr : hdrs) {
        hdr->extract(hdr_buff, *phv);
        hdr_buff += hdr->get_nbytes_packet();
    }
    delete[] buff;
}


