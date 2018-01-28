/*
 * RSETEST.C
 * Example aplication using rse.c to endcode and decode packets
 */

#include "rse.h"
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

#include <semaphore.h>

/***************************************************************************/
/* Define Size of FEC BLOCK (K and H) and Packet (C) and erasure channel   */
/***************************************************************************/

#define     Default_H   3     /* FEC Parity packets: h <= FEC_MAX_H */
#define     Default_K   3     /* Data packets: k < FEC_MAX_N - FEC_MAX_H */
#define     Default_C   2     /* App data symbols per packet: c <= FEC_MAX_COLS */

/* An array defines packets that are lost (erased) using the FEC block index
   (from 0 to FEC_MAX_N-1). The last element in the array must be FEC_MAX_N,
   marking the end of erasure list. For example, to erasure the second (index = 1)
   and fifth (index = 4) packets, the list would be: {1,4, FEC_MAX_N} */
int Default_erase_list[FEC_MAX_N] = {0, 2, 4, FEC_MAX_N};

/***************************************************************************/
/* Options                                                                 */
/***************************************************************************/
#define     Default_O   0       /* parity codeword offset (normally 0) */
#define     Default_S   3       /* seed for pseudo random data values */
#define     Default_R   1       /* how many times to run test */

/***************************************************************************/
/* PCAP functions */
/***************************************************************************/

/* ethernet headers are always exactly 14 bytes [1] */
#define SIZE_ETHERNET 14

/*The semaphores for the shared queue to synchronize PCAP and FEC block generator.*/
sem_t full, empty;

pthread_mutex_t var = PTHREAD_MUTEX_INITIALIZER; /* Used to lock the access to share queue during enqueue/dequeue */
pthread_t tid; /* Storing the thread ID for the thread created.

/* TCP header */
typedef u_int tcp_seq;

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

struct fec_header {
  uint8_t blockId;
  uint8_t pktId;
};

#define IP_HL(ip)               (((ip)->ip_vhl) & 0x0f)
#define IP_V(ip)                (((ip)->ip_vhl) >> 4)



#define CAPTURE_QUEUE_SIZE 10000
#define CAPTURE_SIZE 1000

/*TODO: Remove this */
int cnt =0;

typedef struct packetInfo {
    char* packetStart;
    char* payloadStart; /* Start Address of the payload */
    int payloadLength; /* total length of payload */
} packetInfo_t;

pcap_t *handle; /*Pcap handle*/

/* Call back registered on capturing a packet */
void my_packet_handler(u_char *args, const struct pcap_pkthdr *header, const u_char *packet);

/* function to initiate a packet capture */
void* capturePackets(void* arg);

/* A debug function to print payload */
void printPayload(int payload_length, u_char* payload);

/* A structure to represent a queue*/
struct Queue
{
    int front, rear, size;
    unsigned capacity;
    packetInfo_t** array;
};

/*capture queue, accessible globally*/
struct Queue* captureQueue;

/*function to create a queue of given capacity. It initializes size of queue as 0*/
struct Queue* createQueue(unsigned capacity)
{
    struct Queue* queue = (struct Queue*) malloc(sizeof(struct Queue));
    queue->capacity = capacity;
    queue->front = queue->size = 0;
    queue->rear = capacity - 1;  // This is important, see the enqueue
    queue->array = (packetInfo_t** ) malloc(queue->capacity * sizeof(packetInfo_t*));
    return queue;
}

/*Queue is full when size becomes equal to the capacity*/
int isFull(struct Queue* queue) {
    return (queue->size == queue->capacity);
}

/*Queue is empty when size is 0*/
int isEmpty(struct Queue* queue) {
    return (queue->size == 0);
}

/*Function to add the captured packet info to the queue.*/
void enqueue(struct Queue* queue, packetInfo_t* item)
{
    /*lock the critical section*/
    pthread_mutex_lock(&var);

    if (isFull(queue))
        return;
    queue->rear = (queue->rear + 1) % queue->capacity;
    queue->array[queue->rear] = item;
    queue->size = queue->size + 1;

    /*unlock the critical section*/
    pthread_mutex_unlock(&var);
}

