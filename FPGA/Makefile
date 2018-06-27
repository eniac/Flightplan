.PHONY: All RSE RSEVivado RSEP4 MemcachedVivadoHLS TupleGeneratorVivado RSEInputBufferVivado RSEOutputBufferVivado clean

All: RSE

RSE: RSEVivado

RSEVivado: RSEP4 RSEInputBufferVivado RSEOutputBufferVivado TupleGeneratorVivado
	cd RSEVivado && make

RSEP4: MemcachedVivadoHLS
	cd RSEP4 && make

RSEInputBufferVivado:
	cd RSEInputBufferVivado && make

RSEOutputBufferVivado:
	cd RSEOutputBufferVivado && make

TupleGeneratorVivado:
	cd TupleGeneratorVivado && make

MemcachedVivadoHLS:
	cd MemcachedVivadoHLS && make

clean:
	cd RSEVivado && make clean
	cd MemcachedVivadoHLS && make clean
	cd RSEP4 && make clean
	cd TupleGeneratorVivado && make clean
	cd RSEInputBufferVivado && make clean
	cd RSEOutputBufferVivado && make clean

