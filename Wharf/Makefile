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

DEPS=Makefile Sources/FEC.p4 Sources/Forwarding.p4 Sources/LLDP.p4 Sources/Parsing.p4 Sources/Compression.p4

TARGET=TARGET_BMV2

USER=$(shell logname)

EXTERNS=fec_encode fec_decode memcached header_compress header_decompress

All: bmv2 Sample

Sample: $(BLD_BMV2)/Sample.json

test:
	${P4TEST} -DTARGET_BMV2 -I../FPGA/RSEVivadoHLS/ -I../FPGA/RSEConfig  -I../FPGA/MemcachedP4 

bmv2: $(BLD_BMV2) $(BLD_BMV2)/Encoder.json $(BLD_BMV2)/Decoder.json $(BLD_BMV2)/Dropper.json \
	  $(BLD_BMV2)/Forwarder.json $(BLD_BMV2)/Complete.json $(BLD_BMV2)/Compressor.json

complete: $(BLD_BMV2)/Complete.json

$(BLD_BMV2):
	@mkdir -p $@

$(BLD_BMV2)/%.json: Sources/%.p4 $(DEPS)
	p4c-bm2-ss --emit-externs -I../FPGA/RSEConfig -I../FPGA/MemcachedP4 -I../FPGA/RSEVivadoHLS/  $< -o $@ --target bmv2 --arch v1model -D$(TARGET) -DMID_FORWARDING_DECISION -DHEADER_COMPRESSION
	sed -i.orig 's/"name" : "parse_/"name" : "FecParser_parse_/g' $@
	python2 split_extern_event.py $@ $@ ${EXTERNS}

clean:
	rm -fr $(BLD)
