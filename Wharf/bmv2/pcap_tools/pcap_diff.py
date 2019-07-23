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
        return None

in_cap = rdpcap(args.input)
out_cap = rdpcap(args.output)

out_strs = dict((strrep(o), i) for i, o in enumerate(out_cap))

missing_pkts = []

for i, pkt in enumerate(in_cap):

    in_str = strrep(pkt)

    if in_str not in out_strs:
        missing_pkts.append(i)
    else:
        del out_strs[in_str]
        #out_strs.remove(in_str)

if len(missing_pkts) == 0 and len(out_strs) == 0:
    print("No missing or extra packets!")
    exit(0)

if len(missing_pkts) != 0:
    print("Missing the following input packet indices: ", missing_pkts)

if len(out_strs) != 0:
    print("Extra output packets located at indices: ", sorted(out_strs.values()))

if args.show:
    print("THE FOLLOWING INPUTS ARE MISSING")
    for i in missing_pkts[:args.show]:
        in_cap[i].show()

    print("THE FOLLOWING OUTPUTS ARE EXTRA")
    for i in sorted(out_strs.values())[:args.show]:
        out_cap[i].show()

if args.diff:
    for i1, i2 in zip(missing_pkts[:args.diff], sorted(out_strs.values())[:args.diff]):
	input_i = in_cap[i1].show(dump=True).splitlines(True)
	output_i = out_cap[i2].show(dump=True).splitlines(True)
	diffs = difflib.ndiff(input_i, output_i)
        print("Difference between input {} and output {}".format(i1, i2))
        print(''.join(diffs))

exit(1)
