#!/usr/env/python

import subprocess
import sys
import os
import time
import argparse

if __name__ == '__main__':

    parser = argparse.ArgumentParser("Run a batch of shremotes")
    parser.add_argument("label", type=str, help="base label")
    parser.add_argument("cfg", type=str, help="Shremote cfg")
    parser.add_argument("--args", type=str, help="args str to pass to shremote")
    parser.add_argument("--out", type=str, help="output folder")
    args = parser.parse_args()

    rates = [.05, .1, .15, .25, .5, .75, 1.0, 1.25, 1.5, 1.75, 2.0, 2.5, 3.0, 3.5, 4.0]
    time.sleep(2)
    for rate in rates:
        kwargs = '{};rate:{}'.format(args.args, rate)
        label = "{}_{}".format(args.label, rate)
        cmd = ['python', '../../Shremote/shremote.py', args.cfg, label, '--args', kwargs, '--out', args.out]
        print('Running {}'.format(cmd))
        subprocess.call(cmd)
        print("Done")
        time.sleep(5)
