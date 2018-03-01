/*
 * RSE.H
 */

#ifndef _FEC_H
#define _FEC_H

#include "Configuration.h"

#include <stdio.h>
#include <sys/time.h>
#include <assert.h>
#include <string.h>
/***************************************************************************/
/* Run Option Control (to stderr)                                        */
/***************************************************************************/

//#define  FEC_MAC_LOOKUP                 /* use gf lookup table in FEC_MAC */

#define     MAX_PRINT_COLUMNS   18      /* Max columns printed in tables */
//#define     FEC_DBG_LEVEL_1
//#define     FEC_DBG_LEVEL_2             /* print major events */
//#define     FEC_DBG_LEVEL_3             /* Print Encoding and Decoding Steps */
//#define     FEC_DBG_PRINT_TABLES        /* print math tables */
//#define     FEC_DBG_PRINT_WEIGHTS       /* print RS fec_weights (on init) */
//#define     FEC_DBG_PRINT_TRANS         /* print matrix transform (to 3 rows) */

//#define     FEC_SPEED_TEST

/***************************************************************************/
/* FEC Packet Definitions                                                  */
/***************************************************************************/

//#define     FEC_M           3               /* symbol size (SMALL TEST) */
#define     FEC_M           8               /* symbol size (default) */
//#define     FEC_M           16              /* symbol size (BIG) */
#define     FEC_N           (1 << FEC_M)    /* 2^m = Max symbol value + 1 */
#define     FEC_MAX_COLS	10000           /* Max symbols in one packet */
#define     FEC_EXTRA_COLS	1               /* Extra Parity symbols to code length */

/***************************************************************************/
/* Codeword Definition (using m-bit symbols defined for FEC packet)        */
/***************************************************************************/

#define     FEC_MAX_N       (FEC_MAX_K + FEC_MAX_H)        /* Max packets in FEC block (< FEC_N) */
//#define     FEC_MAX_H       4                        /* MAX h parities */
//#define     FEC_MAX_K       (FEC_MAX_N - FEC_MAX_H)  /* MAX K data packets */

/***************************************************************************/
/* FEC Block Definitions                                                   */
/***************************************************************************/
//typedef unsigned short  fec_sym;            /* 16 bit symbol */
typedef unsigned char	fec_sym;            /* 8 bit symbol */
typedef fec_sym (*fec_blk)[FEC_MAX_COLS];	/* packet structure of C columns */

/* Information about an FEC Block */
/* Packet Storage in rsetest.c is contiguous ([K+H] by [FEC_MAX_COLS] matrix) */
/* but, in general, need not be (so pass as pointers) */
struct fec_block {
    fec_sym    block_C;                     /* Symbols in biggest (parity) packet */
    fec_sym    block_N;                     /* Actual number of packets in FEC block */
    fec_sym    *pdata[FEC_N-1];             /* ptrs to each possible packet in FEC block */
    fec_sym    cbi[FEC_N-1];                /* Code-Block Index (0 to FEC_N-2) */
    int        plen[FEC_N-1];               /* Packet length: number of symbols */
    char       pstat[FEC_N-1];              /* Packet stauts flag: known, wanted, ... */
    fec_sym    d[FEC_MAX_K+1][FEC_MAX_H+1]; /* Duplicate Matrix (generated each symbol) */
    fec_sym    e[FEC_MAX_K+1][FEC_MAX_H+1]; /* Equation Matrix (once per FEC Block) */
};

struct fec_block fb;                        /* Globally defined FEC block */

/** packet status flags **/

#define		FEC_FLAG_KNOWN      0           /* data packet status: Known */
#define		FEC_FLAG_WANTED     1           /* data packet status: Wanted */
#define		FEC_FLAG_IGNORE     2           /* data packet status: Not Want */

/***************************************************************************/
/* Error codes                                                             */
/***************************************************************************/

#define     FEC_ERR_INVALID_PARAMS         -1
#define     FEC_ERR_ENC_MISSING_DATA       -20
#define     FEC_ERR_MOD_NOT_FOUND          4
#define     FEC_ERR_TRANS_FAILED           82

/***************************************************************************/
/* Function prototypes                                                     */
/***************************************************************************/

int  rse_code(int);
int  rse_init(void);
void fec_block_print(void);
void fec_block_delete(int *);
unsigned long fec_get_time_delta(int);

#endif    //_FEC_H
