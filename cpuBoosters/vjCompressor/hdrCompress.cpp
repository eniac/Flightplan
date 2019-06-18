#ifdef COMPRESSOR
#include "Compressor.h"
#else
#include "Decompressor.h"
#endif
#include <stdlib.h>
#include <signal.h>
#include <pcap.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <net/ethernet.h>
#include <stdio.h>
#include "hdrCompress.h"
#include <algorithm>
#include <math.h>
#include <stdlib.h>

#include <iostream>
#include <fstream>
#include <cstring>
#include <sstream>

#define ETH_SIZE ((16 + 48 + 48)/8)
#define UDP_SIZE ((16 + 16 + 16 + 16)/8)
#define IPV4_SIZE ((32 + 32 + 16 + 8 + 8+ 13 + 3 + 16 + 16 + 8 + 4 + 4)/8)
#define MTU 1500
using namespace std;

static pcap_t *output_handle = NULL;
static pcap_t *pcap = NULL;
int flow = 0;

void compressHandler(u_char *userData, const struct pcap_pkthdr* pkthdr, const u_char* packet);
void decompressHandler(u_char *userData, const struct pcap_pkthdr* pkthdr, const u_char* packet);

static int in_offset;
template <int size_bits>
const char* cp_in(ap_uint<size_bits> &dst, const char *src) {
    //std::cout << "Parsing " << size_bits << " bits starting at byte " << (int)( src - src_orig) << ", Offset: " << in_offset << std::endl;
    uint64_t src_bits = *(uint64_t*)src;

    char *start = (char*)&src_bits;
    char *end = start + (size_bits + 8 - 1)/8;

    src_bits <<= in_offset;
    std::reverse(start, end);
    src_bits >>= (64 - size_bits)% 8;
    //src_bits >>= in_offset;

    dst = (ap_uint<size_bits>)(src_bits);

    const char *rtn = src + (size_bits + in_offset) / 8;
    in_offset = (size_bits + in_offset) % 8;
    //std::cout << "Finished Parsing " << size_bits << " bits starting at byte " << (int)( src - src_orig) << ", Offset now: " << in_offset << std::endl;
    return rtn;
}

static int out_offset;
template <int size_bits>
unsigned char *cp_out(ap_uint<size_bits> &src, unsigned char *dst){
    uint64_t src_bits = (uint64_t)src;
    int i;
    char *start = (char*)&src_bits;
    char *end = start + (size_bits + 8 - 1) / 8;
    std::reverse(start, end);
    //src_bits >>= out_offset;
    int left_shift = ((64 - (size_bits + out_offset)) % 8);
    src_bits <<= left_shift;
    /* If flow is 0 - Compress, then we copy the compressed bytes 
       but use an | when the size_bits is less than a byte */
    if (flow == 0) {
        for (i=0; i < (size_bits + out_offset + 7) / 8; i++) {
            if (out_offset > 0)
                dst[i] |= start[i];
            else
                dst[i] = start[i];
        }
    } else {
        for (i=0; i < (size_bits + out_offset + 7) / 8; i++) {
            dst[i] |= start[i];
        }
    }

    dst = dst + (size_bits + out_offset) / 8;
    out_offset = (size_bits + out_offset) % 8;

    return dst;
}

