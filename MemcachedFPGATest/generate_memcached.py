from __future__ import print_function
from scapy.all import *
import json
import memcached_hash as mcdh
import argparse
import struct
import random
import time
import dpkt
import numpy.random
import numpy as np

class PacketGenerator:

    SET_SYNTAX = '{cmd} {key} 0 0 {bytes} \r\n{payload}\r\n'
    GET_SYNTAX = '{cmd} {key}\r\n'

    def __init__(self, src_mac, dst_mac, src_ip, dst_ip, sport = 12345, dport = 11211, val_len=512):
        self.get_hdr = Ether(src=src_mac, dst=dst_mac)/IP(src=src_ip, dst=dst_ip)/UDP(sport=sport, dport=dport,chksum=0)
        self.set_hdr = Ether(src=src_mac, dst=dst_mac)/IP(src=src_ip, dst=dst_ip)/UDP(sport=sport, dport=dport,chksum=0)
        self.get_hdr_bytes = None
        self.set_hdr_bytes = None
        random.seed(time.time())
        self.val_len = val_len
        self.possible_ids = set(range(65536))
        self.used_set_ids = defaultdict(set)
        self.used_get_ids = defaultdict(set)


    def hdr(self, key, used_ids):
        # Try 10 random keys before having to compute set difference
        for _ in range(10):
            id = random.randint(0, 65535)
            # Try the fast-path (randomness) first
            if id not in used_ids[key]:
                used_ids[key].add(id)
                break
        else:
            unused_ids = self.possible_ids.difference(used_ids[key])
            if len(unused_ids) > 0:
                id = random.sample(unused_ids, 1)[0]
                used_ids[key].add(id)
            else:
                print("Reusing for key {}".format(key))
                id = random.randint(1, 65535)


        h = b''.join([struct.pack(">H", x) for x in [id, 0, 1, 0]])
        return h

    def set(self, key):
        key = "{:08d}".format(key)

        load = (key + '-') * (self.val_len)
        load = load[:self.val_len]

        load = bytes(self.hdr(key, self.used_set_ids) +
                      self.SET_SYNTAX.format(cmd='set', key=key, bytes=self.val_len, payload=load))

        if self.set_hdr_bytes is None:
            self.set_hdr[IP].len = len(load) + 28
            self.set_hdr[UDP].len = len(load) + 8
            self.set_hdr_bytes = bytes(self.set_hdr)

        return self.set_hdr_bytes + load

    def get(self, key):
        key = "{:08d}".format(key)

        load = bytes(self.hdr(key, self.used_get_ids) +
                     self.GET_SYNTAX.format(cmd='get', key=key))

        if self.get_hdr_bytes is None:
            self.get_hdr[IP].len = len(load) + 28
            self.get_hdr[UDP].len = len(load) + 8
            self.get_hdr_bytes = bytes(self.get_hdr)

        return self.get_hdr_bytes + load

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--out', type=str, required=True, help="pcap file to write output to")
    parser.add_argument('--n-get', type=int, required=True, help="Number of get packets")
    parser.add_argument('--n-set', type=int, required=True, help="Number of set packets")
    parser.add_argument('--smac', type=str, default='00:00:00:00:00:00', help="Source MAC")
    parser.add_argument('--dmac', type=str, default='00:00:00:00:00:00', help="Dst MAC")
    parser.add_argument('--sip', type=str, default='127.0.0.1', help="Source IP")
    parser.add_argument('--dip', type=str, default='127.0.0.1', help="Dst IP")
    parser.add_argument('--warmup-out', type=str, default=None, help="Pcap file to write cache warmup to")
    parser.add_argument('--key-space', type=int, default=500000, help="Space of keys")
    parser.add_argument('--zipf', type=float, default=.9, help="zipf coeeficient for gets")
    args = parser.parse_args()

    if args.out is None and args.iface is None:
        raise Exception("Must provide either output file or interface")

    return args

def zipf_freq(k, beta):
    return (1/k**beta)

def generate_packets(n_get, n_set, smac, dmac, sip, dip, key_space, zipf_coef):
    pkt_gen = PacketGenerator(smac, dmac, sip, dip)

    max_n_keys = n_get + n_set

    all_keys = np.arange(1, key_space+1)

    zipf_freqs = zipf_freq(all_keys, zipf_coef)
    zipf_freqs /= sum(zipf_freqs)

    get_keys = np.random.choice(all_keys, n_get, p=zipf_freqs)

    warmup_keys = sorted(list(set(get_keys)))[::-1]

    set_keys = np.random.choice(all_keys, n_set)

    pkts = []
    for key in get_keys:
        pkts.append(pkt_gen.get(key))

    for key in set_keys:
        pkts.append(pkt_gen.set(key))

    random.shuffle(pkts)

    warmup_pkts = []
    for key in warmup_keys:
        warmup_pkts.append(pkt_gen.set(key))

    return pkts, warmup_pkts

def write_pkts(pkts, output):
    with open(output, 'w') as f:
        writer = dpkt.pcap.Writer(f)
        for pkt in pkts:
            writer.writepkt(pkt)
        writer.close()


def main(args):
    pkts, warmup_pkts = generate_packets(args.n_get, args.n_set,
                                      args.smac, args.dmac, args.sip, args.dip,
                                      args.key_space, args.zipf)
    if args.warmup_out:
        write_pkts(warmup_pkts, args.warmup_out)

    write_pkts(pkts, args.out)


if __name__ == "__main__":
    args = parse_args()
    main(args)
