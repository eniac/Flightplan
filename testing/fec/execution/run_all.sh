#!/bin/bash

#./run_multiple.sh run_cpu_fec_encoder.sh cpu_fec_encoder fec_new_test_in.pcap
#./run_multiple.sh run_cpu_fec_decoder.sh cpu_decoder_rerun cpu_fec_test_enc.pcap 
#./run_multiple.sh run_fpga_fec_encoder.sh fpga_encoder_rerun fec_new_test_in.pcap
./run_multiple.sh run_fpga_fec_decoder.sh fpga_decoder_rerun fpga_fec_test_enc_60.pcap 