void transfer_in(input_tuples &input_tuple, const char *packet) {
    const char *sv = packet;

    tuple_eth &eth = input_tuple.Hdr.Eth;
    sv = cp_in(eth.Dst, sv);
    sv = cp_in(eth.Src, sv);
    sv = cp_in(eth.Type, sv);

    if(eth.Type == 0x0800) {
        tuple_ipv4 &ipv4 = input_tuple.Hdr.Ipv4;
        sv = cp_in(ipv4.version, sv);
        sv = cp_in(ipv4.ihl, sv);
        sv = cp_in(ipv4.diffserv, sv);
        sv = cp_in(ipv4.totallen, sv);
        sv = cp_in(ipv4.identification, sv);
        sv = cp_in(ipv4.flags, sv);
        sv = cp_in(ipv4.fragoffset, sv);
        sv = cp_in(ipv4.ttl, sv);
        sv = cp_in(ipv4.protocol, sv);
        sv = cp_in(ipv4.hdrchecksum, sv);
        sv = cp_in(ipv4.srcAddr, sv);
        sv = cp_in(ipv4.dstAddr, sv);

        tuple_tcp &tcp = input_tuple.Hdr.Tcp;
        sv = cp_in(tcp.sport, sv);
        sv = cp_in(tcp.dport, sv);
        sv = cp_in(tcp.seq, sv);
        sv = cp_in(tcp.ack, sv);
        sv = cp_in(tcp.flags, sv);
        sv = cp_in(tcp.window, sv);
        sv = cp_in(tcp.check, sv);
        sv = cp_in(tcp.urgent, sv);
        input_tuple.Hdr.Tcp.isValid = 1;
    } else if(eth.Type == 0x1234) {
#ifndef COMPRESSOR
        std::cout << "Copying tuple_cmp over to packet";
        tuple_cmp &cmp = input_tuple.Hdr.Cmp;
        sv = cp_in(cmp.slotID, sv);
        sv = cp_in(cmp.seqChange, sv);
        sv = cp_in(cmp.ackChange, sv);
        sv = cp_in(cmp.__pad, sv);
        sv = cp_in(cmp.totallen, sv);
        sv = cp_in(cmp.identification, sv);
        sv = cp_in(cmp.flags, sv);
        sv = cp_in(cmp.window, sv);
        sv = cp_in(cmp.check, sv);
        sv = cp_in(cmp.urgent, sv);
        input_tuple.Hdr.Cmp.isValid = 1;
#endif
    }
    std::cout << "Parsed " << (int)(sv - (char*)packet) << " bytes" << std::endl;
}

uint16_t ccsum(void *buf, size_t buflen) {
    uint32_t r = 0;
    size_t len = buflen;

    const uint16_t* d = reinterpret_cast<const uint16_t*>(buf);

    while (len > 1)
    {
        r += *d++;
        len -= sizeof(uint16_t);
    }

    if (len)
    {
        r += *reinterpret_cast<const uint8_t*>(d);
    }

    while (r >> 16)
    {
        r = (r & 0xffff) + (r >> 16);
    }

    return static_cast<uint16_t>(~r);
}

template <typename T>
void transfer_out(T &output_tuple, char *packet) {
    unsigned char *sv = (unsigned char*)packet;

    tuple_eth &eth = output_tuple.Hdr.Eth;
    sv = cp_out(eth.Dst, sv);
    sv = cp_out(eth.Src, sv);
    sv = cp_out(eth.Type, sv);

    tuple_ipv4 &ipv4 = output_tuple.Hdr.Ipv4;
    unsigned char *start_sv = sv;
    sv = cp_out(ipv4.version, sv);
    sv = cp_out(ipv4.ihl, sv);
    sv = cp_out(ipv4.diffserv, sv);
    sv = cp_out(ipv4.totallen, sv);
    sv = cp_out(ipv4.identification, sv);
    sv = cp_out(ipv4.flags, sv);
    sv = cp_out(ipv4.fragoffset, sv);
    sv = cp_out(ipv4.ttl, sv);
    sv = cp_out(ipv4.protocol, sv);
    unsigned char *chk_sv = sv;
    sv = cp_out(ipv4.hdrchecksum, sv);
    sv = cp_out(ipv4.srcAddr, sv);
    sv = cp_out(ipv4.dstAddr, sv);

    tuple_tcp &tcp = output_tuple.Hdr.Tcp;
    sv = cp_out(tcp.sport, sv);
    sv = cp_out(tcp.dport, sv);
    sv = cp_out(tcp.seq, sv);
    sv = cp_out(tcp.ack, sv);
    sv = cp_out(tcp.flags, sv);
    sv = cp_out(tcp.window, sv);
    sv = cp_out(tcp.check, sv);
    sv = cp_out(tcp.urgent, sv);
}

