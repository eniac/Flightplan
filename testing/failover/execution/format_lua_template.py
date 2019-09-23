import sys
import string
from argparse import ArgumentParser

parser = ArgumentParser()
parser.add_argument('input', type=str)
parser.add_argument('out', type=str)
parser.add_argument('--rate', type=float, required=True)
parser.add_argument('--log', type=str, required=True)
parser.add_argument('--count', type=str, required=True)

args = parser.parse_args();


with open(args.input) as f:
    t = string.Template(f.read())
    s = t.substitute(dict(rate=args.rate, logfile=args.log, count=args.count))
    with open(args.out, 'w') as f2:
        f2.write(s)

