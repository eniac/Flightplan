.PHONY: All RSE Memcached Compressor RSEEncoder1PortSDx RSEDecoder1PortSDx \
	Memcached1PortSDx Compressor1PortSDx Decompressor1PortSDx RSEEncoder2PortsSDx \
	RSEDecoder2PortsSDx Memcached2PortsSDx Compressor2PortsSDx Decompressor2PortsSDx \
	PacketDropper2PortsSDx RSEEncoder4PortsVivado RSEDecoder4PortsVivado \
        Memcached4PortsSDx Compressor4PortsSDx RSEEncoder1PortVivado RSEDecoder1PortVivado \
	Memcached1PortVivado Compressor1PortVivado Decompressor1PortsVivado RSEEncoder2PortsVivado \
        RSEDecoder2PortsVivado Memcached2PortsVivado Compressor2PortsVivado Decompressor2PortsVivado\
	PacketDropper2PortsVivado RSEEncoder4PortsVivado \
        RSEDecoder4PortsVivado Memcached4PortsVivado Compressor4PortsVivado \
	RSEEncoderP4 RSEDecoderP4 MemcachedP4 CompressorP4 DecompressP4 PacketDropperVivado \
        RSEInputBufferVivado RSEOutputBufferVivado TupleGeneratorVivado RSEEncoderVivadoHLS RSEDecoderVivadoHLS \
        MemcachedVivadoHLS CompressorVivadoHLS DecompressorVivadoHLS

All: RSE Memcached Compressor

RSE: RSEEncoder1PortSDx RSEEncoder2PortsSDx RSEDecoder1PortSDx RSEDecoder2PortsSDx PacketDropper2PortsSDx
Memcached: Memcached1PortSDx Memcached2PortsSDx
HeaderCompression:Compressor2Ports Decompressor2Ports 

Decompressor: Decompressor1portSDx Decompressor2portSDx

RSEEncoder1PortSDx: RSEEncoder1PortVivado
	cd TopLevelSDx && make RSEEncoder1Port

RSEDecoder1PortSDx: RSEDecoder1PortVivado
	cd TopLevelSDx && make RSEDecoder1Port

Memcached1PortSDx: Memcached1PortVivado
	cd TopLevelSDx && make Memcached1Port

Compressor1PortSDx: Compressor1PortVivado
	cd TopLevelSDx && make Compressor1Port

Decompressor1PortSDx: Decompressor1PortVivado
	cd TopLevelSDx && make Decompressor1Port

RSEEncoder2PortsSDx: RSEEncoder2PortsVivado
	cd TopLevelSDx && make RSEEncoder2Ports

RSEDecoder2PortsSDx: RSEDecoder2PortsVivado
	cd TopLevelSDx && make RSEDecoder2Ports

Memcached2PortsSDx: Memcached2PortsVivado
	cd TopLevelSDx && make Memcached2Ports

Compressor2PortsSDx: Compressor2PortsVivado
	cd TopLevelSDx && make Compressor2Ports

Decompressor2PortsSDx: Decompressor2PortsVivado
	cd TopLevelSDx && make Decompressor2Ports

PacketDropper2PortsSDx: PacketDropper2PortsVivado
	cd TopLevelSDx && make PacketDropper2Ports

RSEEncoder4PortsSDx: RSEEncoder4PortsVivado
	cd TopLevelSDx && make RSEEncoder4Ports

RSEDecoder4PortsSDx: RSEDecoder4PortsVivado
	cd TopLevelSDx && make RSEDecoder4Ports

Memcached4PortsSDx: Memcached4PortsVivado
	cd TopLevelSDx && make Memcached4Ports

Compressor4portssdx: Compressor4portsvivado
	cd toplevelsdx && make Compressor4ports
Decompressor4portssdx: Decompressor4portsvivado
	cd toplevelsdx && make Decompressor4ports

RSEEncoder1PortVivado: RSEEncoderP4 RSEInputBufferVivado RSEOutputBufferVivado TupleGeneratorVivado
	cd TopLevelVivado && make RSEEncoder1Port

RSEDecoder1PortVivado: RSEDecoderP4 RSEInputBufferVivado RSEOutputBufferVivado TupleGeneratorVivado
	cd TopLevelVivado && make RSEDecoder1Port

