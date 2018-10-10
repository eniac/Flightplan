#include "booster_primitives.hpp"
#include "memcached.h"
#include "simple_switch.h"

#include <bm/bm_sim/actions.h>
#include <bm/bm_sim/data.h>
#include <bm/bm_sim/packet.h>

using bm::Data;
using bm::Packet;
using bm::Header;


class memcached : public boosters::BoosterExtern<Data &> {
    using BoosterExtern::BoosterExtern;

    void operator ()(Data &forward_d) {
        // Unused...
        (void)forward_d;

        Packet &packet = this->get_packet();
        int egress_port = phv->get_field("standard_metadata.egress_spec").get_int();
        int ingress_port = phv->get_field("standard_metadata.ingress_port").get_int();

        std::vector<Header *>hdrs;
        boosters::get_valid_headers(packet, hdrs);

        for (auto hdr : hdrs) {
            boosters::printHeader(*hdr);
        }

        size_t buff_size;
        u_char *buff = boosters::serialize_with_headers(packet, buff_size, hdrs);

        auto forwarder = [&](char *payload, size_t len, int reverse) {
            BMLOG_DEBUG("Reverse is {}, sending to port {}", reverse, reverse==0 ? egress_port : ingress_port);
            output_new_packet(reverse == 0 ? egress_port : ingress_port, payload, len);
        };

        bool drop = call_memcached((char*)buff, buff_size, forwarder);

        if (drop) {
            get_field("standard_metadata.egress_spec").set(511);
            if (get_phv().has_field("intrinsic_metadata.mcast_grp")) {
                get_field("intrinsic_metadata.mcast_grp").set(0);
            }
        }
       /* for (auto hdr : hdrs) {
            boosters::printHeader(*hdr);
        }*/

    }
};

void import_memcached_booster_primitives(SimpleSwitch *sswitch) {
  REGISTER_BOOSTER_EXTERN(memcached, sswitch);
}


