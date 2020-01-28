#include "booster_primitives.hpp"
#include "memcached.h"
#include "simple_switch.h"

#include <bm/bm_sim/actions.h>
#include <bm/bm_sim/data.h>
#include <bm/bm_sim/packet.h>

using bm::Data;
using bm::Packet;
using bm::Header;

template <typename... Args>
using BoosterExtern = boosters::BoosterExtern<Args...>;

template <typename ...Args>
class memcached_core : public BoosterExtern<Data &, Args...> {
    using BoosterExtern<Data &, Args...>::BoosterExtern;

protected:
    void core(Data &forward_d, Header *fp_h) {
        if (this->is_generated()) {
            forward_d.set(true);
            if (fp_h != nullptr) {
                fp_h->mark_valid();
            }
            return;
        }

        Packet &packet = this->get_packet();
        int egress_port = this->phv->get_field("standard_metadata.egress_spec").get_int();
        int ingress_port = this->phv->get_field("standard_metadata.ingress_port").get_int();

        if (fp_h != nullptr)
            fp_h->mark_invalid();

        // Must save packet state so it can be restored after deparsing
        const Packet::buffer_state_t packet_in_state = this->deparse_packet();

        char *buff = packet.data();
        size_t buff_size = packet.get_data_size();

        auto forwarder = [&](char *payload, size_t len, int reverse) {
            int new_ingress = reverse == 0 ? ingress_port : egress_port;
            int new_egress = reverse == 0 ? egress_port : ingress_port;
            this->generate_packet(payload, len, new_ingress, new_egress);
        };

        bool drop = call_memcached((char*)buff, buff_size, forwarder);

        this->reparse_packet(packet_in_state);

        if (drop) {
            forward_d.set(false);
        } else {
            forward_d.set(true);
        }

        // Drop the packet if another was forwarded
        if (fp_h != nullptr)
            fp_h->mark_valid();
    }
};

class memcached : public memcached_core<> {
    // Inherit constructor
    using memcached_core::memcached_core;

    void operator ()(Data &forward_d) {
        core(forward_d, nullptr);
    }
};

class memcached_fp : public memcached_core<Header &> {
    // Inherit constructor
    using memcached_core::memcached_core;

    void operator ()(Data &forward_d, Header &fp_h) {
        core(forward_d, &fp_h);
    }
};

void import_memcached_booster_primitives(SimpleSwitch *sswitch) {
  REGISTER_BOOSTER_EXTERN(memcached, sswitch);
  REGISTER_BOOSTER_EXTERN(memcached_fp, sswitch);
}


