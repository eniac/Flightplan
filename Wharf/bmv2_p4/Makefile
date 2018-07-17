.PHONY: All EncoderNew run clean

P4C:=p4c-bm2-ss

BMV2_REPO:=#FILL IN BEHAVIORAL-MODEL REPO LOCATION

ifeq ($(BMV2_REPO),)
ifeq ($(MAKECMDGOALS),run)
$(error Must set BMV2_REPO to run mininet with makefile)
endif
endif

All: EncoderNew

EncoderNew: Encoder.json

run: Encoder.json
	sudo python $(BMV2_REPO)/mininet/1sw_demo.py --behavioral-exe $(BMV2_REPO)/targets/booster_switch/simple_switch --json Encoder.json  --pcap-dump dump.pcap

Encoder.json: Makefile Sources/Encoder.p4
	p4c-bm2-ss --emit-externs -I  ../../FPGA/RSEVivadoHLS/ Sources/Encoder.p4 -o $@ --target bmv2 --arch v1model

clean:
	rm -fr Encoder.sdnet Encoder.json
