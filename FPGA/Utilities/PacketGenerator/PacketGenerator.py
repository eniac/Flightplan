#!/usr/bin/env python2
"""
Tool for generating packets for RTL simulation of FEC booster
"""

import argparse
import dpkt
import struct

def main():
  """
  Main packet generator function
  """
  parser = argparse.ArgumentParser()
  parser.add_argument('filename', action = 'store', help = 'Output file')
  parser.add_argument('-t', dest = 'filetype', action = 'store', default = 'text',
                      choices = ['text', 'pcap', 'axi'], help = 'Output file type')
  parser.add_argument('-k', dest = 'k', action = 'store', default = 8,
                      type = int, help = 'Untagged data packets per block (k)')
  parser.add_argument('-f', dest = 'h', action = 'store', default = 4,
                      type = int, help = 'Tagged feedback packets per block (h)')
  parser.add_argument('-b', dest = 'blockCount', action = 'store', default = 3,
                      type = int, help = 'Number of blocks')
  parser.add_argument('-l', dest = 'payloadLength', action = 'store',
                      default = 1024, type = int,
                      help = 'Payload length in bytes')
  args = parser.parse_args()

  packets = []
  for j in range(0, args.blockCount):
    for i in range(0, args.k):
      packets.append(generateDataPacket(packetIndex = i,
                                        payloadLength = args.payloadLength))
    for i in range(0, args.h):
      packets.append(generateParityPacket(packetIndex = i, k = args.k,
                                          payloadLength = args.payloadLength))

  if args.filetype == 'pcap':
    outputPCAPFile(args.filename, packets)
  if args.filetype == 'text':
    outputTextFile(args.filename, packets)
  if args.filetype == 'axi':
    outputAXIFile(args.filename, packets)

def generateDataPacket(addrDst = '000000000000'.decode('hex'),
                       addrSrc = '000000000000'.decode('hex'),
                       payloadLength = 1024, packetIndex = 0):
  """
  Generate a single data packet without tag.
  """
  payloadByte = (str(packetIndex + 1) * 2).decode("hex")
  payload = payloadByte * payloadLength;
  return dpkt.ethernet.Ethernet(dst = addrDst, src = addrSrc, type = 0,
                                data = payload)

def generateParityPacket(addrDst = '000000000000'.decode('hex'),
                         addrSrc = '000000000000'.decode('hex'),
                         payloadLength = 1024, packetIndex = 0,
                         k = 8):
  """
  Generate a single parity packet with tag, identical to packets produced by
  the feedback loop.
  """
  tag = struct.pack("!H", packetIndex)
  payloadByte = (str(packetIndex + 1) * 2).decode("hex")
  payload = tag + payloadByte * payloadLength;
  return dpkt.ethernet.Ethernet(dst = addrDst, src = addrSrc, type = 0x8000,
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

def outputAXIFile(filename, packets):
  """
  Output packets to an AXI file.
  """
  with open(filename, "wt") as textFile:
    for packet in packets:
      data = str(packet).encode('hex')
      while len(data) > 0:
        word = data[:16]
        data = data[16:]
        end = 1 if len(data) == 0 else 0
        mask = 0xFF >> (8 - len(word) / 2)
        word = word + "0" * (16 - len(word))
        textFile.write(str(end) + ' ' + '{:02x}'.format(mask) + ' ' + word[::-1] + '\n')

if __name__ == '__main__':
  main()

