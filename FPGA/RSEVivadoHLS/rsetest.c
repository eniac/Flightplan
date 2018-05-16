/*
 * RSETEST.C
 * Example aplication using rse.c to endcode and decode packets
 */

#include "Configuration.h"
#include <getopt.h>
#include "rse.h"
#include <stdlib.h>
#include <unistd.h>

/***************************************************************************/
/* Define Size of FEC BLOCK (K and H) and Packet (C) and erasure channel   */
/***************************************************************************/

#define     Default_H   FEC_H     /* FEC Parity packets: h <= FEC_MAX_H */
#define     Default_K   FEC_K     /* Data packets: k < FEC_MAX_N - FEC_MAX_H */
#define     Default_C   2     /* App data symbols per packet: c <= FEC_MAX_COLS */

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
#define     Default_A   0       /* Incrementally add parities */
/***************************************************************************/
/* Mains Tests */
/***************************************************************************/

 /*
 * Create Random Data and Blank Parity packets and link to the FEC block (fb)
 */
void fec_blk_get(int fb_index, fec_blk p, fec_sym k, fec_sym h, int c, int seed, fec_sym o) {

    fec_sym	i;
    int		j, fec_packet_length=0;
    
    fec_block_init(fb_index, k, h, FEC_FLAG_WANTED, FEC_FLAG_WANTED);   /* ready for encoding */
    srand(seed);                /* seed for series of pseudo-random numbers */

    if (k > FEC_MAX_K) {
        fprintf(stderr, "Number of data packets (%d) in FEC block > FEC_MAX_K (%d)\n", k, FEC_MAX_K);
        exit (33);
    }
    if (h > FEC_MAX_H) {
        fprintf(stderr, "Number of Requested parity packet (%d) > FEC_MAX_H (%d)\n", h, FEC_MAX_H);
        exit (34);
    }

    /* Put C random symbols into each of the K data packets */
    for (i=0; i<k; i++) {
        for (j=0; j<c; j++) {
            p[i][j] = rand() % FEC_N;                   /* use next random as data */
        }
//        printf ("p=%p p[i]=%p p[i][0]=%x (%x)\n", p, p[i], p[i][0], *p[i]);
        fec_packet_length = fec_block_add_data_packet(fb_index, p[i], i, c, FEC_FLAG_KNOWN);     /* add packet to fb */
    }

    /* Leave H Parity packets empty */
    for (i=0; i<h; i++) {
//        z = FEC_MAX_N - o - i - 1;                      /* Codeword Block index */
        fec_block_add_parity_packet(fb_index, p[i+k], i, k, o, fec_packet_length, FEC_FLAG_WANTED);  /* add packet to fb */
    }
    
    /* shorten last packet, if not: a) 1 symbol/packet, b) lone packet, c) fixed size */
    if ((c > 1) && (k > 1) && (FEC_EXTRA_COLS > 0)) {
        i = k-1;
        fec_block_add_data_packet(fb_index, p[i], i, c-1, FEC_FLAG_KNOWN);     /* add packet to fb */
    }
}

/*
 * Single Encode (send H parity packets after K data packets)
 */
void simple_encode(int fb_index) {
    int rc;
    
    if ((rc=rse_code(fb_index, 'e')) != 0 )  exit(rc);
    fprintf(stderr, "\nSending ");
    D0(fec_block_print(fb_index));
}

/*
 * Emulate Erasure Channel (causing specified packets to be WANTED)
 */
void simple_erase(int fb_index, int *e) {
    
    fec_block_delete(fb_index, e);
    fprintf(stderr, "\nReceived ");
    D0(fec_block_print(fb_index));
}

/*
 * Single Decode (Recover unknown data packets)
 */
void simple_decode(int fb_index) {
    int rc;

    if ((rc=rse_code(fb_index, 'd')) != 0 )  exit(rc);
    fprintf(stderr, "\nRecovered ");
    D0(fec_block_print(fb_index));
}