Memcached1PortVivado: MemcachedP4 RSEInputBufferVivado RSEOutputBufferVivado TupleGeneratorVivado
	cd TopLevelVivado && make Memcached1Port

Compressor1PortVivado: CompressorP4 RSEInputBufferVivado RSEOutputBufferVivado TupleGeneratorVivado
	cd TopLevelVivado && make Compressor1Port

Decompressor1PortVivado: DecompressorP4 RSEInputBufferVivado RSEOutputBufferVivado TupleGeneratorVivado
	cd TopLevelVivado && make Decompressor1Port

RSEEncoder2PortsVivado: RSEEncoderP4 RSEInputBufferVivado RSEOutputBufferVivado TupleGeneratorVivado
	cd TopLevelVivado && make RSEEncoder2Ports

RSEDecoder2PortsVivado: RSEDecoderP4 RSEInputBufferVivado RSEOutputBufferVivado TupleGeneratorVivado
	cd TopLevelVivado && make RSEDecoder2Ports

Memcached2PortsVivado: MemcachedP4 RSEInputBufferVivado RSEOutputBufferVivado TupleGeneratorVivado
	cd TopLevelVivado && make Memcached2Ports

Compressor2PortsVivado: CompressorP4 RSEInputBufferVivado RSEOutputBufferVivado TupleGeneratorVivado
	cd TopLevelVivado && make Compressor2Ports

Decompressor2PortsVivado: DecompressorP4 RSEInputBufferVivado RSEOutputBufferVivado TupleGeneratorVivado
	cd TopLevelVivado && make Decompressor2Ports

PacketDropper2PortsVivado: PacketDropperVivado RSEInputBufferVivado RSEOutputBufferVivado
	cd TopLevelVivado && make PacketDropper2Ports

RSEEncoder4PortsVivado: RSEEncoderP4 RSEInputBufferVivado RSEOutputBufferVivado TupleGeneratorVivado
	cd TopLevelVivado && make RSEEncoder4Ports

RSEDecoder4PortsVivado: RSEDecoderP4 RSEInputBufferVivado RSEOutputBufferVivado TupleGeneratorVivado
	cd TopLevelVivado && make RSEDecoder4Ports

Memcached4PortsVivado: MemcachedP4 RSEInputBufferVivado RSEOutputBufferVivado TupleGeneratorVivado
	cd TopLevelVivado && make Memcached4Ports

Compressor4PortsVivado: CompressorP4 RSEInputBufferVivado RSEOutputBufferVivado TupleGeneratorVivado
	cd TopLevelVivado && make Compressor4Ports
Decompressor4PortsVivado: DecompressorP4 RSEInputBufferVivado RSEOutputBufferVivado TupleGeneratorVivado
	cd TopLevelVivado && make Decompressor4Ports

RSEEncoderP4: RSEEncoderVivadoHLS
	cd RSEP4 && make

RSEDecoderP4: RSEDecoderVivadoHLS
	cd DecoderP4 && make

MemcachedP4: MemcachedVivadoHLS
	cd MemcachedP4 && make

CompressorP4: CompressorVivadoHLS
	cd CompressorP4 && make

DecompressorP4: DecompressorVivadoHLS
	cd DecompressorP4 && make

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

CompressorVivadoHLS:
	cd CompressorVivadoHLS && make

DecompressorVivadoHLS:
	cd DecompressorVivadoHLS && make
clean:
	cd TopLevelSDx && make clean
	cd TopLevelVivado && make clean
	cd RSEP4 && make clean
	cd DecoderP4 && make clean
	cd MemcachedP4 && make clean
	cd DecompressorP4 && make clean
	cd CompressorP4 && make clean
	cd PacketDropperVivado && make clean
	cd RSEInputBufferVivado && make clean
	cd RSEOutputBufferVivado && make clean
	cd TupleGeneratorVivado && make clean
	cd RSEVivadoHLS && make clean
	cd DecoderVivadoHLS && make clean
	cd MemcachedVivadoHLS && make clean
	cd CompressorVivadoHLS && make clean
	cd DecompressorVivadoHLS && make clean
