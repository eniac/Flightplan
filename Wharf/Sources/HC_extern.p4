@Xilinx_MaxLatency(200)
extern void header_compress(out bit<1> forward);

@Xilinx_MaxLatency(200)
extern void header_decompress(out bit<1> forward);

@Xilinx_MaxLatency(100) // FIXME fudge
extern void get_port_link_compression(in bit<PORT_SIZE> port_number, out bit<1> compressed);
