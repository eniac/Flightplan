from __future__ import print_function
import sys
from scapy.all import *
import argparse
import difflib

parser = argparse.ArgumentParser()
parser.add_argument('input', type=str)
parser.add_argument('output', type=str)
parser.add_argument('--show', type=int, required=False, default=0)
parser.add_argument('--diff', type=int, required=False, default=0)
args = parser.parse_args()

def strrep(pkt):
    try:
        return str(pkt)[0:14 + pkt[IP].len]
    except:
        return str(pkt)

in_cap = rdpcap(args.input)
out_cap = rdpcap(args.output)

out_strs = [strrep(o) for o in out_cap]

missing_pkts = []

for i, pkt in enumerate(in_cap):

    in_str = strrep(pkt)

    if in_str not in out_strs:
        missing_pkts.append(i)
    else:
        out_strs[out_strs.index(in_str)] = None

missing_out = [i for i, x in enumerate(out_strs) if x is not None]

if len(missing_pkts) == 0 and len(missing_out) == 0:
    print("No missing or extra packets!")
    exit(0)

if len(missing_pkts) != 0:
    print("Missing the following input packet indices: ", missing_pkts)

if len(missing_out) != 0:
    print("Extra output packets located at indices: ", missing_out)

if args.show:
    print("THE FOLLOWING INPUTS ARE MISSING")
    for i in missing_pkts[:args.show]:
        in_cap[i].show()

    print("THE FOLLOWING OUTPUTS ARE EXTRA")
    for i in missing_out[:args.show]:
        out_cap[i].show()

if args.diff:
    for i1, i2 in zip(missing_pkts[:args.diff], missing_out[:args.diff]):
	input_i = in_cap[i1].show(dump=True).splitlines(True)
	output_i = out_cap[i2].show(dump=True).splitlines(True)
	diffs = difflib.ndiff(input_i, output_i)
        print("Difference between input {} and output {}".format(i1, i2))
        print(''.join(diffs))

exit(1)
