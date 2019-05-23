#!/usr/bin/env python

from scapy.all import *
from argparse import ArgumentParser

class FPPacket(Packet):
    SEGMENT_DESC_SIZE=4

    name = "FlightplanPacket"

    fields_desc = [
            DestMACField("dst"),
            SourceMACField("src"),
            XShortEnumField("type", 0x0, []),

            BitField("from_segment", 0x0, SEGMENT_DESC_SIZE),
            BitField("to_segment", 0x0, SEGMENT_DESC_SIZE),

            BitField("byte1", 0x0, 8),
            BitField("byte2", 0x0, 8),
            BitField("byte3", 0x0, 8),
            BitField("byte4", 0x0, 8),
            BitField("byte5", 0x0, 8),
            BitField("byte6", 0x0, 8),
            BitField("byte7", 0x0, 8),
            BitField("byte8", 0x0, 8),
            BitField("byte9", 0x0, 8),
            BitField("byte10", 0x0, 8),
            BitField("byte11", 0x0, 8),
            BitField("byte12", 0x0, 8),
            BitField("byte13", 0x0, 8),
            BitField("byte14", 0x0, 8),
            BitField("byte15", 0x0, 8),
            BitField("byte16", 0x0, 8),
            BitField("byte17", 0x0, 8)
    ]

    _payload_class = None

    def guess_payload_class(self, payload):
        return self._payload_class

if __name__ == "__main__":
    parser = ArgumentParser("Encapsulates packets with Flightplan header")
    parser.add_argument("input")
    parser.add_argument("output")
    args = parser.parse_args()

    input_pcap = rdpcap(args.input)
    for pkt in input_pcap:
        if pkt.haslayer(Ether):
            fp = FPPacket(dst=pkt.getlayer(Ether).dst, src=pkt.getlayer(Ether).src, type=pkt.getlayer(Ether).type)
            new_pkt = fp/pkt
            wrpcap(args.output, new_pkt, append=True)
        else:
            raise Exception("Input pcap contained a non-Ethernet packet")
