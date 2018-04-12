.PHONY: All RSE RSEVivado RSEP4 RSEVivadoHLS TupleGeneratorVivado RSEInputBufferVivado clean

All: RSE

RSE: RSEVivado

RSEVivado: RSEP4 RSEInputBufferVivado TupleGeneratorVivado
	cd RSEVivado && make

RSEP4: RSEVivadoHLS
	cd RSEP4 && make

RSEInputBufferVivado:
	cd RSEInputBufferVivado && make

TupleGeneratorVivado:
	cd TupleGeneratorVivado && make

RSEVivadoHLS:
	cd RSEVivadoHLS && make

clean:
	cd RSEVivado && make clean
	cd RSEVivadoHLS && make clean
	cd RSEP4 && make clean
	cd TupleGeneratorVivado && make clean
	cd RSEInputBufferVivado && make clean

