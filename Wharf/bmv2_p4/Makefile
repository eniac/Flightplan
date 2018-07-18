.PHONY: All EncoderNew run clean

P4C:=p4c-bm2-ss

BMV2_REPO_M:=$(BMV2_REPO)#FILL IN BEHAVIORAL-MODEL REPO LOCATION

BLD=build/

ifeq ($(BMV2_REPO_M),)
ifeq ($(MAKECMDGOALS),run)
$(error Must set BMV2_REPO to run mininet with makefile)
endif
endif

DEPS=Makefile Sources/FEC.p4 Sources/FecBM.p4

All: $(BLD) BM Sample

Sample: $(BLD)/Sample.json

BM: $(BLD)/EncoderBM.json $(BLD)/DecoderBM.json $(BLD)/Dropper.json

run: All
	sudo python fec_demo.py \
		--behavioral-exe $(BMV2_REPO_M)/targets/booster_switch/simple_switch \
		--encoder-json $(BLD)/EncoderBM.json \
		--decoder-json $(BLD)/DecoderBM.json \
		--dropper-json $(BLD)/Dropper.json \
		--pcap-dump 1 # "1" does nothing here, but flag is necessary

$(BLD):
	mkdir -p $(BLD)

run-%: $(BLD)/%.json
	sudo python $(BMV2_REPO_M)/mininet/1sw_demo.py --behavioral-exe $(BMV2_REPO_M)/targets/booster_switch/simple_switch --json $<  --pcap-dump dump.pcap

$(BLD)/%.json: Sources/%.p4 $(DEPS) $(BLD)
	p4c-bm2-ss --emit-externs -I  ../../FPGA/RSEVivadoHLS/ $< -o $@ --target bmv2 --arch v1model

clean:
	rm -fr Encoder.sdnet Encoder.json Sample.json Decoder.json
