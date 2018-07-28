#include "fecBooster.h"
#include "fecEncodeBooster.hpp"
#include <chrono>
#include <mutex>

static void encode_and_forward(tclass_type tclass, forward_fn_t forward,
                               int block_id, int k, int h) {
    size_t template_size = sizeof(struct ether_header);
    u_char template_packet[template_size];

    size_t empty_size = WHARF_TAG_SIZE;
    u_char empty_packet[empty_size];
    for (int i=0; i < k; i++) {
        if (!pkt_already_inserted(tclass, block_id, i)) {
            // Already advances packet index
            wharf_tag_data(tclass, template_packet, template_size, empty_packet, &empty_size);
            LOG_INFO("Forwarding empty packet size %zu", empty_size);
            forward(empty_packet, empty_size);
            insert_into_pkt_buffer(tclass, block_id, i, template_size, template_packet);
        }
    }

    populate_fec_blk_data(tclass, block_id);
    encode_block();

    size_t parity_size;
    for (int i = k; i < (k + h); i++) {
        u_char *parity_pkt = retrieve_encoded_packet(tclass, i, &parity_size);
        size_t tagged_size = parity_size + WHARF_TAG_SIZE;
        u_char tagged_pkt[tagged_size];

        wharf_tag_parity(tclass, block_id, i,
                         parity_pkt, parity_size,
                         tagged_pkt, &tagged_size);

        LOG_INFO("Forwarding parity packet with size %zd", tagged_size);
        forward(tagged_pkt, tagged_size);
    }
}

using std::chrono::steady_clock;

static steady_clock::time_point timeouts[TCLASS_MAX + 1];

static steady_clock::time_point zero_time = timeouts[0];

static std::mutex encoder_mutex;

void fec_encode_timeout_handler(forward_fn_t forward) {
    // Lock encoding while checking timeouts
    std::lock_guard<std::mutex> lock(encoder_mutex);

    LOG_INFO("Timeout handler called!");
    for (int tclass = 0; tclass <= TCLASS_MAX; tclass++) {
        if (timeouts[tclass] != zero_time && timeouts[tclass] < steady_clock::now()) {
            LOG_INFO("Timeout reached for class %d", tclass);
            timeouts[tclass] = zero_time;
            int block_id = get_fec_block_id(tclass);
            fec_sym k, h;
            get_fec_params(tclass, &k, &h);
            encode_and_forward(tclass, forward, block_id, k, h);
            mark_pkts_absent(tclass, block_id);
            // Packet index advanced in encode_and_forward, so no need to advance block idx here
            // advance_block_id(tclass);
        }
    }
    LOG_INFO("End timeout handler");
}

void fec_encode_p4_packet(const u_char *pkt, size_t pkt_size,
                          const struct fec_header *fec,
                          int k, int h, int t,
                          forward_fn_t forward) {
    // Lock while encoding in progress
    std::lock_guard<std::mutex> lock(encoder_mutex);

    LOG_INFO("Fec_encode called for packet %d: %d.%d",
             (int)fec->class_id, (int)fec->block_id, (int)fec->index);

    tclass_type tclass = fec->class_id;

    // TODO: This shouldn't have to be done every time this is called
    set_fec_params(tclass, k, h);

    LOG_INFO("Inserting pkt of tclass %d size %zu into buffer", (int)tclass, pkt_size);
    insert_into_pkt_buffer(tclass, fec->block_id, fec->index, pkt_size, pkt);

    // If advancing the packet index starts a new block
    int new_idx = advance_packet_idx(tclass);
    if (new_idx == 0) {
        LOG_INFO("Encoding and forwarding block");
        encode_and_forward(tclass, forward, fec->block_id, k, h);
    } else if (new_idx == 1) {
        LOG_INFO("Resetting tclass %d timer", tclass);
        timeouts[tclass] = steady_clock::now() + std::chrono::milliseconds(t);
    }
}
