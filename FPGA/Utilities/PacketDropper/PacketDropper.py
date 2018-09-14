#!/usr/bin/env python2
"""
Tool for converting between packet formats
"""

import argparse
import math
import random
import struct

def main():
  """
  Main packet converter function
  """
  parser = argparse.ArgumentParser()
  parser.add_argument('inputFilename', help = 'Input file')
  parser.add_argument('outputFilename', help = 'Output file')
  parser.add_argument('-i', dest = 'inputType', choices = ['text'], help = 'Input file type',
                      default = 'text')
  parser.add_argument('-o', dest = 'outputType', choices = ['text'], help = 'Output file type',
                      default = 'text')
  parser.add_argument('-p', dest = 'dropProbability', help = 'Probability packet is dropped',
                      default = '0.1', type = float)
  parser.add_argument('-r', dest = 'reconstructable', help = 'Ensure packets can be reconstructed.',
                      action = 'store_true')
  parser.add_argument('-k', dest = 'k', help = 'Data packets in a block', type = int, default = 5)
  parser.add_argument('-n', dest = 'h', help = 'Parity packets in a block', type = int, default = 1)
  args = parser.parse_args()

  packets = []

  if args.inputType == 'text':
    readTextFile(args.inputFilename, packets)

  packets = dropPackets(packets, args.dropProbability, args.reconstructable, args.k, args.h)

  if args.outputType == 'text':
    writeTextFile(args.outputFilename, packets)

def readTextFile(filename, packets):
  """
  Read packets from text file.
  """
  with open(filename, "rt") as textFile:
    for packet in textFile:
      packets.append(packet)

def dropPackets(packets, dropProbability, reconstructable, k, h):
  """
  Drop packets.
  """
  count = int(dropProbability * len(packets))
  indices = sorted(random.sample(range(0, len(packets)), count))

  new_indices = indices[:]
  if reconstructable:
    prev_block = -1
    for index in indices:
      block = int(index / (k + h))
      if block == prev_block:
        missing += 1
        if missing >= h:
          new_indices.remove(index)
      else:
        missing = 1
      prev_block = block

  return [packets[i] for i in range(0, len(packets)) if i not in new_indices]

def writeTextFile(filename, packets):
  """
  Write packets to text file.
  """
  with open(filename, "wt") as textFile:
    for packet in packets:
      textFile.write(packet)

if __name__ == '__main__':
  main()

