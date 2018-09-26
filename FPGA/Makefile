.PHONY: All RSE RSEVivado RSEP4 DecoderP4 MemcachedP4 RSEVivadoHLS DecoderVivadoHLS MemcachedVivadoHLS TupleGeneratorVivado RSEInputBufferVivado RSEOutputBufferVivado clean

All: RSE

RSE: RSEVivado
Decoder: DecoderVivado

Memcached: MemcachedVivado

MemcachedVivado: MemcachedP4 RSEInputBufferVivado RSEOutputBufferVivado TupleGeneratorVivado
	cd RSEVivado && make Memcached

RSEVivado: RSEP4 RSEInputBufferVivado RSEOutputBufferVivado TupleGeneratorVivado
	cd RSEVivado && make

DecoderVivado: DecoderP4 RSEInputBufferVivado RSEOutputBufferVivado TupleGeneratorVivado
	cd RSEVivado && make Decoder

RSEP4: RSEVivadoHLS
	cd RSEP4 && make

DecoderP4: DecoderVivadoHLS
	cd DecoderP4 && make

MemcachedP4: MemcachedVivadoHLS
	cd MemcachedP4 && make

RSEInputBufferVivado:
	cd RSEInputBufferVivado && make

RSEOutputBufferVivado:
	cd RSEOutputBufferVivado && make

TupleGeneratorVivado:
	cd TupleGeneratorVivado && make

RSEVivadoHLS:
	cd RSEVivadoHLS && make

DecoderVivadoHLS:
	cd DecoderVivadoHLS && make

MemcachedVivadoHLS:
	cd MemcachedVivadoHLS && make

clean:
	cd RSEVivado && make clean
	cd RSEVivadoHLS && make clean
	cd DecoderVivadoHLS && make clean
	cd MemcachedVivadoHLS && make clean
	cd MemcachedP4 && make clean
	cd RSEP4 && make clean
	cd DecoderP4 && make clean
	cd TupleGeneratorVivado && make clean
	cd RSEInputBufferVivado && make clean
	cd RSEOutputBufferVivado && make clean

