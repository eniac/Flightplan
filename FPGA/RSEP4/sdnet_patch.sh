#!/bin/bash

# redirect packet stream to fec
sed -i '/class fec_0_t::UserEngine/a \ \ Packet_input packet_in;\n\ \ Packet_output packet_out;' Encoder.sdnet
sed -i '/Deparser.packet_in = Parser.packet_out,/d' Encoder.sdnet
sed -i '/Parser.packet_in = packet_in,/a\ \ \ \ fec_0.packet_in = Parser.packet_out,\n\ \ \ \ Deparser.packet_in = fec_0.packet_out,' Encoder.sdnet