/*Function to remove the captured packet from the queue.*/
packetInfo_t* dequeue(struct Queue* queue) {
    /* lock the critical section*/
    pthread_mutex_lock(&var);

    if (isEmpty(queue))
        return NULL;
    packetInfo_t* item = queue->array[queue->front];
    queue->front = (queue->front + 1) % queue->capacity;
    queue->size = queue->size - 1;
    /*unlock the critical section*/
    pthread_mutex_unlock(&var);
    return item;
}

/*Function to get front of queue*/
packetInfo_t* front(struct Queue* queue) {
    if (isEmpty(queue))
        return NULL;
    return queue->array[queue->front];
}

/*Function to get rear of queue*/
packetInfo_t* rear(struct Queue* queue) {
    if (isEmpty(queue))
        return NULL;
    return queue->array[queue->rear];
}
/*   global count to keep track of the captured packets. This is used to avoid PCAP capturing continuosly.  */
int capturedCount = 0;
/*  device on which packet capture should happen*/
char * deviceToCapture;

void my_packet_handler(
    u_char *args,
    const struct pcap_pkthdr *header,
    const u_char *packet
) {
    cnt++;
    /* declare pointers to packet headers */
    const struct sniff_ethernet *ethernet;  /* The ethernet header [1] */
    const struct sniff_ip *ip;              /* The IP header */
    const struct sniff_tcp *tcp;            /* The TCP header */
    // const struct fec_header *fecHeader;
    u_char *payload;                    /* Packet payload */

    int size_ip;
    int size_tcp;
    int size_payload;

    /* define ethernet header */
    ethernet = (struct sniff_ethernet*)(packet);

    /* define/compute ip header offset */
    ip = (struct sniff_ip*)(packet + SIZE_ETHERNET);
    size_ip = IP_HL(ip) * 4;
    if (size_ip < 20) {
        return;
    }

    /* define/compute tcp header offset */
    tcp = (struct sniff_tcp*)(packet + SIZE_ETHERNET + size_ip);
    size_tcp = TH_OFF(tcp) * 4;
    if (size_tcp < 20) {
        return;
    }

    /* define/compute tcp payload (segment) offset */
    payload = (u_char *)(packet + SIZE_ETHERNET + size_ip + size_tcp);

    /* compute tcp payload (segment) size */
    size_payload = ntohs(ip->ip_len) - (size_ip + size_tcp);

    if (size_payload > 0) {
        /*  Allocate packetinfo per captured packet.  */
        packetInfo_t* capturedPacket = (packetInfo_t *) malloc(sizeof(packetInfo_t));
        capturedPacket->payloadLength = size_payload;

        /* populate the payload length into the global structure to be used later */
        capturedPacket->payloadStart = (char *)payload;

        /* Starting pointer of the captured packet including the header */
        capturedPacket->packetStart = (char*) header;

        printf("The headers are as follows\n");
        // printf("");

        /*Synchronized producer block.*/
        sem_wait(&empty);

        /* Increment the count of captured packets */
        capturedCount++;

        /* Enqueue the packet into the captured queue */
        enqueue(captureQueue, capturedPacket);

        /*release the semaphore.*/
        sem_post(&full);
    }

    /* Print payload in ASCII */
    /*  Uncomment for debugging   */
    // printPayload(size_payload, payload);
    // fecHeader = (struct fec_header *) (packet + SIZE_ETHERNET);
    // printf("PktId:: %d :::: blockId:: %d\n", fecHeader->pktId, fecHeader->blockId);
    // size_t outPktLen = header->len;
    // pcap_inject(handle,packet,outPktLen);

    return;
}

/* A debug function to print payload */
void printPayload(int payload_length, u_char* payload) {
    if (payload_length > 0) {
        u_char *temp_pointer = payload;
        int byte_count = 0;
        while (byte_count++ < payload_length) {
            printf("%c", *temp_pointer);
            temp_pointer++;
        }
        printf("\n");
    }

}

