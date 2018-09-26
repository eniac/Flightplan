All: DecoderVivadoHLS

DecoderVivadoHLS: Decoder.cpp Decoder.h Configuration.h
	@mkdir -p Batch
	cd Batch && bash -c 'source $$SDSOC_ROOT/settings64.sh && vivado_hls ../Synthesize.tcl'

clean:
	rm -fr Batch

