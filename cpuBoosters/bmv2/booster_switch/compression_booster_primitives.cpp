#include "booster_primitives.hpp"
#include "simple_switch.h"
#include "compressor.h"
#include <bm/bm_sim/actions.h>
#include <bm/bm_sim/data.h>
#include <bm/bm_sim/packet.h>

using bm::Data;
using bm::Packet;
using bm::Header;

template <typename... Args>
using BoosterExtern = boosters::BoosterExtern<Args...>;

template <typename ...Args>
class header_compress_core : public BoosterExtern<Data &, Args...> {
    // Inherit constructor
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

        Packet  &packet = this->get_packet();
        int ingress_port = packet.get_ingress_port();

        if (fp_h != nullptr)
            fp_h->mark_invalid();
        // Must save packet state so it can be restored after deparsing
        const Packet::buffer_state_t packet_in_state = this->deparse_packet();

        char *buff = packet.data();
        size_t buff_size = packet.get_data_size();
        bool no_forward = true;

        auto forwarder = [&](const u_char *payload, size_t len) {
            if (buff_size == len && memcmp((char*)payload, buff, len) == 0) {
                BMLOG_DEBUG("Packet unchanged, not generating anew");
                return;
            } else {
                no_forward = false;
                BMLOG_DEBUG("Generating new packet (orig len:{}, new len:{}", buff_size, len);
                this->generate_packet((const char *)payload, len, ingress_port);
            }
        };

        BMLOG_DEBUG("Compressing packet...");
        compress((u_char*)buff, buff_size, forwarder);

        this->reparse_packet(packet_in_state);

        // Drop the packet if another was forwarded
        forward_d.set(no_forward);
        if (fp_h != nullptr)
            fp_h->mark_valid();
    }
};

class header_compress : public header_compress_core<> {
    // Inherit constructor
    using header_compress_core::header_compress_core;

    void operator ()(Data &forward_d) {
        core(forward_d, nullptr);
    }
};

class header_compress_fp : public header_compress_core<Header &> {
    // Inherit constructor
    using header_compress_core::header_compress_core;

    void operator ()(Data &forward_d, Header &fp_h) {
        core(forward_d, &fp_h);
    }
};

template <typename ...Args>
class header_decompress_core : public BoosterExtern<Data &, Args...> {
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

        Packet  &packet = this->get_packet();
        int ingress_port = packet.get_ingress_port();

        if (fp_h != nullptr)
            fp_h->mark_invalid();
        // Deparsing the packet makes the headers readable in packet.data()
        const Packet::buffer_state_t packet_in_state = this->deparse_packet();

        char *buff = packet.data();
        size_t buff_size = packet.get_data_size();
        bool no_forward = true;

        auto forwarder = [&](const u_char *payload, size_t len) {
            if (buff_size == len && memcmp((char*)payload, buff, len) == 0) {
                BMLOG_DEBUG("Packet unchanged, not generating anew");
                return;
            } else {
                no_forward = false;
                BMLOG_DEBUG("Generating new packet (orig len:{}, new len:{}", buff_size, len);
                this->generate_packet((const char *)payload, len, ingress_port);
            }
        };

        BMLOG_DEBUG("Decompressing packet...");
        decompress((u_char*)buff, buff_size, forwarder);

        packet.restore_buffer_state(packet_in_state);

        this->reparse_packet(packet_in_state);
        if (fp_h != nullptr)
            fp_h->mark_valid();
        // Drop the packet if nothing was forwarded
        forward_d.set(no_forward);
    }
};

class header_decompress : public header_decompress_core<> {
    // Inherit constructor
    using header_decompress_core::header_decompress_core;

    void operator ()(Data &forward_d) {
        core(forward_d, nullptr);
    }
};

class header_decompress_fp : public header_decompress_core<Header &> {
    // Inherit constructor
    using header_decompress_core::header_decompress_core;

    void operator ()(Data &forward_d, Header &fp_h) {
        core(forward_d, &fp_h);
    }
};

int import_compression_booster_primitives(SimpleSwitch *sswitch) {
    REGISTER_BOOSTER_EXTERN(header_compress, sswitch);
    REGISTER_BOOSTER_EXTERN(header_compress_fp, sswitch);
    REGISTER_BOOSTER_EXTERN(header_decompress, sswitch);
    REGISTER_BOOSTER_EXTERN(header_decompress_fp, sswitch);
    return 0;
}
