.PHONY: All EncoderNew run clean

P4C:=p4c-bm2-ss

BMV2_REPO_M:=$(BMV2_REPO)#FILL IN BEHAVIORAL-MODEL REPO LOCATION

ifeq ($(BMV2_REPO_M),)
ifeq ($(MAKECMDGOALS),run)
$(error Must set BMV2_REPO to run mininet with makefile)
endif
endif

All: EncoderNew Sample

EncoderNew: Encoder.json

Sample: Sample.json

run: Encoder.json
	sudo python $(BMV2_REPO_M)/mininet/1sw_demo.py --behavioral-exe $(BMV2_REPO_M)/targets/booster_switch/simple_switch --json $<  --pcap-dump dump.pcap

run-sample: Sample.json
	sudo python $(BMV2_REPO_M)/mininet/1sw_demo.py --behavioral-exe $(BMV2_REPO_M)/targets/booster_switch/simple_switch --json $< --pcap-dump dump.pcap

Encoder.json: Makefile Sources/Encoder.p4
	p4c-bm2-ss --emit-externs -I  ../../FPGA/RSEVivadoHLS/ Sources/Encoder.p4 -o $@ --target bmv2 --arch v1model

Sample.json: Makefile Sources/Sample.p4
	p4c-bm2-ss --emit-externs Sources/Sample.p4 -o $@ --target bmv2 --arch v1model

clean:
	rm -fr Encoder.sdnet Encoder.json Sample.json
