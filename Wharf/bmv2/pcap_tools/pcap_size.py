from scapy.all import *
import sys

if len(sys.argv) < 2:
    print("Usage %s INPUT_FILE [OUTPUT_FILE]" % sys.argv[0])
    print("returns 0 if the first two files are identically sized")
    exit(-1)

sizes = []

for i, filename in enumerate(sys.argv[1:]):
    size = 0
    n = 0
    for pkt in rdpcap(open(filename, 'rb')):
        size+=len(pkt)
        n += 1

    sizes.append(size)

    if i > 0:
        print("%s %d pkts, %d bytes (%.2f%%)" % (filename, n, size, 100*float(size) / sizes[0] if sizes[0] > 0 else -1))
    else:
        print("%s %d pkts, %d bytes" % (filename, n, size))

if sizes[0] == sizes[1]:
    exit(0)
exit(1)
