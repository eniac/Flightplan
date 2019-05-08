from __future__ import print_function
from scapy.all import *
import yaml
import sys
from collections import defaultdict
from itertools import permutations
from argparse import ArgumentParser

def load_paths(topo_file, endpoint_sets):

    topo = yaml.load(open(topo_file))

    hosts = []
    connections = defaultdict(set)
    all_links = set()

    for host, ops in topo['hosts'].items():
        hosts.append(host)
        for iface in ops.get('interfaces', []):
            if 'link' in iface:
                connections[host].add(iface['link'])
                connections[iface['link']].add(host)
                all_links.add((iface['link'], host))
                all_links.add((host, iface['link']))

    for sw, ops in topo['switches'].items():
        for iface in ops.get('interfaces', []):
            if 'link' in iface:
                connections[sw].add(iface['link'])
                connections[iface['link']].add(sw)
                all_links.add((iface['link'], sw))
                all_links.add((sw, iface['link']))

    paths = {}

    for endpoints in endpoint_sets:
        for h2, h1 in zip(endpoints, endpoints[1:]):
            used_links = set()
            dists = {l: 999 for l in connections}
            prev = {l: '' for l in connections}

            dists[h1] = 0
            unused_links = set(connections.keys())

            while len(unused_links) > 0:
                cur = [h for h in unused_links if dists[h] == min([dists[x] for x in unused_links])][0]

                unused_links.remove(cur)

                for conn in connections[cur]:
                    alt = dists[cur] + 1
                    if alt < dists[conn]:
                        dists[conn] = alt
                        prev[conn] = cur
            paths[(h2, h1)] = prev

    to_show = defaultdict(list)
    unshown_links = connections.copy()

    for (h1, h2), path in paths.items():
        to_show[(h1, h2)].append((h1, path[h1]))
        if path[h1] in unshown_links[h1]:
            unshown_links[h1].remove(path[h1])
        u = path[h1]
        while u != h2:
            to_show[(h1, h2)].append((u, path[u]))
            if path[u] in unshown_links[u]:
                unshown_links[u].remove(path[u])
            u = path[u]

    return to_show

def show_size(n1, n2, sizes, out_dir):
    filename = os.path.join(out_dir, '{}_to_{}.pcap'.format(n1, n2))
    size = 0
    n = 0

    for pkt in rdpcap(open(filename, 'rb')):
        size += len(pkt)
        n += 1

    sizes.append(size)

    if len(sizes) > 1:
        print("%s %d pkts, %d bytes (%.2f%%)" % (filename, n, size, 100*float(size) / sizes[0] if sizes[0] > 0 else float('nan')))
    else:
        print("%s %d pkts, %d bytes" % (filename, n, size))


def main(topo_file, pcap_dir, endpoint_sets):
    to_show = load_paths(topo_file, endpoint_sets)

    for endpoints in endpoint_sets:
        print(endpoints[0]+" ", end='')
        for h1, h2 in zip(endpoints, endpoints[1:]):
            path = to_show[(h1, h2)]
            for p1, _ in path[1:]:
                print("-> {} ".format(p1), end='')
            print("-> {} ".format(h2), end='')
        print()
        sizes = []
        for h1, h2 in zip(endpoints, endpoints[1:]):
            for i, (n1, n2) in enumerate(to_show[(h1, h2)]):
                show_size(n1, n2, sizes, pcap_dir)

if __name__ == '__main__':
    parser = ArgumentParser()
    parser.add_argument("topology")
    parser.add_argument("pcap_dir")
    parser.add_argument("endpoints", nargs="+", help="Endpoints to hit on traversal")
    args = parser.parse_args()

    main(args.topology, args.pcap_dir, [args.endpoints])
