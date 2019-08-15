@Xilinx_MaxLatency(1000)
extern void headerCompress(out bit<1> forward);

control CheckTcp(inout headers_t hdr, inout switch_metadata_t ioports)
{
	apply {
		bit<1> forward = 0;
		if (hdr.tcp.isValid()) {
			headerCompress(forward); 
		}
	}
}
