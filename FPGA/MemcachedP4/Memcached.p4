@Xilinx_MaxLatency(200)
extern void memcached(out bit<1> forward);

#if 0
control CheckCache(inout headers_t hdr, inout switch_metadata_t ioports)
{
	apply {
		bit<1> forward = 0;
		if (hdr.udp.isValid()) {
			if (hdr.udp.dport == 11211) {
				memcached(forward); // FIXME check "forward" output value.
			}
		}
	}
}
#endif
