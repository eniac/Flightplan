#!/usr/bin/env python2
"""
Tool for converting between packet formats
"""

import argparse
import math
import struct

def main():
  """
  Main packet converter function
  """
  parser = argparse.ArgumentParser()
  parser.add_argument('inputFilename', help = 'Input file')
  parser.add_argument('outputFilename', help = 'Output file')
  parser.add_argument('-i', dest = 'inputType', choices = ['axi'], help = 'Input file type',
                      default = 'axi')
  parser.add_argument('-o', dest = 'outputType', choices = ['text'], help = 'Output file type',
                      default = 'text')
  args = parser.parse_args()

  packets = []

  if args.inputType == 'axi':
    readAXIFile(args.inputFilename, packets)

  if args.outputType == 'text':
    writeTextFile(args.outputFilename, packets)

def swapBytes(inputBytes):
  """
  """
  outputBytes = ""
  for offset in range(0, len(inputBytes), 2):
    outputBytes = inputBytes[offset : offset + 2] + outputBytes
  return outputBytes

def readAXIFile(filename, packets):
  """
  Read packets from AXI file.
  """
  with open(filename, "rt") as textFile:
    packet = ""
    for line in textFile:
      (end_of_packet, enables, data) = line.split()
      count = int(math.log(int(enables, 16) + 1) / math.log(2))
      packet += swapBytes(data[16 - 2 * count :])
      if end_of_packet == "1":
        packets.append(packet)
        packet = ""

def writeTextFile(filename, packets):
  """
  Write packets to text file.
  """
  with open(filename, "wt") as textFile:
    for packet in packets:
      textFile.write(packet + ';\n')

if __name__ == '__main__':
  main()

