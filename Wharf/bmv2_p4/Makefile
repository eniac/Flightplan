.PHONY: All EncoderNew run clean

P4C:=p4c-bm2-ss

BMV2_REPO_M:=$(BMV2_REPO)#FILL IN BEHAVIORAL-MODEL REPO LOCATION

BLD=build/
BLD2=build2/

ifeq ($(BMV2_REPO_M),)
ifeq ($(MAKECMDGOALS),run)
$(error Must set BMV2_REPO to run mininet with makefile)
endif
endif

DEPS=Makefile Sources/FEC.p4 Sources/Forwarding.p4 Sources/LLDP.p4 Sources/Parsing.p4

TARGET=TARGET_BMV2

USER=$(shell logname)

All: $(BLD) BM Sample

Sample: $(BLD)/Sample.json

BM: $(BLD)/Encoder.json $(BLD)/Decoder.json $(BLD)/Dropper.json

run: All
	-mkdir -p pcap_output log_files
	-sudo python fec_demo.py \
		--behavioral-exe $(BMV2_REPO_M)/targets/booster_switch/simple_switch \
		--encoder-json $(BLD)/EncoderBM.json \
		--decoder-json $(BLD)/DecoderBM.json \
		--dropper-json $(BLD)/Dropper.json \
		--pcap-dump pcap_output/ \
		--log-console log_files/
	-sudo chown -R $(USER) pcap_output/ log_files/

$(BLD) $(BLD2):
	mkdir -p $@

run-%: $(BLD)/%.json
	sudo python $(BMV2_REPO_M)/mininet/1sw_demo.py --behavioral-exe $(BMV2_REPO_M)/targets/booster_switch/simple_switch --json $<  --pcap-dump dump.pcap

$(BLD)/%.json: Sources/%.p4 $(DEPS) $(BLD)
	p4c-bm2-ss --emit-externs -I  ../../FPGA/RSEVivadoHLS/ $< -o $@ --target bmv2 --arch v1model -D$(TARGET)

clean:
	rm -fr $(BLD)