void* capturePackets(void* arg) {
    char *device;
    char error_buffer[PCAP_ERRBUF_SIZE];
    device = deviceToCapture;
    printf("Capturing packets on %s\n", device );
    /* Open device for live capture */
    handle = pcap_open_live(
                 device,
                 BUFSIZ,
                 1, /*set device to promiscous*/
                 0, /*Timeout of 0*/
                 error_buffer
             );

    if (handle == NULL) {
        fprintf(stderr, "Could not open device %s: %s\n", device, error_buffer);
        return NULL;
    }

    /*Indicates that we need to capture only incoming packets.*/
    // pcap_setdirection(handle, PCAP_D_IN);
    
    printf("This is the start of capture\n");
    pcap_loop(handle, 0, my_packet_handler, NULL);
    printf("Ths is the end of capture\n");

    // int ret = pcap_setdirection(handle, PCAP_D_IN);
    // if (ret == -1) {
    //     printf("Packet capture failed! \n");
    //     pthread_exit(NULL);
    // }
    printf("Completed Capturing packets on %s\n", device );
    printf("COUNT is ::::::: %d\n", cnt);
    pthread_exit(NULL);
    return NULL;
}


/*
 * Create Random Data and Blank Parity packets and link to the FEC block (fb)
 */
void fec_blk_get(fec_blk p, fec_sym k, fec_sym h, int c, int seed, fec_sym o) {
    fprintf(stderr, "At the top of fec_blk_get\n");
    fec_sym i, y, z;
    int maxPacketLength = 0;
    // fb.block_C = c + FEC_EXTRA_COLS;    /* One extra for length symbol */
    fb.block_N = k + h;

    /* Call the packet capture to populate the capturedPackets array */
    packetInfo_t* populatePacket;

    /* Put C random symbols into each of the K data packets */
    for (i = 0; i < k; i++) {
        if (i >= FEC_MAX_K) {
            fprintf(stderr, "Number of Requested data packet (%d) > FEC_MAX_K (%d)\n", k, FEC_MAX_K);
            exit (33);
        }

        printf("Now waiting for the lock\n");

        /*The synchronization at the consumer block*/
        sem_wait(&full);

        /*  Dequeue the captured packet and populate the global FEC block.  */
        if ((populatePacket = dequeue(captureQueue)) != NULL ) {
            fb.pdata[i] = (fec_sym *) populatePacket->payloadStart;
            fb.cbi[i] = i;
            fb.plen[i] = populatePacket->payloadLength;
            // printf("The length of the payload is : %d\n", populatePacket->payloadLength);
            /*  Keep track of maximum packet length to set the block_C field of FEC structure    */
            if (populatePacket->payloadLength > maxPacketLength) {
                maxPacketLength = populatePacket->payloadLength;
            }
            // printf("The max packet length inside the loop is : %d\n", maxPacketLength);
            fb.pstat[i] = FEC_FLAG_KNOWN;
        } else {
            printf("Error: We don't have any more packets");
            break;
        }
        sem_post(&empty);

    }

    // printf("The length after the loop is : %d\n", maxPacketLength);

    fb.block_C = maxPacketLength + FEC_EXTRA_COLS;    /* One extra for length symbol */
    fprintf(stderr, "This is the value of fb.block_C = %d\n", fb.block_C);


    /* Leave H Parity packets empty */

    for (i = 0; i < h; i++) {
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
    /* shorten last packet, if not: a) 1 symbol/packet, b) lone packet, c) fixed size */
    if ((c > 1) && (k > 1) && (FEC_EXTRA_COLS > 0)) {
        fb.plen[k - 1] -= 1;
        p[k - 1][0] -= 1;
    }
}

void results_print(int number_of_tests, unsigned long data_bits_in_fb) {
    unsigned  long     time_taken = 0;

#ifdef FEC_SPEED_TEST
    time_taken = fec_get_time_delta(0);
#endif
    fprintf(stderr, "%d time(s) in %lu μs: ~%lu μs per block ≈ %lu Mbps\n", number_of_tests, time_taken, time_taken / number_of_tests, data_bits_in_fb * number_of_tests / time_taken);
}

unsigned long calculate_data_bits_in_fb(void) {
    fec_sym i;
    unsigned  long     symbol_count = 0;

    for (i = 0; i < fb.block_N; i++) {
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
    for (i = 0; i < number_of_tests; i++) {
        if ((rc = rse_code(0)) != 0 )  exit(rc);
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
    if ((rc = rse_code(1)) != 0 )  exit(rc);
    fprintf(stderr, "\nSending ");
    D0(fec_block_print());

    /* Erasure Channel */
    fec_block_delete(e);
    fprintf(stderr, "\nReceived ");
    D0(fec_block_print());

    /* Decoder */
    if ((rc = rse_code(1)) != 0 )  exit(rc);
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

int check_stack_size(int size) {
    fec_sym i;
    int systemRet, size_in_KB, mylimit_in_KB = 7000;

    size_in_KB = size * sizeof(i) / 1000;
    if (size_in_KB > mylimit_in_KB) {
        fprintf(stderr, "\nrsetest.c allocated %d KB fon stack for packet store. My limit = %d KB ulimit = ", size_in_KB, mylimit_in_KB);
        systemRet = system("ulimit -s");
        exit (1);
    }
    else {
        return 0;
    }
}
/*
 * Get User input
 */
int main(int argc, char **argv) {
    fec_sym p[FEC_MAX_N][FEC_MAX_COLS];   /* storage for packets in FEC block (fb) */
    fec_sym k, h, o;
    int c, opt, rc, i = 0, r, s;
    int list_done = (int) FEC_MAX_N;
    int e_list[FEC_MAX_N];
    unsigned  long     data_bits_in_fb;

    check_stack_size (FEC_MAX_COLS * FEC_MAX_N);
    e_list[0] = list_done;         /* empty list of erasure fb packet indices */
    h = Default_H;
    k = Default_K;
    c = Default_C;
    o = Default_O;
    r = Default_R;
    s = Default_S;
    deviceToCapture = "eno1";
    while ((opt =  getopt(argc, argv, "c:e:k:h:o:r:s:i:")) != EOF)
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
        case 'i':
            deviceToCapture = optarg;
            break;
        default:
            printf("\nNot yet defined opt = %d\n", opt);
            abort();
        }
    }
    if (argc == 2)   usage(argc, argv);     /* Print help if one arguement */
    /* If no erasure input indices input, then use defaults */
    if ( e_list[0] == list_done) {
        for (i = 0; Default_erase_list[i] != list_done; i++) {
            e_list[i] = Default_erase_list[i];      /* copy default values */
        }
    }
    e_list[i] = list_done;      /* put list_done marker at end of input */

    if ((rc = rse_init()) != 0 ) exit(rc);   /* initialize fec codewords */
    /* Create the full semaphore and initialize to 0 */
    sem_init(&full, 0, 0);

    /* Create the empty semaphore and initialize to BUFFER_SIZE */
    sem_init(&empty, 0, CAPTURE_QUEUE_SIZE);

    int err = pthread_create(&tid, NULL, &capturePackets, NULL);
    if (err != 0)
        printf("\ncan't create thread :[%s]", strerror(err));
    else
        printf("\n Thread created successfully\n");

    captureQueue = createQueue(CAPTURE_QUEUE_SIZE);
    int z = 0;
    while ( z < 100) {
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
            if ((rc = rse_code(1)) != 0 )  exit(rc);        /* encode and mark */
            fec_block_delete(e_list);                       /* delete packets */
            printf("Run Decoder %d times for FEC Block with %lu data bits:\n", r, data_bits_in_fb);
            fec_multi_test(r, data_bits_in_fb);
        }
        z++;
    }
    return (0);
}
