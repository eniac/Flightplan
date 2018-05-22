@Xilinx_MaxLatency(200)
extern void memcached(out bit<1> forward);

typedef bit<32> Ipv4Address;

#define ETHERTYPE_IPV4 0x0800
#define PROTOCOL_UDP 0x11

header ipv4_t{
	bit<4> version;
	bit<4> ihl;
	bit<8> diffserv;
	bit<16> totallen;
	bit<16> identification;
	bit<3> flags;
	bit<13> fragoffset;
	bit<8> ttl;
	bit<8> protocol;
	bit<16> hdrchecksum;
	Ipv4Address srcAddr;
	Ipv4Address dstAddr;	
}

header udp_h{
	bit<16> sport;
	bit<16> dport;
	bit<16> len;
	bit<16> chksum;
}

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
