#!/bin/bash

# redirect packet stream to fec
sed -i '/class fec_0_t::UserEngine/a \ \ Packet_input packet_in;\n\ \ Packet_output packet_out;' Encoder.sdnet
sed -i '/Deparser.packet_in = Parser.packet_out,/d' Encoder.sdnet
sed -i '/Parser.packet_in = packet_in,/a\ \ \ \ fec_0.packet_in = Parser.packet_out,\n\ \ \ \ Deparser.packet_in = fec_0.packet_out,' Encoder.sdnet

# force the program to admit all headers, no matter extracted or not ( currently only vid )
sed -i '/hdr.veth.isValid = 1,/a\ \ \ \ \ \ hdr.vid.isValid = 1,' Encoder.sdnet
