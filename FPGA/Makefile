.PHONY: All RSE RSEVivado RSEP4 RSEVivadoHLS RSEFeedbackVivado clean

All: RSE

RSE: RSEVivado

RSEVivado: RSEP4
	cd RSEVivado && make

RSEP4: RSEVivadoHLS RSEFeedbackVivado
	cd RSEP4 && make

RSEFeedbackVivado:
	cd RSEFeedbackVivado && make

RSEVivadoHLS:
	cd RSEVivadoHLS && make

clean:
	cd RSEVivado && make clean
	cd RSEVivadoHLS && make clean
	cd RSEP4 && make clean
	cd RSEFeedbackVivado && make clean

