#include "fecBooster.h"
#include "fecDecodeBooster.hpp"

/**
 * Each class of traffic has some decoding state that needs to be maintained
 */
struct tclass_state {
    bool empty;
    int block_id;
    int packet_idx;
    bool forwarded;
};

static struct tclass_state tclasses[TCLASS_MAX + 1][MAX_PORT + 1];

static void reset_decoder(tclass_type tclass, int ingress_port, int block_id) {
    tclasses[tclass][ingress_port].empty = true;
    tclasses[tclass][ingress_port].forwarded = true;
    mark_pkts_absent(tclass, ingress_port, block_id);
}

static void decode_and_forward(tclass_type tclass, int ingress_port, decode_forward_fn forward,
                               int block_id, int k, int h) {
    if (tclasses[tclass][ingress_port].empty ||
            is_all_data_pkts_recieved_for_block(tclass, ingress_port, block_id)) {
        reset_decoder(tclass, ingress_port, block_id);
        LOG_INFO("All data packets received for %d:%d. Skipping decode",
                 (int)tclass, block_id);
        return;
    }

    populate_fec_blk_data_and_parity(tclass, ingress_port, block_id);
    decode_block(tclass, ingress_port, block_id);

    int num_recovered = 0;
    for (int i=0; i < k; i++) {
        if (pkt_recovered(tclass, ingress_port, block_id, i)) {
            num_recovered += 1;

            FRAME_SIZE_TYPE size;
            u_char *pkt = retrieve_from_pkt_buffer(tclass, ingress_port, block_id, i, &size);

            if (size > sizeof(struct ether_header)) {
                LOG_INFO("Forwarding packet of size %d", (int)size);
                forward(pkt, size);
            }
        }
    }

    LOG_INFO("Recovered %d packets", num_recovered);

    reset_decoder(tclass, ingress_port, block_id);
}

void fec_decode_p4_packet(const u_char *pkt,
                          const struct fec_header *fec, int ingress_port,
                          int k, int h,
                          decode_forward_fn forward, drop_fn_t drop) {
    size_t pkt_size = fec->packet_len;

    LOG_INFO("Fec_decode called for packet %d: %d.%d",
             (int)fec->class_id, (int)fec->block_id, (int)fec->index);

    tclass_type tclass = fec->class_id;

    // If it's the start of a new block, mark that it hasn't been forwarded yet
    if (fec->block_id != tclasses[tclass][ingress_port].block_id ||
            fec->index <= tclasses[tclass][ingress_port].packet_idx) {
        if (!tclasses[tclass][ingress_port].forwarded) {
            LOG_ERR("Recieved start of next block before forwarding previous block!");
        }
        reset_decoder(tclass, ingress_port, fec->block_id);
        tclasses[tclass][ingress_port].forwarded = false;
    } else if (tclasses[tclass][ingress_port].forwarded) {
        LOG_INFO("Already forwarded. Skipping insertion of packet");
        // Otherwise, if the block is already forwarded, there's nothing to do
        return;
    }

    // TODO: This shouldn't have to be done every time this is called
    set_fec_params(tclass, k, h);

    if (fec->index >= k) {
        pkt += sizeof(struct ether_header);
        pkt_size -= sizeof(struct ether_header);
    }

    LOG_INFO("Inserting pkt of tclass %d size %zu into buffer",(int)tclass, pkt_size);
    if (!pkt_already_inserted(tclass, ingress_port, fec->block_id, fec->index)) {
        insert_into_pkt_buffer(tclass, ingress_port, fec->block_id, fec->index, pkt_size, pkt);
        tclasses[tclass][ingress_port].empty = false;
    } else {
        LOG_ERR("Received duplicate: tclass %d; block %d index %d; ingress %d! Not buffering",
                (int)tclass, (int)fec->block_id, (int)fec->index, ingress_port);
    }

    if (can_decode(tclass, ingress_port, fec->block_id)) {
        decode_and_forward(tclass, ingress_port, forward, fec->block_id, k, h);
    }

    tclasses[tclass][ingress_port].block_id = fec->block_id;
    tclasses[tclass][ingress_port].packet_idx = fec->index;

    if (pkt_size == sizeof(struct ether_header)) {
        LOG_INFO("Empty packet received -- too small to forward");
        drop();
    }
}

