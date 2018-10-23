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

        // Must save packet state so it can be restored after deparsing
        const auto packet_in_state = packet.save_buffer_state();

        auto deparser = get_p4objects()->get_deparser("deparser");
        deparser->deparse(&packet);

        char *buff = packet.data();
        size_t buff_size = packet.get_data_size();

        auto forwarder = [&](char *payload, size_t len, int reverse) {
            int new_ingress = reverse == 0 ? ingress_port : egress_port;
            int new_egress = reverse == 0 ? egress_port : ingress_port;
            generate_packet(payload, len, new_ingress, new_egress);
        };

        bool drop = call_memcached((char*)buff, buff_size, forwarder);

        packet.restore_buffer_state(packet_in_state);

        if (drop) {
            forward_d.set(true);
        } else {
            forward_d.set(false);
        }
       /* for (auto hdr : hdrs) {
            boosters::printHeader(*hdr);
        }*/

    }
};

void import_memcached_booster_primitives(SimpleSwitch *sswitch) {
  REGISTER_BOOSTER_EXTERN(memcached, sswitch);
}


