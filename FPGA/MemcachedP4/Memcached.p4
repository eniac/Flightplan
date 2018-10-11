#include "Memcached_extern.p4"

@Xilinx_MaxLatency(1000)
extern void memcached(out bit<1> forward);

control CheckCache(inout headers_t hdr, inout switch_metadata_t ioports)
{
	apply {
		bit<1> forward = 0;
		if (hdr.udp.isValid()) {
			if (hdr.udp.dport == 11211 || hdr.udp.sport == 11211) {
				memcached(forward); // FIXME check "forward" output value.
			}
		}
	}
}
