import sys
from scapy.all import *

if len(sys.argv) != 3:
    print("Usage: %s <expected.pcap> <output.pcap>" % sys.argv[0])
    exit()

exp_cap  = rdpcap(sys.argv[1])
out_cap  = [ x for x in rdpcap(sys.argv[2]) if IP in x]


def strrep(pkt):
    try:
        return str(pkt)[0:14 + pkt[IP].len]
    except:
        return "NOT IP!"

found_pkts = set()
missing = []
dups = []

for pkt in exp_cap:
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
                dups.append(pkt2)
                del out_cap[i - n_remvd]
                n_remvd += 1
        if found:
            del out_cap[i - n_remvd]
            found_pkts.add(exp)
        else:
            missing.append(pkt)

    except Exception as e:
        print "EXCEPTION", e

def classify(pkts):
    nos = dict(STORED=0, VALUE=0, other=0)
    for pkt in pkts:
        if 'STORED' in str(pkt):
            nos['STORED'] += 1
        elif 'VALUE' in str(pkt):
            nos['VALUE'] += 1
        else:
            nos['other'] += 1
    return nos

def show_classf(classf):
    print "\tStored: {STORED}\n\tValue: {VALUE}\n\tOther: {other}".format(**classf)

extras = []

for pkt in out_cap:
    if strrep(pkt) in found_pkts:
        dups.append(pkt)
    else:
        extras.append(pkt)


missingnos = classify(missing)
dupnos = classify(dups)
extranos = classify(extras)

rtn = 0
if len(missing) > 0:
    rtn = 1
    print "MISSING PACKETS:"
    show_classf(missingno)

if len(extras) > 0:
    if len(extras) != extranos['other']:
        rtn = -1
    print "EXTRA PACKETS:"
    show_classf(extranos)

if len(dups) > 0:
    print "DUPLICATE PACKETS:"
    show_classf(dupnos)

exit(rtn)
