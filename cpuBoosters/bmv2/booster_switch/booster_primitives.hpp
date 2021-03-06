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

using bm::PHV;
using bm::Header;
using bm::Packet;
using bm::Field;
using bm::P4Objects;


void printHeader(const Header &hdr);

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
        booster_pkt->entry_node = input.current_node;
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

    const Packet::buffer_state_t deparse_packet() {
        Packet::buffer_state_t state = this->get_packet().save_buffer_state();
        auto deparser = this->get_p4objects()->get_deparser("deparser");
        deparser->deparse(&this->get_packet());
        return state;
    }

    void reparse_packet(const Packet::buffer_state_t state) {
        this->get_packet().restore_buffer_state(state);
    }

    bool is_generated() {
        return this->pkt->entry_node == this->pkt->current_node;
    }

public:
    BoosterExtern(SimpleSwitch *sswitch) : sswitch{sswitch} {}

};

void import_booster_externs(SimpleSwitch *sswitch);

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
} // namespace boosters
#endif // BOOSTER_PRIMITIVES_HPP_
