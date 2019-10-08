#!/bin/bash

#./run_multiple.sh run_cpu_hc_compress.sh cpu_compress_rerun oneFlow1000.pcap 
#./run_multiple.sh run_cpu_hc_decompress.sh cpu_decompress_rerun oneFlow1000_new.pcap.compress.pcap 
#./run_multiple.sh run_fpga_hc_compress.sh fpga_compress_rerun oneFlow1000.pcap 
./run_multiple.sh run_fpga_hc_decompress.sh fpga_decompress_rerun oneFlow1000_new.pcap.compress.pcap 
