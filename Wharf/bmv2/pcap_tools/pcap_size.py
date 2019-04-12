from scapy.all import *
import sys

if len(sys.argv) < 2:
    print("Usage %s INPUT_FILE [OUTPUT_FILE]" % sys.argv[0])
    exit(-1)

sizes = []

for i, filename in enumerate(sys.argv[1:]):
    size = 0
    for pkt in rdpcap(open(filename, 'rb')):
        size+=len(pkt)

    sizes.append(size)

    if i > 0:
        print("%s %d bytes (%.2f%%)" % (filename, size, 100*float(size) / sizes[0] if sizes[0] > 0 else -1))
    else:
        print("%s %d bytes" % (filename, size))


