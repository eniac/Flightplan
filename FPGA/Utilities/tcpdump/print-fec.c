#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include "netdissect-stdinc.h"

#include <stdio.h>
#include <stdlib.h>

#include "netdissect.h"
#include "extract.h"

#include "../../RSEConfig/Configuration.h"

#define TRAFFIC_CLASS_OFFSET (0)
#define BLOCK_INDEX_OFFSET   (TRAFFIC_CLASS_OFFSET + FEC_TRAFFIC_CLASS_WIDTH)
#define PACKET_INDEX_OFFSET  (BLOCK_INDEX_OFFSET + FEC_BLOCK_INDEX_WIDTH)
#define ORIGINAL_TYPE_OFFSET (PACKET_INDEX_OFFSET + FEC_PACKET_INDEX_WIDTH)
#define PACKET_LENGTH_OFFSET (ORIGINAL_TYPE_OFFSET + FEC_ETHER_TYPE_WIDTH)
#define PAYLOAD_OFFSET       (PACKET_LENGTH_OFFSET + FEC_PACKET_LENGTH_WIDTH)

static int read_field(const u_char * packet, int offset, int width)
{
	int start = (offset + 7) / 8;
	int end = (offset + width - 1 + 7) / 8;
	int value = 0;
	for (int i = start; i <= end; i++)
		value = (value << 8) | packet[i];
	int length = 8 * (end - start + 1);
	int mask = (1 << (length - start)) - 1;
	mask -= (1 << (length - start - width)) - 1;
	return value & mask;
}

static int k_list[] = {5, 50, 50};
static int h_list[] = {1, 1, 5};

void
fec_print(netdissect_options *ndo, const u_char *pptr, u_int len)
{
	int traffic_class = read_field(pptr, TRAFFIC_CLASS_OFFSET, FEC_TRAFFIC_CLASS_WIDTH);
	int block_index = read_field(pptr, BLOCK_INDEX_OFFSET, FEC_BLOCK_INDEX_WIDTH);
	int packet_index = read_field(pptr, PACKET_INDEX_OFFSET, FEC_PACKET_INDEX_WIDTH);
	int original_type = read_field(pptr, ORIGINAL_TYPE_OFFSET, FEC_ETHER_TYPE_WIDTH);
	int packet_length = read_field(pptr, PACKET_LENGTH_OFFSET, FEC_PACKET_LENGTH_WIDTH);

	int k = k_list[traffic_class];
	int h = h_list[traffic_class];

	if (packet_index >= k)
		ND_PRINT("FEC Parity");
	else
		ND_PRINT("FEC Data");

	ND_PRINT(", traffic class %u", traffic_class);
	ND_PRINT(", block %u", block_index);
	ND_PRINT(", packet %u", packet_index);
	ND_PRINT(", original type: %u", original_type);
	ND_PRINT(", encoded length: %u", packet_length);
	ND_PRINT(", contents:");
	if (!ndo->ndo_Xflag && !ndo->ndo_xflag && !ndo->ndo_Aflag)
		hex_and_ascii_print(ndo, "\n\t", pptr + PAYLOAD_OFFSET, len);
}
