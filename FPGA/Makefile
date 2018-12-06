.PHONY: All RSE Memcached RSEEncoder1PortSDx RSEDecoder1PortSDx Memcached1PortSDx RSEEncoder2PortsSDx \
	RSEDecoder2PortsSDx Memcached2PortsSDx PacketDropper2PortsSDx RSEEncoder1PortVivado RSEDecoder1PortVivado \
	Memcached1PortVivado RSEEncoder2PortsVivado RSEDecoder2PortsVivado Memcached2PortsVivado \
	PacketDropper2PortsVivado RSEEncoderP4 RSEDecoderP4 MemcachedP4 PacketDropperVivado RSEInputBufferVivado \
        RSEOutputBufferVivado TupleGeneratorVivado RSEEncoderVivadoHLS RSEDecoderVivadoHLS MemcachedVivadoHLS

All: RSE Memcached

RSE: RSEEncoder1PortSDx RSEEncoder2PortsSDx RSEDecoder1PortSDx RSEDecoder2PortsSDx PacketDropper2PortsSDx
Memcached: Memcached1PortSDx Memcached2PortsSDx

RSEEncoder1PortSDx: RSEEncoder1PortVivado
	cd TopLevelSDx && make RSEEncoder1Port

RSEDecoder1PortSDx: RSEDecoder1PortVivado
	cd TopLevelSDx && make RSEDecoder1Port

Memcached1PortSDx: Memcached1PortVivado
	cd TopLevelSDx && make Memcached1Port

RSEEncoder2PortsSDx: RSEEncoder2PortsVivado
	cd TopLevelSDx && make RSEEncoder2Ports

RSEDecoder2PortsSDx: RSEDecoder2PortsVivado
	cd TopLevelSDx && make RSEDecoder2Ports

Memcached2PortsSDx: Memcached2PortsVivado
	cd TopLevelSDx && make Memcached2Ports

PacketDropper2PortsSDx: PacketDropper2PortsVivado
	cd TopLevelSDx && make PacketDropper2Ports

RSEEncoder1PortVivado: RSEEncoderP4 RSEInputBufferVivado RSEOutputBufferVivado TupleGeneratorVivado
	cd TopLevelVivado && make RSEEncoder1Port

RSEDecoder1PortVivado: RSEDecoderP4 RSEInputBufferVivado RSEOutputBufferVivado TupleGeneratorVivado
	cd TopLevelVivado && make RSEDecoder1Port

Memcached1PortVivado: MemcachedP4 RSEInputBufferVivado RSEOutputBufferVivado TupleGeneratorVivado
	cd TopLevelVivado && make Memcached1Port

RSEEncoder2PortsVivado: RSEEncoderP4 RSEInputBufferVivado RSEOutputBufferVivado TupleGeneratorVivado
	cd TopLevelVivado && make RSEEncoder2Ports

RSEDecoder2PortsVivado: RSEDecoderP4 RSEInputBufferVivado RSEOutputBufferVivado TupleGeneratorVivado
	cd TopLevelVivado && make RSEDecoder2Ports

Memcached2PortsVivado: MemcachedP4 RSEInputBufferVivado RSEOutputBufferVivado TupleGeneratorVivado
	cd TopLevelVivado && make Memcached2Ports

PacketDropper2PortsVivado: PacketDropperVivado RSEInputBufferVivado RSEOutputBufferVivado
	cd TopLevelVivado && make PacketDropper2Ports

RSEEncoderP4: RSEEncoderVivadoHLS
	cd RSEP4 && make

RSEDecoderP4: RSEDecoderVivadoHLS
	cd DecoderP4 && make

MemcachedP4: MemcachedVivadoHLS
	cd MemcachedP4 && make

PacketDropperVivado:
	cd PacketDropperVivado && make

RSEInputBufferVivado:
	cd RSEInputBufferVivado && make

RSEOutputBufferVivado:
	cd RSEOutputBufferVivado && make

TupleGeneratorVivado:
	cd TupleGeneratorVivado && make

RSEEncoderVivadoHLS:
	cd RSEVivadoHLS && make

RSEDecoderVivadoHLS:
	cd DecoderVivadoHLS && make

MemcachedVivadoHLS:
	cd MemcachedVivadoHLS && make

clean:
	cd TopLevelSDx && make clean
	cd TopLevelVivado && make clean
	cd RSEP4 && make clean
	cd DecoderP4 && make clean
	cd MemcachedP4 && make clean
	cd PacketDropperVivado && make clean
	cd RSEInputBufferVivado && make clean
	cd RSEOutputBufferVivado && make clean
	cd TupleGeneratorVivado && make clean
	cd RSEVivadoHLS && make clean
	cd DecoderVivadoHLS && make clean
	cd MemcachedVivadoHLS && make clean

