#!/usr/bin/env python
# Run quick tests which create and parse packet with
# pytest -s flightplan_packet.py

from scapy.all import *
from argparse import ArgumentParser

class FPPacket(Packet):

    VERSION_SIZE=4
    SEGMENT_DESC_SIZE=4

    name = "FlightplanPacket"

    fields_desc = [
            BitField("version", 0x0, VERSION_SIZE),
            XBitField("enc_eth_type", 0x0, 16),
            BitField("from_segment", 0x0, SEGMENT_DESC_SIZE),
            BitField("to_segment", 0x0, SEGMENT_DESC_SIZE),
            BitField("pad", 0x0, 4)
    ]

    def guess_payload_class(self, payload):
        return FPRcv1

class FPRcv(Packet):

    name = "FlightplanReceive"

    SEQ_WIDTH=32

    fields_desc = [ByteField("Byte_%d" % i, 0x0) for i in range(1,9)] + \
        [BitField("seqno", 0x0, SEQ_WIDTH),
         BitField("ack", 0x0, 1),
         BitField("nak", 0x0, 1),
         BitField("pad", 0x0, 6)]

    _payload_class = None

    def guess_payload_class(self, payload):
        return self._payload_class

class FPSnd2(FPRcv):
    name = "FlightPlanSend2"

class FPSnd1(FPRcv):
    name = "FlightPlanSend1"
    _payload_class = FPSnd2

class FPRcv2(FPRcv):
    name = "FlightPlanReceive2"
    _payload_class = FPSnd1

class FPRcv1(FPRcv):
    name = "FlightPlanReceive1"
    _payload_class = FPRcv2

def build_fp_packet():
    return Ether(src="AA:BB:CC:DD:EE:FF") / \
            FPPacket(version=0xA,
                     enc_eth_type=0xABCD,
                     from_segment=1) / \
            FPRcv1(seqno=1)
            #FPRcv2(seqno=2) / \
            #FPSnd1(seqno=3) / \
            #FPSnd2(seqno=4)



bind_layers(Ether, FPPacket, type=0x2222)


def test_show_packet():
    (Ether()/FPPacket()/FPRcv()).show()

def test_str_packet():
    print("As Bytes:")
    hexdump(Ether()/FPPacket()/FPRcv())

def test_whole_packet():
    build_fp_packet().show()

def test_parse_packet():
    raw = bytes(build_fp_packet())

    pkt = Ether(raw)
    pkt.show()


def send_packet(iface, n):
    pkt = build_fp_packet()

    for i in range(n):
        sendp(pkt, iface=iface)

if __name__ == "__main__":
    parser = ArgumentParser("Sends flightplan packets on specified interface")
    parser.add_argument("iface")
    parser.add_argument('n', nargs='?', default=10)
    args = parser.parse_args()

    send_packet(args.iface, args.n)
