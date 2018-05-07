#!/usr/bin/env python2
"""
Tool for generating packets for RTL simulation of FEC booster
"""

import argparse
import dpkt
import random
import re
import struct

def main():
  """
  Main packet generator function
  """
  parser = argparse.ArgumentParser()
  parser.add_argument('-t', dest = 'textFilename', action = 'store',
                      help = 'Output text file')
  parser.add_argument('-p', dest = 'pcapFilename', action = 'store',
                      help = 'Output PCAP file')
  parser.add_argument('-n', dest = 'packetCount', action = 'store', default = 100,
                      type = int, help = 'Number of packets')
  parser.add_argument('-l', dest = 'payloadLength', action = 'store',
                      default = '1024', help = 'Payload length in bytes.  ' \
                      'Specify a range (e.g., 512-1024) for random values.')
  args = parser.parse_args()

  packets = []
  for i in range(0, args.packetCount):
    packets.append(generatePacket(packetIndex = i,
                                  payloadLength = args.payloadLength))

  if args.pcapFilename != None:
    outputPCAPFile(args.pcapFilename, packets)
  if args.textFilename != None:
    outputTextFile(args.textFilename, packets)

def generatePacket(addrDst = '000000000000'.decode('hex'),
                   addrSrc = '000000000000'.decode('hex'),
                   payloadLength = 1024, packetIndex = 0):
  """
  Generate a single data packet without tag.
  """
  length = pickPayloadLength(payloadLength)
  payloadByte = (str(packetIndex % 9 + 1) * 2).decode("hex")
  payload = payloadByte * length;
  return dpkt.ethernet.Ethernet(dst = addrDst, src = addrSrc, type = 0,
                                data = payload)

def outputPCAPFile(filename, packets):
  """
  Output packets to a PCAP file.
  """
  with open(filename, "wb") as pcapFile:
    # File format identifier
    pcapFile.write("d4c3b2a1".decode("hex"))
    # File version
    pcapFile.write(struct.pack("<HH", 2, 4))
    # Time zone correction
    pcapFile.write(struct.pack("<I", 0))
    # Accuracy of timestamps
    pcapFile.write(struct.pack("<I", 0))
    # Maximum packet length
    pcapFile.write(struct.pack("<I", 1600))
    # Data link type (1 = Ethernet)
    pcapFile.write(struct.pack("<I", 1))
    for packet in packets:
      # Time
      pcapFile.write(struct.pack("<ii", 0, 0))
      # Number of bytes of packet stored in file
      pcapFile.write(struct.pack("<i", len(packet)))
      # Length of packet in bytes
      pcapFile.write(struct.pack("<i", len(packet)))
      # Packet contents
      pcapFile.write(str(packet))

def outputTextFile(filename, packets):
  """
  Output packets to a text file.
  """
  with open(filename, "wt") as textFile:
    for packet in packets:
      textFile.write(str(packet).encode('hex') + ';\n')

def pickPayloadLength(length):
  """
  Choose a payload length based on the command line argument.
  """
  result = re.match(r'(\S+)-(\S+)', length)
  if result != None:
    start = int(result.group(1))
    end = int(result.group(2))
    length = random.randint(start, end)
  else:
    length = int(length)
  return length

if __name__ == '__main__':
  main()

