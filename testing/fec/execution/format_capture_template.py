import sys
import string
from argparse import ArgumentParser

parser = ArgumentParser()
parser.add_argument('input', type=str)
parser.add_argument('out', type=str)
parser.add_argument('--duration', type=float, required=True)

args = parser.parse_args();


with open(args.input) as f:
    t = string.Template(f.read())
    s = t.substitute(dict(duration=args.duration))
    with open(args.out, 'w') as f2:
        f2.write(s)