#define CHECK(field) \
    if (input_tuple1.Hdr.field != input_tuple.Hdr.field) { \
        std::cout << "NO MATCH: " # field << std::endl; \
    } else { \
        std::cout << "MATCH " << std::endl; \
    }

#ifdef COMPRESSOR

bool call_compressor(const char *packet, size_t packet_size, mcd_forward_fn forward) {

    if (packet_size < ETH_SIZE + UDP_SIZE + IPV4_SIZE) {
        std::cout << "Packet size too small!" << std::endl;
        return false;
    }

    input_tuples input_tuple;
    transfer_in(input_tuple, packet);
#ifdef HC_DEBUG
    std::cout << "COMPRESSOR I/P tuple "<< std::endl;
#endif
    tuple_eth &eth = input_tuple.Hdr.Eth;
#ifdef HC_DEBUG
    std::cout << "Eth type " << eth.Type.to_string(16) << std::endl;
    std::cout << "Eth Src " << eth.Src.to_string(16) << std::endl;
    std::cout << "Eth Dst " << eth.Dst.to_string(16) << std::endl;
#endif

    tuple_ipv4 &ipv4 = input_tuple.Hdr.Ipv4;
#ifdef HC_DEBUG
    std::cout << "IPv4 Version " << ipv4.version.to_string(16) << std::endl;
    std::cout << "IPv4 IHL " << ipv4.ihl.to_string(16) << std::endl;
    std::cout << "IPv4 diffserv " << ipv4.diffserv.to_string(16) << std::endl;
    std::cout << "IPv4 totallen " << ipv4.totallen.to_string(16) << std::endl;
    std::cout << "IPv4 ID " << ipv4.identification.to_string(16) << std::endl;
    std::cout << "IPv4 flags" << ipv4.flags.to_string(16) << std::endl;
    std::cout << "IPv4 frag" << ipv4.fragoffset.to_string(16) << std::endl;
    std::cout << "IPv4 TTL " << ipv4.ttl.to_string(16) << std::endl;
    std::cout << "IPv4 Protocol " << ipv4.protocol.to_string(16) << std::endl;
    std::cout << "IPv4 Checksum " << ipv4.hdrchecksum.to_string(16) << std::endl;
    std::cout << "IPv4 Src " << ipv4.srcAddr.to_string(16) << std::endl;
    std::cout << "IPv4 Dst " << ipv4.dstAddr.to_string(16) << std::endl;
#endif

    tuple_tcp &tcp = input_tuple.Hdr.Tcp;
#ifdef HC_DEBUG
    std::cout << "TCP Dst " << tcp.dport.to_string(16) << std::endl;
    std::cout << "TCP Src " << tcp.sport.to_string(16) << std::endl;
    std::cout << "TCP flags " << tcp.flags.to_string(16) << std::endl;
    std::cout << "TCP Window " << tcp.window.to_string(16) << std::endl;
    std::cout << "TCP Check " << tcp.check.to_string(16) << std::endl;
    std::cout << "TCP Urgent " << tcp.urgent.to_string(16) << std::endl;
#endif


    input_tuple.headerCompress_input.Stateful_valid = 1;
    input_tuple.Ioports.Egress_port = 0;
    input_tuple.Ioports.Ingress_port = 0;
    input_tuple.Local_state.Id = 0;
    input_tuple.Parser_extracts.Size = 0;
    input_tuple.CheckTcp.forward = 0;

    hls::stream<input_tuples> input_tuple_stream;
    input_tuple_stream.write(input_tuple);

    hls::stream<packet_interface> packet_input_stream;
    unsigned int n_words = DIVIDE_AND_ROUNDUP(packet_size, BYTES_PER_WORD);
    for (unsigned int i = 0; i < n_words; i++) {
        ap_uint<MEM_AXI_BUS_WIDTH> word = 0;
        for (int j = 0; j < BYTES_PER_WORD; j++) {
            word <<= 8;
            unsigned offset = BYTES_PER_WORD * i + j;
            if (offset < packet_size) {
                word |= (unsigned char)packet[offset];
            }
        }
        bool at_end = i == n_words - 1;
        packet_interface input;
        input.Data = word;
        input.Start_of_frame = i == 0;
        input.End_of_frame = at_end;
        input.Count = packet_size % BYTES_PER_WORD;
        if (input.Count == 0 || !at_end)
            input.Count = 8;
        input.Error = 0;
        packet_input_stream.write(input);
    }

    hls::stream<output_tuples> output_tuple_stream;
    hls::stream<packet_interface> packet_output_stream;

    Compressor(input_tuple_stream, output_tuple_stream, packet_input_stream, packet_output_stream);

    packet_interface output;

    int pkt_num = 0;
    while (1) {
        output_tuples output_tuple = output_tuple_stream.read();
        char output_packet[2048];
        memset(output_packet, 0, 2048);
        int packet_i = 0;
        do {
            output = packet_output_stream.read();
            for (int i = 0; i < output.Count; i++)
            {
                char Byte = (output.Data >> (8 * (BYTES_PER_WORD - i -1))) & 0xFF;
                output_packet[packet_i++] = Byte;

                memset(&Byte, 0 , sizeof(char));
            }
        } while (!output.End_of_frame);

        tuple_eth &oeth = output_tuple.Hdr.Eth;
#ifdef HC_DEBUG
        std::cout << "COMPRESSOR O/P tuple ";
        std::cout << "Eth type " << oeth.Type.to_string(16) << std::endl;
        std::cout << "Eth Src " << oeth.Src.to_string(16) << std::endl;
        std::cout << "Eth Dst " << oeth.Dst.to_string(16) << std::endl;
#endif

        tuple_ipv4 &oipv4 = output_tuple.Hdr.Ipv4;
#ifdef HC_DEBUG
        std::cout << "IPv4 Version " << oipv4.version.to_string(16) << std::endl;
        std::cout << "IPv4 IHL " << oipv4.ihl.to_string(16) << std::endl;
        std::cout << "IPv4 diffserv " << oipv4.diffserv.to_string(16) << std::endl;
        std::cout << "IPv4 totallen " << oipv4.totallen.to_string(16) << std::endl;
        std::cout << "IPv4 ID " << oipv4.identification.to_string(16) << std::endl;
        std::cout << "IPv4 flags" << oipv4.flags.to_string(16) << std::endl;
        std::cout << "IPv4 frag" << oipv4.fragoffset.to_string(16) << std::endl;
        std::cout << "IPv4 TTL " << oipv4.ttl.to_string(16) << std::endl;
        std::cout << "IPv4 Protocol " << oipv4.protocol.to_string(16) << std::endl;
        std::cout << "IPv4 Checksum " << oipv4.hdrchecksum.to_string(16) << std::endl;
        std::cout << "IPv4 Src " << oipv4.srcAddr.to_string(16) << std::endl;
        std::cout << "IPv4 Dst " << oipv4.dstAddr.to_string(16) << std::endl;
#endif

        tuple_tcp &otcp = output_tuple.Hdr.Tcp;
#ifdef HC_DEBUG
        std::cout << "TCP Dst " << otcp.dport.to_string(16) << std::endl;
        std::cout << "TCP Src " << otcp.sport.to_string(16) << std::endl;
        std::cout << "TCP flags " << otcp.flags.to_string(16) << std::endl;
        std::cout << "TCP Window " << otcp.window.to_string(16) << std::endl;
        std::cout << "TCP Check " << otcp.check.to_string(16) << std::endl;
        std::cout << "TCP Urgent " << otcp.urgent.to_string(16) << std::endl;
#endif

        transfer_out(output_tuple, output_packet);
        pkt_num++;

        forward(output_packet, packet_i, 0);//output_tuple.Hdr.Udp.sport == input_tuple.Hdr.Udp.dport);

        if (output_tuple.CheckTcp.forward != 1) {
            break;
        }
    }
    return true;
}

