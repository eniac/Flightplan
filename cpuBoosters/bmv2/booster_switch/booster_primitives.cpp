#include "booster_primitives.hpp"

#ifdef FEC_BOOSTER
#include "fec_booster_primitives.h"
#endif

#ifdef MEMCACHED_BOOSTER
#include "memcached_booster_primitives.h"
#endif

void boosters::import_booster_externs(SimpleSwitch *sswitch) {
#ifdef FEC_BOOSTER
    import_fec_booster_primitives(sswitch);
#endif
#ifdef MEMCACHED_BOOSTER
    import_memcached_booster_primitives(sswitch);
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


