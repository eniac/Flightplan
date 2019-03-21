.PHONY: All EncoderNew run clean

P4C:=p4c-bm2-ss
P4TEST:=p4test

BMV2_REPO_M:=$(BMV2_REPO)#FILL IN BEHAVIORAL-MODEL REPO LOCATION
RUNTIME_CLI_DIR=$(BMV2_REPO_M)/tools

BLD=build/
BLD_BMV2=$(BLD)/bmv2/

ifeq ($(BMV2_REPO_M),)
ifneq ($(filter run%,$(MAKECMDGOALS)),)
$(error Must set BMV2_REPO to run mininet with makefile)
endif
endif

DEPS=Makefile Sources/FEC.p4 Sources/Forwarding.p4 Sources/LLDP.p4 Sources/Parsing.p4 Sources/Complete.p4 Sources/Compressor.p4

TARGET=TARGET_BMV2

USER=$(shell logname)

EXTERNS=fec_encode fec_decode memcached header_compress header_decompress

All: bmv2 Sample

Sample: $(BLD_BMV2)/Sample.json

test:
	${P4TEST} -DTARGET_BMV2 -I../FPGA/RSEVivadoHLS/ -I../FPGA/RSEConfig  -I../FPGA/MemcachedP4 

bmv2: $(BLD_BMV2)/Encoder.json $(BLD_BMV2)/Decoder.json $(BLD_BMV2)/Dropper.json \
	  $(BLD_BMV2)/Forwarder.json $(BLD_BMV2)/Complete.json $(BLD_BMV2)/Compressor.json

complete: $(BLD_BMV2)/Complete.json

run: All
	-mkdir -p pcap_output log_files
	-sudo PYTHONPATH=$(RUNTIME_CLI_DIR) python bmv2/fec_demo.py \
		--behavioral-exe $(BMV2_REPO_M)/targets/booster_switch/simple_switch \
		--encoder-json $(BLD_BMV2)/Encoder.json \
		--decoder-json $(BLD_BMV2)/Decoder.json \
		--dropper-json $(BLD_BMV2)/Dropper.json \
		--dropper-pcap bmv2/lldp_enable_fec.pcap \
		--pcap-dump bmv2/pcap_output/ \
		--log-console log_files/ \
		--command-file bmv2/forwarding_commands.txt
	-sudo chown -R $(USER) pcap_output/ log_files/

$(BLD) $(BLD_BMV2):
	mkdir -p $@

run-%: $(BLD_BMV2)/%.json
	sudo mn -c
	mkdir -p pcap_output
	sudo PYTHONPATH=$(RUNTIME_CLI_DIR) python bmv2/1sw_demo.py --behavioral-exe $(BMV2_REPO_M)/targets/booster_switch/simple_switch --json $<  --pcap-dump pcap_output/ --command-file bmv2/complete_commands.txt

$(BLD_BMV2)/%.json: Sources/%.p4 $(DEPS) $(BLD_BMV2)
	p4c-bm2-ss --emit-externs -I../FPGA/RSEConfig -I../FPGA/MemcachedP4 -I../FPGA/RSEVivadoHLS/  $< -o $@ --target bmv2 --arch v1model -D$(TARGET) -DMID_FORWARDING_DECISION -DHEADER_COMPRESSION
	sed -i.orig 's/"name" : "parse_/"name" : "FecParser_parse_/g' $@
	python2 split_extern_event.py $@ $@ ${EXTERNS}

clean:
	rm -fr $(BLD)
