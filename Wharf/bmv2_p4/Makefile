.PHONY: All EncoderNew run clean

P4C:=p4c-bm2-ss

BMV2_REPO_M:=$(BMV2_REPO)#FILL IN BEHAVIORAL-MODEL REPO LOCATION

ifeq ($(BMV2_REPO_M),)
ifeq ($(MAKECMDGOALS),run)
$(error Must set BMV2_REPO to run mininet with makefile)
endif
endif

All: Encoder Decoder Sample

Encoder: Encoder.json

Sample: Sample.json

Decoder: Decoder.json

run: Encoder.json
	sudo python $(BMV2_REPO_M)/mininet/1sw_demo.py --behavioral-exe $(BMV2_REPO_M)/targets/booster_switch/simple_switch --json $<  --pcap-dump dump.pcap

run-%: %.json
	sudo python $(BMV2_REPO_M)/mininet/1sw_demo.py --behavioral-exe $(BMV2_REPO_M)/targets/booster_switch/simple_switch --json $<  --pcap-dump dump.pcap

run-Sample: Sample.json
	sudo python $(BMV2_REPO_M)/mininet/1sw_demo.py --behavioral-exe $(BMV2_REPO_M)/targets/booster_switch/simple_switch --json $< --pcap-dump dump.pcap

%.json: Sources/%.p4 Makefile
	p4c-bm2-ss --emit-externs -I  ../../FPGA/RSEVivadoHLS/ $< -o $@ --target bmv2 --arch v1model

clean:
	rm -fr Encoder.sdnet Encoder.json Sample.json Decoder.json
