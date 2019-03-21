#include "booster_primitives.hpp"
#include "simple_switch.h"
#include "compressor.h"
#include <bm/bm_sim/actions.h>
#include <bm/bm_sim/data.h>
#include <bm/bm_sim/packet.h>

using bm::Data;
using bm::Packet;
using bm::Header;

class header_compress : public boosters::BoosterExtern<Data &> {
    using BoosterExtern::BoosterExtern;

    void operator ()(Data &forward_d) {
        if (is_generated()) {
            forward_d.set(true);
            return;
        }

        Packet  &packet = this->get_packet();
        int ingress_port = packet.get_ingress_port();

        // Must save packet state so it can be restored after deparsing
        const Packet::buffer_state_t packet_in_state = packet.save_buffer_state();

        // Deparsing the packet makes the headers readable in packet.data()
        auto deparser = get_p4objects()->get_deparser("deparser");
        deparser->deparse(&packet);

        char *buff = packet.data();
        size_t buff_size = packet.get_data_size();
        bool no_forward = true;

        auto forwarder = [&](const u_char *payload, size_t len) {
            BMLOG_DEBUG("Generating new packet");
            no_forward = false;
            generate_packet((const char *)payload, len, ingress_port);
        };

        BMLOG_DEBUG("Compressing packet...");
        compress((u_char*)buff, buff_size, forwarder);

        packet.restore_buffer_state(packet_in_state);

        // Drop the packet if another was forwarded
        forward_d.set(no_forward);
    }
};

class header_decompress : public boosters::BoosterExtern<Data &> {
    using BoosterExtern::BoosterExtern;

    void operator ()(Data &forward_d) {
        if (is_generated()) {
            forward_d.set(true);
            return;
        }

        Packet  &packet = this->get_packet();
        int ingress_port = packet.get_ingress_port();

        // Must save packet state so it can be restored after deparsing
        const Packet::buffer_state_t packet_in_state = packet.save_buffer_state();

        // Deparsing the packet makes the headers readable in packet.data()
        auto deparser = get_p4objects()->get_deparser("deparser");
        deparser->deparse(&packet);

        char *buff = packet.data();
        size_t buff_size = packet.get_data_size();
        bool no_forward = true;

        auto forwarder = [&](const u_char *payload, size_t len) {
            no_forward = false;
            BMLOG_DEBUG("Generating new packet");
            generate_packet((const char *)payload, len, ingress_port);
        };

        BMLOG_DEBUG("Decompressing packet...");
        decompress((u_char*)buff, buff_size, forwarder);

        packet.restore_buffer_state(packet_in_state);

        // Drop the packet if nothing was forwarded
        forward_d.set(no_forward);
    }
};

int import_compression_booster_primitives(SimpleSwitch *sswitch) {
    REGISTER_BOOSTER_EXTERN(header_compress, sswitch);
    REGISTER_BOOSTER_EXTERN(header_decompress, sswitch);
    return 0;
}
