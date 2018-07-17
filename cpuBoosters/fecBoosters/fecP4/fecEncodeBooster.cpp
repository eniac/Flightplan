#include "fecBooster.h"
#include "fecEncodeBooster.hpp"

static void encode_and_forward(tclass_type tclass, forward_fn_t forward,
                               int block_id, int k, int h) {
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

void fec_encode_p4_packet(const u_char *pkt, size_t pkt_size,
                          const struct fec_header *fec,
                          int k, int h,
                          forward_fn_t forward) {
    LOG_INFO("Fec_encode called for packet %d: %d.%d", 
             (int)fec->class_id, (int)fec->block_id, (int)fec->index);

    tclass_type tclass = fec->class_id;

    // TODO: This shouldn't have to be done every time this is called
    set_fec_params(tclass, k, h);

    LOG_INFO("Inserting pkt of tclass %d size %zu into buffer", (int)tclass, pkt_size);
    insert_into_pkt_buffer(tclass, fec->block_id, fec->index, pkt_size, pkt);

    // If advancing the packet index starts a new block
    if (advance_packet_idx(tclass) == 0) {
        LOG_INFO("Encoding and forwarding block");
        encode_and_forward(tclass, forward, fec->block_id, k, h);
    }
}
