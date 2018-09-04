#include "MemHLS.h"

bool call_memcached(char *packet, size_t packet_size, char *udp_bits, char *ipv4_bits, char *eth_bits) {
    tuple_udp *udp = (tuple_udp*)udp_bits;
    tuple_ipv4 *ipv4 = (tuple_ipv4*)ipv4_bits;
    tuple_eth *eth = (tuple_eth*)eth_bits;

    input_tuples input_tuple;
    input_tuple.Hdr.Udp = *udp;
    input_tuple.Hdr.Ipv4 = *ipv4;
    input_tuple.Hdr.Eth = *eth;

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
                word |= packet[offset];
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

    Memcore(input_tuple_stream, output_tuple_stream, packet_input_stream, packet_output_stream);

    packet_interface output;
    int packet_i = 0;
    do {
        output = packet_output_stream.read();
        for (int i = 0; i < output.Count; i++) {
            char byte = (output.Data >> ( 8 * (BYTES_PER_WORD - i - 1))) && 0XFF;
            packet[++packet_i] = byte;
        }
    } while (!output.End_of_frame);

    output_tuples output_tuple = output_tuple_stream.read();
    memcpy(udp_bits, &output_tuple.Hdr.Udp, sizeof(*udp));
    memcpy(ipv4_bits, &output_tuple.Hdr.Ipv4, sizeof(*ipv4));
    memcpy(eth_bits, &output_tuple.Hdr.Eth, sizeof(*eth));
    return false;
}
