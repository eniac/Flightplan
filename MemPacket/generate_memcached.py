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

    def __init__(self, src_mac, dst_mac, src_ip, dst_ip, sport = 12345, dport = 11211):

        self.Pkt = bytes(Ether(src=src_mac, dst=dst_mac)/IP(src=src_ip, dst=dst_ip)/UDP(sport=sport, dport=dport))
        random.seed(time.time())
        self.cur_id = random.randint(0, 100)

    def hdr(self):
        h = b''.join([struct.pack(">H", x) for x in [self.cur_id, 0, 1, 0]])
        self.cur_id+= 1
        self.cur_id %= 65535
        return h

    def set(self, key, nbytes=512):
        key = "{:}".format(key)

        load = (key + '-') * (nbytes)
        load = load[:nbytes]

        pkt = self.Pkt + bytes(self.hdr() + self.SET_SYNTAX.format(cmd='set', key=key, bytes=nbytes, payload=load))

        return pkt

    def get(self, key):

        return self.Pkt + bytes(self.hdr() + self.GET_SYNTAX.format(cmd='get', key=key))

def send_and_show(pkt, iface):
    print("Sending: {}".format(pkt.load[8:]))
    a = srp1(pkt, iface=iface)
    print("Received: {}".format(a.load[8:]))

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--smac', type=str, default='00:00:00:00:00:00', help="Source MAC")
    parser.add_argument('--dmac', type=str, default='00:00:00:00:00:00', help="Dst MAC")
    parser.add_argument('--sip', type=str, default='127.0.0.1', help="Source IP")
    parser.add_argument('--dip', type=str, default='127.0.0.1', help="Dst IP")
    parser.add_argument('--iface', type=str, default=None, help="Interface on which to play traffic")
    parser.add_argument('--wait-resp', action='store_true', help="Wait for responses")
    parser.add_argument('--out', type=str, default=None, help="pcap file to write output to")
    parser.add_argument('--n-pkt', type=int, default=None, help="Total number of packets")
    parser.add_argument('--n-get', type=int, default=None, help="Number of get packets (if n-pkt not set)")
    parser.add_argument('--n-set', type=int, default=None, help="Number of set packets (if n-pkt not set)")
    parser.add_argument('--get-pct', type=float, default=.95, help="Percentage of packets that are GETs")
    parser.add_argument('--collision-prob', type=float, default=.05, help="Probability of collision")
    parser.add_argument('--pre-set', action='store_true', help='Perform all SETs before any gets')
    parser.add_argument('--set-out', type=str, default=None, help='if --pre-set, saves SETs to separate file')
    parser.add_argument('--set-sip', type=str, default=None, help='if --pre-set, SET packets have source IP')
    parser.add_argument('--hashlog', type=str, default=None, help="Log hash values for later processing")
    parser.add_argument('--uniform-random', action='store_true', help='Sample keys uniformly when getting')
    parser.add_argument('--zipf-random', type=float, default=None, help='Sample keys as zipf when getting')

    args = parser.parse_args()
 
    if args.out is None and args.iface is None:
        raise Exception("Must provide either output file or interface")

    return args

def zipf_freq(k, beta):
    return (1/k**beta)

