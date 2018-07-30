.PHONY: All EncoderNew run clean

P4C:=p4c-bm2-ss

BMV2_REPO_M:=$(BMV2_REPO)#FILL IN BEHAVIORAL-MODEL REPO LOCATION

BLD=build/
BLD_BMV2=$(BLD)/bmv2/

ifeq ($(BMV2_REPO_M),)
ifneq ($(filter run%,$(MAKECMDGOALS)),)
$(error Must set BMV2_REPO to run mininet with makefile)
endif
endif

DEPS=Makefile Sources/FEC.p4 Sources/Forwarding.p4 Sources/LLDP.p4 Sources/Parsing.p4

TARGET=TARGET_BMV2

USER=$(shell logname)

All: bmv2 Sample

Sample: $(BLD_BMV2)/Sample.json

bmv2: $(BLD_BMV2)/Encoder.json $(BLD_BMV2)/Decoder.json $(BLD_BMV2)/Dropper.json

run: All
	-mkdir -p pcap_output log_files
	-sudo python fec_demo.py \
		--behavioral-exe $(BMV2_REPO_M)/targets/booster_switch/simple_switch \
		--encoder-json $(BLD_BMV2)/Encoder.json \
		--decoder-json $(BLD_BMV2)/Decoder.json \
		--dropper-json $(BLD_BMV2)/Dropper.json \
		--pcap-dump pcap_output/ \
		--log-console log_files/
	-sudo chown -R $(USER) pcap_output/ log_files/

$(BLD) $(BLD_BMV2):
	mkdir -p $@

run-%: $(BLD_BMV2)/%.json
	mkdir -p pcap_output
	sudo python 1sw_demo.py --behavioral-exe $(BMV2_REPO_M)/targets/booster_switch/simple_switch --json $<  --pcap-dump pcap_output/

$(BLD_BMV2)/%.json: Sources/%.p4 $(DEPS) $(BLD_BMV2)
	p4c-bm2-ss --emit-externs -I  ../../FPGA/RSEVivadoHLS/ $< -o $@ --target bmv2 --arch v1model -D$(TARGET)

clean:
	rm -fr $(BLD)
