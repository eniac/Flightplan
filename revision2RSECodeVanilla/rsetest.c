/*
 * RSETEST.C
 * Example aplication using rse.c to endcode and decode packets
 */

#include "rse.h"
#include <stdlib.h>
#include <unistd.h>

/***************************************************************************/
/* Define Size of FEC BLOCK (K and H) and Packet (C) and erasure channel   */
/***************************************************************************/

#define		Default_H   3     /* FEC Parity packets: h <= FEC_MAX_H */
#define		Default_K   3     /* Data packets: k < FEC_MAX_N - FEC_MAX_H */
#define		Default_C   3     /* App data symbols per packet: c <= FEC_MAX_COLS */

/* An array defines packets that are lost (erased) using the FEC block index
   (from 0 to FEC_MAX_N-1). The last element in the array must be FEC_MAX_N,
   marking the end of erasure list. For example, to erasure the second (index = 1)
   and fifth (index = 4) packets, the list would be: {1,4, FEC_MAX_N} */
int Default_erase_list[FEC_MAX_N] = {0, 2, 4, FEC_MAX_N};

/***************************************************************************/
/* Options                                                                 */
/***************************************************************************/
#define		Default_O   0       /* parity codeword offset (normally 0) */
#define     Default_S   3       /* seed for pseudo random data values */
#define		Default_R   1       /* how many times to run test */

/***************************************************************************/
/* Functional Tests */
/***************************************************************************/

/*
 * Create Random Data and Blank Parity packets and link to the FEC block (fb)
 */
void fec_blk_get(fec_blk p, fec_sym k, fec_sym h, int c, int seed, fec_sym o) {

    fec_sym	i, y, z;
    int		j;
    
    fb.block_C = c + FEC_EXTRA_COLS;    /* One extra for length symbol */
    fb.block_N = k + h;
    srand(seed);                /* seed for series of pseudo-random numbers */

    /* Put C random symbols into each of the K data packets */
    for (i=0; i<k; i++) {
        if (i >= FEC_MAX_K) {
            fprintf(stderr, "Number of data packets (%d) in FEC block > FEC_MAX_K (%d)\n", k, FEC_MAX_K);
            exit (33);
        }
        fb.pdata[i] = p[i];
        fb.cbi[i]=i;
        fb.plen[i] = c;
        fb.pstat[i] = FEC_FLAG_KNOWN;
        for (j=0; j<c; j++) {
            p[i][j] = rand() % FEC_N;       /* use next random as data */
// printf ("i=%d j=%d p=%d \n", i, j, p[i][j]);
        }
    }

    /* Leave H Parity packets empty */
    
    for (i=0; i<h; i++) {
        if (i >= FEC_MAX_H) {
            fprintf(stderr, "Number of Requested parity packet (%d) > FEC_MAX_H (%d)\n", h, FEC_MAX_H);
            exit (34);
        }
        y = k + i;                                  /* FEC block index */
        z = FEC_MAX_N - o - i - 1;             /* Codeword index */
        fb.pdata[y] = p[y];
        fb.cbi[y] = z;
        fb.plen[y] = fb.block_C;
        fb.pstat[y] = FEC_FLAG_WANTED;
//        printf ("y=%d z=%d cbi=%d \n", y, z, fb.cbi[y]);
    }
    /*TODO: Need to ask Tony about this !*/
    /* shorten last packet, if not: a) 1 symbol/packet, b) lone packet, c) fixed size */
    if ((c > 1) && (k > 1) && (FEC_EXTRA_COLS > 0)) {
        fb.plen[k-1] -= 1;
        p[k-1][0] -= 1;
    }
}

void results_print(int number_of_tests, unsigned long data_bits_in_fb) {
    unsigned  long     time_taken=0;

#ifdef FEC_SPEED_TEST
    time_taken=fec_get_time_delta(0);
#endif
    fprintf(stderr, "%d time(s) in %lu μs: ~%lu μs per block ≈ %lu Mbps\n", number_of_tests, time_taken, time_taken/number_of_tests, data_bits_in_fb * number_of_tests / time_taken);
}

unsigned long calculate_data_bits_in_fb(void) {
    fec_sym i;
    unsigned  long     symbol_count=0;

    for (i=0; i<fb.block_N; i++) {
        if (fb.cbi[i] < FEC_MAX_K) {
            symbol_count += fb.plen[i];
//            fprintf(stderr, "Symbol %d = %d bits\n", fb.cbi[i], fb.plen[i]);
        }
    }
    return (symbol_count * sizeof(i) * 8);
}

/*
 * Multiple coding operations
 */
void fec_multi_test(int number_of_tests, unsigned  long data_bits_in_fb) {
    int rc, i;

#ifdef FEC_SPEED_TEST
    fec_get_time_delta(0);                          /* start timer */
#endif
    for (i=0; i<number_of_tests; i++) {
        if ((rc=rse_code(0)) != 0 )  exit(rc);
        results_print(1, data_bits_in_fb);
    }
//    results_print(number_of_tests, data_bits_in_fb);
//    fec_block_print();
}
/*
 * Single Encode and decode (send H parity packets after K data packets)
 */