def generate_packets(smac, dmac, sip, dip, n_pkt, n_get, n_set, get_pct, collision_prob,
                     set_sip, iface, pre_set, uniform_random, zipf_random):
    gen = PacketGenerator(smac, dmac, sip, dip)
    if set_sip:
        set_gen = PacketGenerator(smac, dmac, set_sip, dip)
    else:
        set_gen = gen
    log = []

    if n_pkt is not None:
        n_get = int(n_pkt * get_pct)
        n_set = int(n_pkt * ( 1 - get_pct))
    else:
        n_get = n_get
        n_set = n_set

    if n_set == 0:
        n_set = 1
        print("Ratio too low! Setting N_SET to 1")

    if pre_set:
        n_collisions = int(n_get * collision_prob)
        n_non_collisions = n_get - n_collisions

        # Hash -> [key_idx, key2_idx, ...]
        hashes = defaultdict(list)
        sets = []

        if collision_prob > .95:
            gtor = mcdh.gen_mostly_collisions(n_set)
        else:
            gtor = mcdh.gen_hashes(n_set)

        for i, (k, h) in enumerate(gtor):
            sets.append(k)
            hashes[h].append(i)

        multi_hashes = {k:v for k, v in hashes.items() if len(v) > 1}

        pkts = []
        for key in sets:
            pkts.append(set_gen.set(key))
            log.append(dict(type='set', h=mcdh.str_hash(key), k=key))

        hit_hash_keys = hashes.keys()
        miss_hash_keys = multi_hashes.keys()

        safe_hit_hash_keys = set(hashes.keys())
        safe_miss_hash_keys = set(multi_hashes.keys())
        used_hash_keys = []

        if zipf_random is not None:
            zipf_freqs = np.array([zipf_freq(n_set - i, zipf_random) for i in range(n_set)])
            zipf_freqs /= sum(zipf_freqs)

            keys = numpy.random.choice(sets, n_get, p=zipf_freqs)

            for i, key in enumerate(keys):
                if i % (n_get / 10) == 0:
                    print('%d...' % len(pkts), end='')
                    sys.stdout.flush()
                pkts.append(gen.get(key))
                log.append(dict(type='get', h=mcdh.str_hash(key), k=key, idx=i))
        else:
            print("n_get is %d n_set %d" % (n_get, len(pkts)))
            for i in range(n_get):
                if i % (n_get / 10) == 0:
                    print('%d,' % len(pkts), end='')
                    sys.stdout.flush()

                if uniform_random:
                    key = random.choice(sets)
                    pkts.append(gen.get(key))
                    log.append(dict(type='get', h = mcdh.str_hash(key), k=key, collide='?', idx=i))
                else:
                    do_collide = random.random() < collision_prob
                    if do_collide:
                        h = random.choice(list(safe_miss_hash_keys))
                        idx = hashes[h][0]
                        del hashes[h][0]
                        hashes[h].append(idx)
                        pkts.append(gen.get(sets[idx]))
                        log.append(dict(type='get', h = mcdh.str_hash(sets[idx]), k=sets[idx], collide=True, idx=i))

                        safe_hit_hash_keys.remove(h)
                        safe_miss_hash_keys.remove(h)
                    else:
                        h = random.choice(list(safe_hit_hash_keys))
                        idx = hashes[h][-1]
                        pkts.append(gen.get(sets[idx]))
                        log.append(dict(type='get', h = mcdh.str_hash(sets[idx]), k=sets[idx], collide=False, idx=i))

                        if h in safe_miss_hash_keys:
                            safe_miss_hash_keys.remove(h)
                        safe_hit_hash_keys.remove(h)

                used_hash_keys.append(h)
                if i >= 500:
                    reuse_hash = used_hash_keys[i-250]
                    if reuse_hash in miss_hash_keys:
                        safe_miss_hash_keys.add(reuse_hash)
                    safe_hit_hash_keys.add(reuse_hash)

    else:

        if zipf_random is not None:
            zipf_freqs = np.array([zipf_freq(n_set - i, zipf_random) for i in range(n_set)])
            zipf_freqs /= sum(zipf_freqs)

        total_n = n_get + n_set
        inter_set = n_get / n_set

        # Hash -> [key1, key2, ...]
        hashes = defaultdict(list)
        non_collisions = set()
        collisions = set()
        pkts = []
        gets_placed = 0

        if collision_prob > .95:
            gentor = mcdh.gen_mostly_collisions(n_set * 1000)
        else:
            gentor = mcdh.gen_hashes(n_set * 2)

        for i, (k, h) in enumerate(gentor):
            if i % (n_set / 10) == 0:
                print('%d,' % len(pkts), end='')
                sys.stdout.flush()
            hashes[h].append(k)

            old_ks = set(hashes[h][:-1])
            non_collisions -= old_ks
            collisions |= old_ks
            non_collisions.add(k)

            pkts.append(gen.set(k))
            log.append(dict(type='set', h=mcdh.str_hash(k), k=k))

            for _ in range(int(inter_set)):
                collide = random.uniform(0, 1)
                if zipf_random is not None:
                    key = numpy.random.choice(sets, 1, p=zipf_freqs)[0]
                elif uniform_random:
                    key = random.choice(collisions | non_collisions, 1)[0]
                else:
                    if collide < collision_prob:
                        if len(collisions) > 0:
                            key = random.sample(collisions, 1)[0]

                            h2 = mcdh.str_hash(key)

                            if h2 not in hashes:
                                print("Bad things afoot!")

                            # Move this key to the front of the list
                            hashes[h2].remove(key)
                            hashes[h2].append(key)

                            old_ks = set(hashes[h2][:-1])
                            non_collisions -= old_ks
                            collisions |= old_ks
                            non_collisions.add(key)

                        else:
                            continue
                    else:
                        key = random.sample(non_collisions, 1)[0]
                pkts.append(gen.get(key))
                log.append(dict(type='get', h=mcdh.str_hash(key), k=key))
                gets_placed += 1
                if gets_placed >= n_get:
                    break

            if gets_placed >= n_get:
                break

    if iface:
        for pkt in pkts:
            if 'set' in pkt.load:
                sendp(pkt, iface=iface)
            else:
                send_and_show(pkt, iface)

    return pkts, log

def write_pkt_group(pkts, out):
    with open(out, 'w') as f:
        writer = dpkt.pcap.Writer(f)
        for pkt in pkts:
            writer.writepkt(pkt)
        writer.close()


def write_pkts(args, pkts, log):
    if args.out:
        print("Writing output")
        if not args.set_out:
            write_pkt_group(pkts, args.out)
        else:
            sets = [pkt for pkt in pkts if 'set' in pkt]
            gets = [pkt for pkt in pkts if 'get' in pkt]
            # I apologize for creating the packet in scapy, then writing it
            # with dpkt. scapy was too slow to write packets
            write_pkt_group(gets, args.out)

            print("Writing sets")
            write_pkt_group(sets, args.set_out)

    if args.hashlog:
        with open(args.hashlog, 'w') as f:
            print("Writing hashlog")
            json.dump(log, f, indent=2)


if __name__ == "__main__":
    args = parse_args()
    pkts, log = generate_packets(
            args.smac, args.dmac, args.sip, args.dip,
            args.n_pkt, args.n_get, args.n_set, args.get_pct,
            args.collision_prob, args.set_sip, args.iface, args.pre_set,
            args.uniform_random, args.zipf_random)
    write_pkts(args, pkts, log)
