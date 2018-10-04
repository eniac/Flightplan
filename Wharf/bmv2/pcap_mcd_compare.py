import sys
from scapy.all import *
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('expected', type=str)
parser.add_argument('output', type=str)
parser.add_argument('--show', action='store', required=False, default=None)
args = parser.parse_args()

exp_cap  = rdpcap(args.expected)
out_cap  = [ x for x in rdpcap(args.output) if IP in x]


def strrep(pkt):
    try:
        return str(pkt)[0:14 + pkt[IP].len]
    except:
        return None

found_pkts = set()
missing = []
dups = []

print("Comparing {} and {} for memcached".format(args.expected, args.output))

for j, pkt in enumerate(exp_cap):

    if (j + 1) % (len(exp_cap) / 10) == 0:
        print 100.0 * j  / len(exp_cap)

    try:
        exp = strrep(pkt)
        found = False
        n_remvd = 0
        for i, pkt2 in enumerate(out_cap[:]):
            stpkt2 = strrep(pkt2)
            if stpkt2 == exp:
                found = True
                break
            if stpkt2 in found_pkts:
                dups.append((pkt2,j))
                del out_cap[i - n_remvd]
                n_remvd += 1
        if found:
            del out_cap[i - n_remvd]
            found_pkts.add(exp)
        else:
            missing.append((pkt,j))

    except Exception as e:
        print "EXCEPTION", e

def classify(pkts):
    nos = dict(STORED=0, VALUE=0, other=0, stored_i = [], value_i = [])
    for pkt, i in pkts:
        if 'STORED' in str(pkt):
            nos['STORED'] += 1
            nos['stored_i'].append(i)
        elif 'VALUE' in str(pkt):
            nos['VALUE'] += 1
            nos['value_i'].append(i)
        else:
            nos['other'] += 1
    return nos

def show_classf(classf):
    print "\tStored: {STORED}\n\tValue: {VALUE}\n\tOther: {other}".format(**classf)

extras = []

print ("Classifying duplicates and extras")

for pkt in out_cap:
    if strrep(pkt) in found_pkts:
        dups.append((pkt, -1))
    else:
        extras.append((pkt, -1))


missingnos = classify(missing)
dupnos = classify(dups)
extranos = classify(extras)

rtn = 0
if len(missing) > 0:
    rtn = 1
    print "MISSING PACKETS:"
    show_classf(missingnos)
    print missingnos['stored_i']
    print missingnos['value_i']
    if args.show == 'missing':
        for pkt, _ in missing:
            pkt.show()

if len(extras) > 0:
    if len(extras) != extranos['other']:
        rtn = -1
    print "EXTRA PACKETS:"
    show_classf(extranos)
    if args.show == 'extra':
        for pkt, _ in extras:
            pkt.show()

if len(dups) > 0:
    print "DUPLICATE PACKETS:"
    show_classf(dupnos)

print "SUCCESSFUL PACKETS:"
show_classf(classify([(x, 0) for x in found_pkts]))

exit(rtn)
