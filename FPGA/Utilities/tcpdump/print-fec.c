#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include "netdissect-stdinc.h"

#include <stdio.h>
#include <stdlib.h>

#include "netdissect.h"
#include "extract.h"

#define PARITY_MASK (0x80)

#define PACKET_TYPE_OFFSET  (0)
#define BLOCK_INDEX_OFFSET  (0)
#define PACKET_INDEX_OFFSET (1)
#define PAYLOAD_OFFSET      (2)

void
fec_print(netdissect_options *ndo, const u_char *pptr, u_int len)
{
	if (pptr[PACKET_TYPE_OFFSET] & PARITY_MASK)
		ND_PRINT("FEC Parity");
	else
		ND_PRINT("FEC Data");
	ND_PRINT(", block %u", pptr[BLOCK_INDEX_OFFSET]);
	ND_PRINT(", packet %u", pptr[PACKET_INDEX_OFFSET]);
	ND_PRINT(", length: %u", len);
	ND_PRINT(", contents:");
	if (!ndo->ndo_Xflag && !ndo->ndo_xflag && !ndo->ndo_Aflag)
		hex_and_ascii_print(ndo, "\n\t", pptr + PAYLOAD_OFFSET, len);
}