#else

bool call_decompressor(const char *packet, size_t packet_size, mcd_forward_fn forward) {

    if (packet_size < ETH_SIZE + UDP_SIZE + IPV4_SIZE) {
        std::cout << "Packet size too small!" << std::endl;
        return false;
    }

    input_tuples input_tuple;
    transfer_in(input_tuple, packet);

    tuple_eth &eth = input_tuple.Hdr.Eth;
#ifdef HC_DEBUG
    std::cout << "DECOMPRESSOR I/P tuple ";
    std::cout << "Eth type " << eth.Type.to_string(16) << std::endl;
    std::cout << "Eth Src " << eth.Src.to_string(16) << std::endl;
    std::cout << "Eth Dst " << eth.Dst.to_string(16) << std::endl;
#endif

    tuple_ipv4 &ipv4 = input_tuple.Hdr.Ipv4;
#ifdef HC_DEBUG
    std::cout << "IPv4 Version " << ipv4.version.to_string(16) << std::endl;
    std::cout << "IPv4 IHL " << ipv4.ihl.to_string(16) << std::endl;
    std::cout << "IPv4 ID " << ipv4.identification.to_string(16) << std::endl;
    std::cout << "IPv4 flags" << ipv4.flags.to_string(16) << std::endl;
    std::cout << "IPv4 frag" << ipv4.fragoffset.to_string(16) << std::endl;
    std::cout << "IPv4 TTL " << ipv4.ttl.to_string(16) << std::endl;
    std::cout << "IPv4 Protocol " << ipv4.protocol.to_string(16) << std::endl;
    std::cout << "IPv4 Checksum " << ipv4.hdrchecksum.to_string(16) << std::endl;
    std::cout << "IPv4 Src " << ipv4.srcAddr.to_string(16) << std::endl;
    std::cout << "IPv4 Dst " << ipv4.dstAddr.to_string(16) << std::endl;
#endif

    tuple_tcp &tcp = input_tuple.Hdr.Tcp;
#ifdef HC_DEBUG
    std::cout << "TCP Dst " << tcp.dport.to_string(16) << std::endl;
    std::cout << "TCP Src " << tcp.sport.to_string(16) << std::endl;
    std::cout << "TCP flags " << tcp.flags.to_string(16) << std::endl;
    std::cout << "TCP Window " << tcp.window.to_string(16) << std::endl;
    std::cout << "TCP Check " << tcp.check.to_string(16) << std::endl;
    std::cout << "TCP Urgent " << tcp.urgent.to_string(16) << std::endl;
#endif

    tuple_cmp &cmp = input_tuple.Hdr.Cmp;
#ifdef HC_DEBUG
    std::cout << "Cmp slotId " << cmp.slotID.to_string(10) << std::endl;
    std::cout << "Cmp totallen " << cmp.totallen.to_string(16) << std::endl;
    std::cout << "Cmp identification " << cmp.identification.to_string(16) << std::endl;
    std::cout << "Cmp flags " << cmp.flags.to_string(16) << std::endl;
    std::cout << "Cmp window " << cmp.window.to_string(16) << std::endl;
    std::cout << "Cmp check " << cmp.check.to_string(16) << std::endl;
    std::cout << "Cmp urgent " << cmp.urgent.to_string(16) << std::endl;
#endif

    input_tuple.headerDecompress_input.Stateful_valid = 1;
    input_tuple.Ioports.Egress_port = 0;
    input_tuple.Ioports.Ingress_port = 0;
    input_tuple.Local_state.Id = 0;
    input_tuple.Parser_extracts.Size = 0;
    input_tuple.CheckTcp.forward = 0;

    hls::stream<input_tuples> input_tuple_stream;
    input_tuple_stream.write(input_tuple);

    hls::stream<packet_interface> packet_input_stream;
    unsigned int n_words = DIVIDE_AND_ROUNDUP(packet_size, BYTES_PER_WORD);
    for (unsigned int i = 0; i < n_words; i++) {
        ap_uint<MEM_AXI_BUS_WIDTH> word = 0;
        for (int j = 0; j < BYTES_PER_WORD; j++) {
            word <<= 8;
            unsigned offset = BYTES_PER_WORD * i + j;
            if (offset < packet_size) {
                word |= (unsigned char)packet[offset];
            }
        }
        bool at_end = i == n_words - 1;
        packet_interface input;
        input.Data = word;
        input.Start_of_frame = i == 0;
        input.End_of_frame = at_end;
        input.Count = packet_size % BYTES_PER_WORD;
        if (input.Count == 0 || !at_end)
            input.Count = 8;
        input.Error = 0;
        packet_input_stream.write(input);
    }

    hls::stream<output_tuples> output_tuple_stream;
    hls::stream<packet_interface> packet_output_stream;

    Decompressor(input_tuple_stream, output_tuple_stream, packet_input_stream, packet_output_stream);

    packet_interface output;

    int pkt_num = 0;
    while (1) {
        output_tuples output_tuple = output_tuple_stream.read();
        char output_packet[2048];
        int packet_i = 0;
        do {
            output = packet_output_stream.read();
            for (int i = 0; i < output.Count; i++)
            {
                char Byte = (output.Data >> (8 * (BYTES_PER_WORD - i -1))) & 0xFF;
                output_packet[packet_i++] = Byte;
            }
        } while (!output.End_of_frame);

        transfer_out(output_tuple, output_packet);
        pkt_num++;

        tuple_eth &oeth = output_tuple.Hdr.Eth;
#ifdef HC_DEBUG
        std::cout << "DECOMPRESSOR O/P tuple";
        std::cout << "Eth type " << oeth.Type.to_string(16) << std::endl;
        std::cout << "Eth Src " << oeth.Src.to_string(16) << std::endl;
        std::cout << "Eth Dst " << oeth.Dst.to_string(16) << std::endl;
#endif

        tuple_ipv4 &oipv4 = output_tuple.Hdr.Ipv4;
#ifdef HC_DEBUG
        std::cout << "IPv4 Version " << oipv4.version.to_string(16) << std::endl;
        std::cout << "IPv4 IHL " << oipv4.ihl.to_string(16) << std::endl;
        std::cout << "IPv4 ID " << oipv4.identification.to_string(16) << std::endl;
        std::cout << "IPv4 flags" << oipv4.flags.to_string(16) << std::endl;
        std::cout << "IPv4 frag" << oipv4.fragoffset.to_string(16) << std::endl;
        std::cout << "IPv4 TTL " << oipv4.ttl.to_string(16) << std::endl;
        std::cout << "IPv4 Protocol " << oipv4.protocol.to_string(16) << std::endl;
        std::cout << "IPv4 Checksum " << oipv4.hdrchecksum.to_string(16) << std::endl;
        std::cout << "IPv4 Src " << oipv4.srcAddr.to_string(16) << std::endl;
        std::cout << "IPv4 Dst " << oipv4.dstAddr.to_string(16) << std::endl;
#endif

        tuple_tcp &otcp = output_tuple.Hdr.Tcp;
#ifdef HC_DEBUG
        std::cout << "TCP Dst " << otcp.dport.to_string(16) << std::endl;
        std::cout << "TCP Src " << otcp.sport.to_string(16) << std::endl;
        std::cout << "TCP flags " << otcp.flags.to_string(16) << std::endl;
        std::cout << "TCP Window " << otcp.window.to_string(16) << std::endl;
        std::cout << "TCP Check " << otcp.check.to_string(16) << std::endl;
        std::cout << "TCP Urgent " << otcp.urgent.to_string(16) << std::endl;
#endif

        forward(output_packet, packet_i, 0);//output_tuple.Hdr.Udp.sport == input_tuple.Hdr.Udp.dport);

        if (output_tuple.CheckTcp.forward != 1) {
            break;
        }
    }
    return true;
}

