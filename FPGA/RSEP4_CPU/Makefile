.PHONY: All Simulation clean

P4C=~/dcomp/p4c/build/p4c-bm2-ss

BEHAVIORAL_MODEL_REPO:= #FILL IN BEHAVIORAL-MODEL REPO LOCATION

All: EncoderNew

EncoderNew: Encoder.json

run: Encoder.json
	sudo python $(BEHAVIORAL_MODEL_REPO)/mininet/1sw_demo.py --behavioral-exe $(BEHAVIORAL_MODEL_REPO)/targets/booster_switch/simple_switch --json Encoder.json  --pcap-dump dump.pcap

Encoder.json: Makefile Sources/Encoder.p4
	p4c-bm2-ss --emit-externs -I  ../RSEVivadoHLS/ -Idata/p4include  Sources/Encoder.p4 -o $@ --target bmv2 --arch v1model

clean:
	rm -fr Encoder.sdnet Encoder.json