/*
 * Single Encode (send H parity packets after K data packets)
 */
void simple_add(int fb_index, fec_blk p, fec_sym k, int add_count) {
    fec_sym fbi, *ptr;
    int  i, rc, len;

//    printf("Add %d additional parities\n", add_count);
    fbi = fec_block_add(fb_index, add_count);      /* Modify Number of packets and get old value */
    len = fec_block_get_len(fb_index, fbi - 1);     /* Length of parity packet */
    for (i=0; i<add_count; i++) {
        ptr = p[0] + ((fbi+i)*FEC_MAX_COLS);       /* pointer to next packet buffer */
        fec_block_add_wanted_packet(fb_index, ptr, fbi+i, k, 0, len);
    }
//    D0(fec_block_print(fb_index));
    if ((rc=rse_code(fb_index, 'e')) != 0 )  exit(rc);
    fprintf(stderr, "\nSending ");
    D0(fec_block_print(fb_index));
}
/***************************************************************************/
/* Speed Tests */
/***************************************************************************/

void results_print(int number_of_tests, unsigned long data_bits_in_fb) {
    unsigned  long     time_taken=0;
    int                 level=3;
    
    if (number_of_tests == 0)   {
        time_taken=fec_get_time_delta(1, 0);
        time_taken=fec_get_time_delta(2, 0);
        if (FEC_SPEED_TEST < level)  fprintf(stderr, "Ignore first run\n");
    }
    else {
        time_taken=fec_get_time_delta(1, 2);
        if (FEC_SPEED_TEST < level)  fprintf(stderr, "%d time(s) in %lu μs: ~%lu μs per block ≈ %lu Mbps\n", number_of_tests, time_taken, time_taken/number_of_tests, data_bits_in_fb * number_of_tests / time_taken);
    }
}

/*
 * Multiple coding operations
 */
void fec_multi_test(int number_of_tests, unsigned  long data_bits_in_fb, char code_mode) {
    int rc, i;
    int fb_index=0;

    for (i=0; i<number_of_tests; i++) {
        if ((rc=rse_code(fb_index, code_mode)) != 0 )  exit(rc);
        if (i==0)   results_print(0, data_bits_in_fb);  /* start timer */
        else        results_print(1, data_bits_in_fb);  /* print delta */
    }
//    results_print(number_of_tests, data_bits_in_fb);
//    fec_block_print(fb_index, 0);
}

/*
 * Delete Packet from FEC Block with given FEC block indices (fbis)
 */
void erase_random_data_packets(int *delete_fbis, int h) {
    int i;
    int list_done = (int) FEC_MAX_N;
    int fb_index=0;

    for (i=0; i<h; i++) {
        delete_fbis[i] = i;
    }
    delete_fbis[i] = list_done;      /* put marker at end of input */
    fec_block_delete(fb_index, delete_fbis);   /* delete packets */
}

void simple_speed_test (int fb_index, int r, fec_sym h, fec_sym k) {
    int             rc;
    unsigned  long  data_bits_in_fb, time_taken;
    int             e_list[FEC_MAX_N];

    data_bits_in_fb = fec_block_number_of_data_bits(fb_index);
#ifdef FEC_SPEED_TEST
    fec_multi_test(r+1, data_bits_in_fb, 'E');      /* encode but don't mark */
    time_taken=fec_get_time_delta(2, 1);
    printf("\nRan Encoder %d times (%d parity from %d data packets (~%lu data bits) per run):\n Average Data Rate = %lu Mbps\n", r, h, k, data_bits_in_fb, data_bits_in_fb * r / time_taken);


    if ((rc=rse_code(fb_index, 'e')) != 0 )  exit(rc);      /* encode and mark */
    erase_random_data_packets(e_list, h);
    fec_multi_test(r+1, data_bits_in_fb, 'D');      /* decode but don't mark */
    time_taken=fec_get_time_delta(2, 1);
    printf("\nRan Decoder %d times (regenerated %d data from %d received packets per run):\n Average Data Rate = %lu Mbps\n", r, h, k, data_bits_in_fb * r / time_taken);

#else
    printf("MUST define FEC_SPEED_TEST in rse.h to run speed test\n");
#endif
}

