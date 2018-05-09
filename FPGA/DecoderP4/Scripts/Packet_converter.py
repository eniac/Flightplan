#!/usr/bin/env python2
"""
Tool for converting packets in AXI bus format to text format
"""

import argparse
import math
import struct

def main():
  """
  Main packet converter function
  """
  parser = argparse.ArgumentParser()
  parser.add_argument('-i', dest = 'inputFilename', action = 'store',
                      help = 'Input AXI file')
  parser.add_argument('-o', dest = 'outputFilename', action = 'store',
                      help = 'Output text file')
  args = parser.parse_args()

  convertPackets(args.inputFilename, args.outputFilename);

def convertPackets(inputFilename, outputFilename):
  """
  Convert packet.
  """
  with open(inputFilename, "rt") as inputFile:
    with open(outputFilename, "wt") as outputFile:
      packet = ""
      for line in inputFile:
        tokens = line.split()
        if (len(tokens) == 3):
          [endOfFrame, byteEnables, data] = tokens
          byteCount = int(math.ceil(math.log(int(byteEnables, 16) + 1, 2)))
          packet += reverseWord(data)[0 : 2 * byteCount]
          if endOfFrame == "1":
            outputFile.write(packet + ";\n");
            packet = ""

def reverseWord(word):
  value = int(word, 16)
  value = struct.unpack("<Q", struct.pack(">Q", value))[0]
  return "%016X" % value

if __name__ == '__main__':
  main()

