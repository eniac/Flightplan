/*
 * RSE.H
 */

#ifndef _FEC_H
#define _FEC_H

#include <assert.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <time.h>
#include <pcap.h>
#include <netinet/in.h>
#include <netinet/if_ether.h>
#include <net/ethernet.h>
#include <errno.h>
#include <string.h>
#include <limits.h>
#include <pthread.h>
#include <arpa/inet.h>
#include <stdbool.h>

/***************************************************************************/
/* Codeword Definition (using m-bit symbols defined for FEC packet)        */
/***************************************************************************/
//#define     FEC_M           3              /* symbol size (SMALL TEST) */
#define     FEC_M           8              /* symbol size (default) */
//#define     FEC_M           16             /* symbol size (Faster?) */

#define     FEC_N           (1 << FEC_M)   /* 2^m = Max symbol value + 1 */
//#define     FEC_MAX_N       350            /* Max packets in FEC block (< FEC_N) */
#define     FEC_MAX_N       (FEC_N-1)      /* Max packets in FEC block (< FEC_N) */
#define     FEC_MAX_H       16             /* MAX h parities (< FEC_MAX_N) */
#define     FEC_MAX_K       (FEC_MAX_N - FEC_MAX_H)  /* MAX k data packets */

/***************************************************************************/
/* FEC Packet Definition (to hold data and additional length info)         */
/***************************************************************************/
#define     FEC_MAX_COLS    10000         /* Max symbols in one packet */
#define     VARIABLE_LENGTH 1             /* Extra symbols to code length? */

/***************************************************************************/
/* Calculate number of columns needed to hold length and symbol type       */
/***************************************************************************/
#if VARIABLE_LENGTH < 1
        #define     FEC_EXTRA_COLS  0
#else
  #if FEC_M < 9
    #if FEC_MAX_COLS < 256
        #define     FEC_EXTRA_COLS  1
    #elif FEC_MAX_COLS < 65536
        #define     FEC_EXTRA_COLS  2
    #else
        #define     FEC_EXTRA_COLS  3
    #endif
  #else
    #if FEC_MAX_COLS < 65536
        #define     FEC_EXTRA_COLS  1
    #else
        #define     FEC_EXTRA_COLS  2
    #endif
  #endif
#endif

#if FEC_M < 9
    typedef unsigned char   fec_sym;            /* 8 bit symbol */
#else
    typedef unsigned short  fec_sym;            /* 16 bit symbol */
#endif

/***************************************************************************/
/* FEC Block Definitions                                                   */
/***************************************************************************/
typedef fec_sym (*fec_blk)[FEC_MAX_COLS];	/* packet structure of C columns */

/* Information about an FEC Block */
/* Packet Storage in rsetest.c is contiguous ([K+H] by [FEC_MAX_COLS] matrix) */
/* but, in general, need not be (so pass as pointers) */
struct fec_block {
    int        block_C;                     /* Number of Symbols in Parity packets */
    fec_sym    block_N;                     /* Actual number of packets in FEC block */
    fec_sym    *pdata[FEC_N-1];             /* ptrs to each possible packet in FEC block */
    fec_sym    cbi[FEC_N-1];                /* Code-Block Index (0 to FEC_N-2) */
    int        plen[FEC_N-1];               /* Packet length: number of symbols */
    char       pstat[FEC_N-1];              /* Packet stauts flag: known, wanted, ... */
};
extern struct fec_block fb;                 /* Declare FEC block fb */

/* TCP header */
typedef u_int tcp_seq;

#define IP_HL(ip)               (((ip)->ip_vhl) & 0x0f)
#define IP_V(ip)                (((ip)->ip_vhl) >> 4)

/* IP header */
struct sniff_ip {
    u_char  ip_vhl;                 /* version << 4 | header length >> 2 */
    u_char  ip_tos;                 /* type of service */
    u_short ip_len;                 /* total length */
    u_short ip_id;                  /* identification */
    u_short ip_off;                 /* fragment offset field */
#define IP_RF 0x8000            /* reserved fragment flag */
#define IP_DF 0x4000            /* dont fragment flag */
#define IP_MF 0x2000            /* more fragments flag */
#define IP_OFFMASK 0x1fff       /* mask for fragmenting bits */
    u_char  ip_ttl;                 /* time to live */
    u_char  ip_p;                   /* protocol */
    u_short ip_sum;                 /* checksum */
    struct  in_addr ip_src, ip_dst; /* source and dest address */
};

