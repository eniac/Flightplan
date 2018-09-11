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
  args = parser.parse_args()

  packets = []

  if args.inputType == 'text':
    readTextFile(args.inputFilename, packets)

  packets = dropPackets(packets, args.dropProbability)

  if args.outputType == 'text':
    writeTextFile(args.outputFilename, packets)

def readTextFile(filename, packets):
  """
  Read packets from text file.
  """
  with open(filename, "rt") as textFile:
    for packet in textFile:
      packets.append(packet)

def dropPackets(packets, dropProbability):
  """
  Drop packets.
  """
  count = int((1 - dropProbability) * len(packets))
  indices = sorted(random.sample(range(0, len(packets)), count))
  return [packets[i] for i in indices]

def writeTextFile(filename, packets):
  """
  Write packets to text file.
  """
  with open(filename, "wt") as textFile:
    for packet in packets:
      textFile.write(packet)

if __name__ == '__main__':
  main()