#endif

/**
 * @brief Forwards the provided frame to the configured output pcap handle.
 *
 * @param[in] packet Packet data to be send on the output interface
 * @param[in] len Size of the provided packet
 */
void forward_frame(const void * packet, int len, int reverse) {
    if (NULL != output_handle) {
        pcap_inject(output_handle, packet, len);
    } else {
        pcap_inject(pcap, packet, len);
    }
}


int main(int argc, char *argv[]){
    int opt = 0;
    char *if_name = nullptr;
    char *oif_name = nullptr;
    char *opt_flow = nullptr;
    while ((opt =  getopt(argc, argv, "i:o:f:")) != EOF)
    {
        switch (opt)
        {
            case 'i':
                if_name = optarg;
                break;
            case 'o':
                oif_name = optarg;
                break;
            case 'f':
                opt_flow = optarg;
                flow = atoi(opt_flow);
                if(flow == 0)
                    printf("\nPacket Flow is to Compressor booster \n");
                else if(flow == 1)
                    printf("\nPacket Flow is to Decompressor booster \n");
                break;
            default:
                printf("\nNot yet defined opt = %d\n", opt);
                abort();
        }
    }
    cout << "booster running on interface: " << if_name << endl;

    char pcap_errbuf[PCAP_ERRBUF_SIZE];
    pcap_errbuf[0]='\0';
    pcap=pcap_open_live(if_name,MTU,1,0,pcap_errbuf);
    if (pcap_errbuf[0]!='\0') {
        fprintf(stderr,"%s",pcap_errbuf);
    }
    if (!pcap) {
        exit(1);
    }

    char output_errbuf[PCAP_ERRBUF_SIZE];
    output_errbuf[0]='\0';
    if(oif_name != nullptr)
        output_handle = pcap_open_live(oif_name, MTU, 0, 0, output_errbuf);
    if(output_handle == NULL) {
        fprintf(stderr,"%s:%s",oif_name, output_errbuf);  
    }

    switch(flow) {
        case 0:
#ifndef COMPRESSOR
            cerr << "Used compressor flow for Decompressor binary. EXITING!";
            return 1;
#endif
            // start packet processing loop for compress.
            if (pcap_loop(pcap, 0, compressHandler, NULL) < 0) {
                cerr << "pcap_loop() failed: " << pcap_geterr(pcap);
                return 1;
            }
            break;
        case 1:
#ifdef COMPRESSOR
            cerr << "Used decompressor flow for Compressor binary. EXITING!";
            return 1;
#endif
            // start packet processing loop for decompress.
            if (pcap_loop(pcap, 0, decompressHandler, NULL) < 0) {
                cerr << "pcap_loop() failed: " << pcap_geterr(pcap);
                return 1;
            }
            break;
        default:
            cerr << "Invalid flow option. EXITING!";
            return 1;
    }
    return 0;
}

void compressHandler(u_char *userData, const struct pcap_pkthdr* pkthdr, const u_char* packet) {
#ifdef COMPRESSOR
    call_compressor((const char*)packet, pkthdr->len, forward_frame);
#endif
    return;
}

void decompressHandler(u_char *userData, const struct pcap_pkthdr* pkthdr, const u_char* packet) {
#ifndef COMPRESSOR
    call_decompressor((const char*)packet, pkthdr->len, forward_frame);
#endif
    return;
}