/* UDP protocol header. */
struct sniff_udp {
    u_short uh_sport;               /* source port */
    u_short uh_dport;               /* destination port */
    u_short uh_ulen;                /* udp length */
    u_short uh_sum;                 /* udp checksum */
};


struct sniff_tcp {
    u_short th_sport;               /* source port */
    u_short th_dport;               /* destination port */
    tcp_seq th_seq;                 /* sequence number */
    tcp_seq th_ack;                 /* acknowledgement number */
    u_char  th_offx2;               /* data offset, rsvd */
#define TH_OFF(th)      (((th)->th_offx2 & 0xf0) >> 4)
    u_char  th_flags;
#define TH_FIN  0x01
#define TH_SYN  0x02
#define TH_RST  0x04
#define TH_PUSH 0x08
#define TH_ACK  0x10
#define TH_URG  0x20
#define TH_ECE  0x40
#define TH_CWR  0x80
#define TH_FLAGS        (TH_FIN|TH_SYN|TH_RST|TH_ACK|TH_URG|TH_ECE|TH_CWR)
    u_short th_win;                 /* window */
    u_short th_sum;                 /* checksum */
    u_short th_urp;                 /* urgent pointer */
};


/** packet status flags **/
#define		FEC_FLAG_KNOWN      0           /* data packet status: Known */
#define		FEC_FLAG_WANTED     1           /* data packet status: Wanted */
#define		FEC_FLAG_IGNORE     2           /* data packet status: Not Want */

/* Matrix storage */
struct fec_matrices {
    fec_sym    d[FEC_MAX_H][FEC_MAX_H+1];   /* Duplicate Matrix (generated each symbol) */
    fec_sym    e[FEC_MAX_H][FEC_MAX_H+1];   /* Equation Matrix (once per FEC Block) */
};
extern struct fec_matrices fcm;             /* Declare FEC code matrix fcm */

/***************************************************************************/
/* Error codes                                                             */
/***************************************************************************/

#define     FEC_ERR_INVALID_PARAMS         -1
#define     FEC_ERR_ENC_MISSING_DATA       -20
#define     FEC_ERR_MOD_NOT_FOUND          4
#define     FEC_ERR_TRANS_FAILED           82

/***************************************************************************/
/* Run Option Control (to stderr)                                        */
/***************************************************************************/

//#define  FEC_MAC_LOOKUP                 /* use gf lookup table in FEC_MAC */
//#define     FEC_SPEED_TEST


#define     MAX_PRINT_COLUMNS   8      /* Max columns printed in tables */
// #define     FEC_DBG_LEVEL_0             /* Leave defined, unless want no printing */
// #define     FEC_DBG_LEVEL_1             /* Leave defined, unless want no printing */
//#define     FEC_DBG_LEVEL_2                /*Leave defined, unless want no printing */
// #define     FEC_DBG_LEVEL_3             /* Leave defined, unless want no printing */

//#define     FEC_DBG_LEVEL_1
//#define     FEC_DBG_LEVEL_2             /* print major events */
//#define     FEC_DBG_LEVEL_3             /* Print Encoding and Decoding Steps */
//#define     FEC_DBG_MATH_TABLES         /* print math tables */
//#define     FEC_DBG_PRINT_RS            /* print RS fec_weights (on init) */
//#define     FEC_DBG_PRINT_TRANS         /* print matrix transform (to 3 rows) */
//#define     FEC_DBG_CODE_LENGTH         /* print calculating length into and out of packet */

#ifdef FEC_DBG_LEVEL_0
    #define D0(x) x
#else
    #define D0(x)
#endif

#ifdef FEC_DBG_LEVEL_1
    #define D1(x) x
#else
    #define D1(x)
#endif

#ifdef FEC_DBG_LEVEL_2
    #define D2(x) x
#else
    #define D2(x)
#endif

#ifdef FEC_DBG_LEVEL_3
    #define D3(x) x
#else
    #define D3(x)
#endif

/***************************************************************************/
/* Function prototypes                                                     */
/***************************************************************************/
int  rse_code(int);
int  rse_init(void);
void fec_block_delete(int *);
#ifdef FEC_DBG_LEVEL_0
void fec_block_print(void);
#endif
#ifdef FEC_SPEED_TEST
unsigned long fec_get_time_delta(int);
#endif

/***************************************************************************/

#endif    //_FEC_H
