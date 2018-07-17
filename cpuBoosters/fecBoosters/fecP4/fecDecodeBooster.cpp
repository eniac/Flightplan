#include "fecBooster.h"
#include "fecDecodeBooster.hpp"

/**
 * Each class of traffic has some decoding state that needs to be maintained
 */
struct tclass_state {
    bool empty;
	int block_id;
	int packet_idx;
	/** After each second, this value is decremented. If it == 0, block is forwarded */
};

static struct tclass_state tclasses[TCLASS_MAX + 1];

static void reset_decoder(tclass_type tclass, int block_id) {
    tclasses[tclass].empty = true;
    mark_pkts_absent(tclass, block_id);
}

static void decode_and_forward(tclass_type tclass, forward_fn_t forward,
                               int block_id, int k, int h) {
    if (tclasses[tclass].empty || is_all_data_pkts_recieved_for_block(tclass, block_id)) {
        reset_decoder(tclass, block_id);
        LOG_INFO("All data packets received for %d:%d. Skipping decode",
                 (int)tclass, block_id);
        return;
    }

    populate_fec_blk_data_and_parity(tclass, block_id);
    decode_block(tclass, block_id);

    int num_recovered = 0;
    for (int i=0; i < k; i++) {
        if (pkt_recovered(tclass, block_id, i)) {
            num_recovered += 1;

            FRAME_SIZE_TYPE size;
            u_char *pkt = retrieve_from_pkt_buffer(tclass, block_id, i, &size);

            if (size > 0) {
                LOG_INFO("Forwarding packet of size %d", (int)size);
                forward(pkt, size);
            }
        }
    }

    LOG_INFO("Recovered %d packets", num_recovered);

    reset_decoder(tclass, block_id);
}

void fec_decode_p4_packet(const u_char *pkt, size_t pkt_size,
                          const struct fec_header *fec,
                          int k, int h,
                          forward_fn_t forward) {
    LOG_INFO("Fec_decode called for packet %d: %d.%d",
             (int)fec->class_id, (int)fec->block_id, (int)fec->index);

    tclass_type tclass = fec->class_id;

    // TODO: This shouldn't have to be done every time this is called
    set_fec_params(tclass, k, h);

    if (fec->index >= k) {
        pkt += sizeof(struct ether_header);
        pkt_size -= sizeof(struct ether_header);
    }

    LOG_INFO("Inserting pkt of tclass %d size %zu into buffer",(int)tclass, pkt_size);
    if (!pkt_already_inserted(tclass, fec->block_id, fec->index)) {
        insert_into_pkt_buffer(tclass, fec->block_id, fec->index, pkt_size, pkt);
        tclasses[tclass].empty = false;
    } else {
        LOG_ERR("Received duplicate packet! Not buffering");
    }


    if (fec->block_id != tclasses[tclass].block_id ||
            fec->index < tclasses[tclass].packet_idx ||
            fec->index == (k + h - 1)) {
        decode_and_forward(tclass, forward, tclasses[tclass].block_id, k, h);
        if (fec->index == (k + h - 1)) {
            tclasses[tclass].block_id = (fec->block_id + 1) % MAX_BLOCK;
            tclasses[tclass].packet_idx = 0;
        } else {
            tclasses[tclass].block_id = fec->block_id;
            tclasses[tclass].packet_idx = fec->index;
        }
    } else {
        tclasses[tclass].packet_idx = fec->index;
    }
}