/***************************************************************************/
/* Main */
/***************************************************************************/

/*
 * Print User input Paramaeters
 */
void usage(int argc, char **argv) {
    fec_sym i;
    
    fprintf(stderr, "\nUnknown parameter.  Usage:\n\n");
    fprintf(stderr, "  %s\n", argv[0]);
    fprintf(stderr, "     [-a Add additional parities to those already generated]\n");
    fprintf(stderr, "     [-c Max number of (%lu-byte) Symbols in a data packet]\n", sizeof(i));
    fprintf(stderr, "     [-e FEC Block index of packet erased in comms emulation]\n");
    fprintf(stderr, "     [-h Number of Parity packets in the FEC block]\n");
    fprintf(stderr, "     [-k Number of Data packets in the FEC block]\n");
    fprintf(stderr, "     [-o Offset when selecting which parities to generated\n");
    fprintf(stderr, "     [-r Number of runs in a speed test of encoder and decoder]\n");
    fprintf(stderr, "     [-s Seed for generating random data values]\n");
    fprintf(stderr, "\nExample of FEC block with k=4 data & h=3 parity packets of c=8 symbols.\n");
    fprintf(stderr, "With Comms link erasing packets 0, 2, 3 and 5:\n\n");
    fprintf(stderr, "  %s ", argv[0]);
    fprintf(stderr, "-k 3 -h 4 -c 8 -e 0 -e 2 -e 3 -e 5\n");
    exit (1);
}

int check_stack_size(int size) {
    fec_sym i;
    int systemRet, size_in_KB, mylimit_in_KB=7000;
    
    size_in_KB = size * sizeof(i) / 1000;
    if (size_in_KB > mylimit_in_KB) {
        systemRet = system("ulimit -s");
        fprintf(stderr, "\nrsetest.c allocated %d KB fon stack for packet store. My limit = %d KB ulimit = %d", size_in_KB, mylimit_in_KB, systemRet);

        exit (1);
    }
    else {
        return 0;
    }
}

int main(int argc, char **argv) {
    fec_sym p[FEC_MAX_N][FEC_MAX_COLS];   /* storage for packets in FEC block (fb) */
    fec_sym k, h, a, o;
    int c, opt, rc, i=0, r, s;
    int list_done = (int) FEC_MAX_N;
    int e_list[FEC_MAX_N];
    int fb_index=0;
    
    check_stack_size (FEC_MAX_COLS*FEC_MAX_N);
    e_list[0] = list_done;         /* empty list of erasure fb packet indices */
    a = Default_A;
    h = Default_H;
    k = Default_K;
    c = Default_C;
    o = Default_O;
    r = Default_R;
    s = Default_S;
    while((opt =  getopt(argc, argv, "a:c:e:k:h:o:r:s:")) != EOF)
    {
        switch (opt)
        {
            case 'a':  //Number of symbols in a packet (pointed to by the fb)
                a = atoi(optarg);
                break;
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
    fec_blk_get(fb_index, p, k, h, c, s, o);             /* Generate random data */

    switch (r) {
        case 0:
            printf("\nNot yet defined Number of runs = %d\n", r);
//            graph_rate(p, k, h, c, s, o);   /* Graph rates up to k and h */
            break;
        case 1:
            /* 1 run of encoder, channel emulation and decoder */
            simple_encode(fb_index);
            if ( a > 0 ) {
                simple_add(fb_index, p, k, a);
            }
            simple_erase(fb_index, e_list);
            simple_decode(fb_index);
 
            break;
        default:
            simple_speed_test(fb_index, r, h, k);
    }
    
    
    return (0);
}
