#include "booster_primitives.hpp"
#include "memcached.h"
#include "simple_switch.h"

#include <bm/bm_sim/actions.h>
#include <bm/bm_sim/data.h>
#include <bm/bm_sim/packet.h>

template <typename... Args>
using ActionPrimitive = bm::ActionPrimitive<Args...>;
using bm::Data;
using bm::Packet;
using bm::Header;


class memcached : public ActionPrimitive<Data &> {
    void operator ()(Data &forward_d) {
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
            SimpleSwitch::get_instance()->output_booster_packet(reverse == 0 ? egress_port : ingress_port, (u_char*)payload, len);
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

REGISTER_PRIMITIVE(memcached);

// dummy function, which ensures that this unit is not discarded by the linker
// it is being called by the constructor of SimpleSwitch
// the previous alternative was to have all the primitives in a header file (the
// primitives could also be placed in simple_switch.cpp directly), but I need
// this dummy function if I want to keep the primitives in their own file
int import_memcached_booster_primitives() {
  return 0;
}


