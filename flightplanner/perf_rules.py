#!/usr/local/bin/python
# Nik Sultana, UPenn, August 2020
# Performance rule generator from CSV input
# ./perf_rules.py > examples/performance_tclust.json

import csv
import sys

# FIXME const filename
input_csv = 'examples/performance_tclust.csv'

print('[')

first = True
with open(input_csv, 'r') as csvf:
  for row in csv.DictReader(csvf):

    if row['name'].strip()[0] == "#":
      continue

    # If one aF parameter is given, then they all should be given.
    if "" != row['g:aF:LUTs'] and ("" == row['g:aF:BRAMs'] and "" == row['g:aF:FFs']):
      raise Exception('"aF" parameters are not in synch')
    if "" != row['g:aF:BRAMs'] and ("" == row['g:aF:LUTs'] and "" == row['g:aF:FFs']):
      raise Exception('"aF" parameters are not in synch')
    if "" != row['g:aF:FFs'] and ("" == row['g:aF:LUTs'] and "" == row['g:aF:BRAMs']):
      raise Exception('"aF" parameters are not in synch')

    is_FPGA = False
    if "" != row['g:aF:LUTs'] and "" != row['g:aF:BRAMs'] and "" != row['g:aF:FFs']:
      is_FPGA = True

    if not first: print (',')
    first = False

    result = '{\n' \
     '  "name" : "' + row['name'] + '",\n' \
     '  "props" : ["' + row['props (singular)'] + '"],\n' \
     '  "bounds" : [\n'

    if is_FPGA:
      result += \
        '      {"lt":["Data::Bound::FPGA1_Area_BRAMs", "100"]},\n' \
        '      {"lt":["Data::Bound::FPGA1_Area_FFs", "100"]},\n' \
        '      {"lt":["Data::Bound::FPGA1_Area_LUTs", "100"]},\n' \
        '      {"lt":["Data::Bound::FPGA2_Area_BRAMs", "100"]},\n' \
        '      {"lt":["Data::Bound::FPGA2_Area_FFs", "100"]},\n' \
        '      {"lt":["Data::Bound::FPGA2_Area_LUTs", "100"]},\n' \
        '      {"lt":["Data::Bound::FPGA3_Area_BRAMs", "100"]},\n' \
        '      {"lt":["Data::Bound::FPGA3_Area_FFs", "100"]},\n' \
        '      {"lt":["Data::Bound::FPGA3_Area_LUTs", "100"]},\n' \
        '      {"lt":["Data::Bound::FPGA4_Area_BRAMs", "100"]},\n' \
        '      {"lt":["Data::Bound::FPGA4_Area_FFs", "100"]},\n' \
        '      {"lt":["Data::Bound::FPGA4_Area_LUTs", "100"]},\n' \
        '      {"lt":["Data::Bound::FPGA5_Area_BRAMs", "100"]},\n' \
        '      {"lt":["Data::Bound::FPGA5_Area_FFs", "100"]},\n' \
        '      {"lt":["Data::Bound::FPGA5_Area_LUTs", "100"]},\n'

    result += \
     '      {"lt":["Data::Bound::InputRate", "' + row['bounds:ltData::Bound::InputRate'] + '"]},\n' \
     '      {"gt":["Data::Bound::PacketSize", "' + row['bounds:gt:Data::Bound::PacketSize'] + '"]}\n' \
     '    ],\n' \
     '  "g" : [\n' \
     '      {"aP":["Data::Bound::Latency", "' + row['g:aP:Data::Bound::Latency'] + '"]},\n' \
     '      {"aM":["Data::Bound::InputRate", "' + row['g:aM:Data::Bound::InputRate'] + '"]},\n'

    if is_FPGA:
      result += '{"aF":["' + row['g:aF:LUTs'] + '", "' + row['g:aF:BRAMs'] + '", "' + row['g:aF:FFs'] + '"]},\n'

    result += \
     '      {"aO":["Data::Bound::Power", "' + row['g:aO:Data::Bound::Power'] + '"]},\n' \
     '      {"aO":["Data::Bound::Cost", "' + row['g:aO:Data::Bound::Cost'] + '"]}\n' \
     '    ],\n' \
     '  "conclusion" : "' + row['conclusion'] + '"\n' \
     '}'

    sys.stdout.write(result)

print('\n]')
