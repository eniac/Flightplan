.PHONY: All RSE RSEVivado RSEP4 RSEVivadoHLS MemcachedVivadoHLS TupleGeneratorVivado RSEInputBufferVivado RSEOutputBufferVivado clean

All: RSE

RSE: RSEVivado

Memcached: MemcachedVivado

MemcachedVivado: MemcachedP4 RSEInputBufferVivado RSEOutputBufferVivado TupleGeneratorVivado
	cd RSEVivado && make Memcached

RSEVivado: RSEP4 RSEInputBufferVivado RSEOutputBufferVivado TupleGeneratorVivado
	cd RSEVivado && make

RSEP4: RSEVivadoHLS
	cd RSEP4 && make

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

MemcachedVivadoHLS:
	cd MemcachedVivadoHLS && make

clean:
	cd RSEVivado && make clean
	cd RSEVivadoHLS && make clean
	cd MemcachedVivadoHLS && make clean
	cd MemcachedP4 && make clean
	cd RSEP4 && make clean
	cd TupleGeneratorVivado && make clean
	cd RSEInputBufferVivado && make clean
	cd RSEOutputBufferVivado && make clean