void fec_simple_test(int *e) {
    int rc;

    /* Encoder */
    if ((rc=rse_code(1)) != 0 )  exit(rc);
    fprintf(stderr, "\nSending ");
    D0(fec_block_print());

    
    /* Erasure Channel */
    fec_block_delete(e);
    fprintf(stderr, "\nReceived ");
    D0(fec_block_print());

    /* Decoder */
    if ((rc=rse_code(1)) != 0 )  exit(rc);
    fprintf(stderr, "\nRecovered ");
    D0(fec_block_print());
}

/*
 * Print User input Paramaeters
 */
void usage(int argc, char **argv) {
    fec_sym i;
    
    fprintf(stderr, "\nUnknown parameter.  Usage:\n\n");
    fprintf(stderr, "  %s\n", argv[0]);
    fprintf(stderr, "     [-k Number of Data packets in the FEC block]\n");
    fprintf(stderr, "     [-h Number of Parity packets in the FEC block]\n");
    fprintf(stderr, "     [-c Max number of (%lu-byte) Symbols in a data packet]\n", sizeof(i));
    fprintf(stderr, "     [-e FEC Block index of packet erased in comms emulation]\n");
    fprintf(stderr, "     [-o Offset when selecting which parities to generate]\n");
    fprintf(stderr, "     [-r Number of runs in a speed test of encoder and decoder]\n");
    fprintf(stderr, "     [-s Seed for generating random data values]\n");
    fprintf(stderr, "\nExample of FEC block with k=4 data & h=3 parity packets of c=8 symbols.\n");
            fprintf(stderr, "With Comms link erasing packets 0, 2, 3 and 5:\n\n");
    fprintf(stderr, "  %s ", argv[0]);
    fprintf(stderr, "-k 3 -h 4 -c 8 -e 0 -e 2 -e 3 -e 5\n");
    exit (1);
}

/*
 * Get User input
 */
int main(int argc, char **argv) {
    fec_sym p[FEC_MAX_N][FEC_MAX_COLS];   /* storage for packets in FEC block (fb) */
    fec_sym k, h, o;
    int c, opt, rc, i=0, r, s;
    int list_done = (int) FEC_MAX_N;
    int e_list[FEC_MAX_N];
    unsigned  long     data_bits_in_fb;
    
    e_list[0] = list_done;         /* empty list of erasure fb packet indices */
    h = Default_H;
    k = Default_K;
    c = Default_C;
    o = Default_O;
    r = Default_R;
    s = Default_S;
    while((opt =  getopt(argc, argv, "c:e:k:h:o:r:s:")) != EOF)
    {
        switch (opt)
        {
            case 'c':  //Number of symbols in a packet (pointed to by the fb)
                c = atoi(optarg);
                break;
            case 'e':  //Input (possibly of many) giving fb index of a packet erasure
                e_list[i++] = atoi(optarg);
                break;
            case 'h':  //Number of FEC packets to add in fb
                h = atoi(optarg);
                break;
            case 'k':  //Number of Data Packets in the fb
                k = atoi(optarg);;
                break;
            case 'o':  //Parity Offset
                o = atoi(optarg);;
                break;
            case 'r':  //Number of times to run encode-decode cycle
                r = atoi(optarg);;
                break;
            case 's':  //Seed
                s = atoi(optarg);;
                break;
            default:
                printf("\nNot yet defined opt = %d\n", opt);
                abort();
        }
    }
    if (argc == 2)   usage(argc, argv);     /* Print help if one arguement */
    /* If no erasure input indices input, then use defaults */
    if ( e_list[0] == list_done) {
        for (i=0; Default_erase_list[i] != list_done; i++) {
            e_list[i] = Default_erase_list[i];      /* copy default values */
        }
    }
    e_list[i] = list_done;      /* put list_done marker at end of input */
    
    if ((rc = rse_init()) != 0 ) exit(rc);   /* initialize fec codewords */
    fec_blk_get(p, k, h, c, s, o);

    switch (r) {
        case 0:
            printf("\nNot yet defined Number of runs = %d\n", r);
            break;
        case 1:
            fec_simple_test(e_list);        /* 1 run of encoder and decoder */
            break;
        default:
            data_bits_in_fb = calculate_data_bits_in_fb();
            printf("Run Encoder %d times for FEC Block with %lu data bits:\n", r, data_bits_in_fb);
            fec_multi_test(r, data_bits_in_fb);
            if ((rc=rse_code(1)) != 0 )  exit(rc);          /* encode and mark */
            fec_block_delete(e_list);                       /* delete packets */
            printf("Run Decoder %d times for FEC Block with %lu data bits:\n", r, data_bits_in_fb);
            fec_multi_test(r, data_bits_in_fb);
    }
    return (0);
}
