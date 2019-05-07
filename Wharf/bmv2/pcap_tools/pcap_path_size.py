from __future__ import print_function
from scapy.all import *
import yaml
import sys
from collections import defaultdict
from itertools import permutations

if len(sys.argv) < 3:
    print("Usage %s TOPOLOGY_FILE OUT_DIR" % sys.argv[0])
    exit(-1)

def load_paths(topo_file):

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

    for h1, h2 in permutations(hosts, 2):
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

    def insert_unshown(n, path, i):
        for i2, n3 in enumerate(list(unshown_links[n]), i):
            path.insert(i2, (n, n3))
            unshown_links[n].remove(n3)
            insert_unshown(n3, path, i2+1)

    for ends, path in sorted(to_show.items(), key = lambda e: e[0]):
        for i, (n1, _) in enumerate(path[:]):
            insert_unshown(n1, path, i)

    return to_show

def show_size(i, n1, n2, sizes, out_dir):
    filename = os.path.join(out_dir, '{}_to_{}.pcap'.format(n1, n2))
    size = 0
    n = 0

    for pkt in rdpcap(open(filename, 'rb')):
        size += len(pkt)
        n += 1

    sizes.append(size)

    if i > 0:
        print("%s %d pkts, %d bytes (%.2f%%)" % (filename, n, size, 100*float(size) / sizes[0] if sizes[0] > 0 else float('nan')))
    else:
        print("%s %d pkts, %d bytes" % (filename, n, size))


def main(topo_file, pcap_dir):
    to_show = load_paths(topo_file)

    for ends, path in sorted(to_show.items(), key = lambda e: e[0]):
        for p1, _ in path:
            print("{} -> ".format(p1), end='')
        print(ends[1])
        sizes = []
        for i, (n1, n2) in enumerate(path):
            show_size(i, n1, n2, sizes, pcap_dir)

main(sys.argv[1], sys.argv[2])
