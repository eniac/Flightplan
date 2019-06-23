.PHONY: All RSEEncoder1Port RSEDecoder1Port Memcached1Port RSEEncoder2Ports RSEDecoder2Ports Memcached2Ports \
        PacketDropper2Ports RSEEncoder4Ports RSEDecoder4Ports Memcached4Ports RSEEncoder1Port_project \
        RSEDecoder1Port_project Memcached1Port_project RSEEncoder2Ports_project RSEDecoder2Ports_project \
        Memcached2Ports_project PacketDropper2Ports RSEEncoder4Ports_project RSEDecoder4Ports_project \
        Memcached4Ports_project Compressor1Port_project Compressor2Port_project Compressor4Port_project \
	Decompressor1Port_project Decompressor2Port_project Decompressor4Port_project clean

All: RSEEncoder1Port RSEDecoder1Port Memcached1Port Compressor1Port RSEEncoder2Ports RSEDecoder2Ports \
     Memcached2Ports PacketDropper2Ports Compressor2Ports Decompressor1Ports Decompressor2Ports

RSEEncoder1Port_project:
	@rm -fr RSEEncoder1Port
	vivado -mode batch -source Create_project.tcl -tclargs ../RSEP4/Encoder/XilinxSwitch generic_1_port RSEEncoder1Port

RSEDecoder1Port_project:
	@rm -fr RSEDecoder1Port
	vivado -mode batch -source Create_project.tcl -tclargs ../DecoderP4/Decoder/XilinxSwitch generic_1_port RSEDecoder1Port

Memcached1Port_project:
	@rm -fr Memcached1Port
	vivado -mode batch -source Create_project.tcl -tclargs ../MemcachedP4/Encoder/XilinxSwitch generic_1_port Memcached1Port

Compressor1Port_project:
	@rm -fr Compressor1Port
	vivado -mode batch -source Create_project.tcl -tclargs ../CompressorP4/Encoder/XilinxSwitch generic_1_port Compressor1Port

Decompressor1Port_project:
	@rm -fr Decompressor1Port
	vivado -mode batch -source Create_project.tcl -tclargs ../DecompressorP4/Encoder/XilinxSwitch generic_1_port Decompressor1Port

RSEEncoder2Ports_project:
	@rm -fr RSEEncoder2Ports
	vivado -mode batch -source Create_project.tcl -tclargs ../RSEP4/Encoder/XilinxSwitch generic_2_ports RSEEncoder2Ports

RSEDecoder2Ports_project:
	@rm -fr RSEDecoder2Ports
	vivado -mode batch -source Create_project.tcl -tclargs ../DecoderP4/Decoder/XilinxSwitch generic_2_ports RSEDecoder2Ports

Memcached2Ports_project:
	@rm -fr Memcached2Ports
	vivado -mode batch -source Create_project.tcl -tclargs ../MemcachedP4/Encoder/XilinxSwitch generic_2_ports Memcached2Ports

Compressor2Ports_project:
	@rm -fr Compressor2Ports
	vivado -mode batch -source Create_project.tcl -tclargs ../CompressorP4/Encoder/XilinxSwitch generic_2_ports Compressor2Ports

Decompressor2Ports_project:
	@rm -fr Decompressor2Ports
	vivado -mode batch -source Create_project.tcl -tclargs ../DecompressorP4/Encoder/XilinxSwitch generic_2_ports Decompressor2Ports

PacketDropper2Ports_project:
	@rm -fr PacketDropper2Ports
	vivado -mode batch -source Create_PacketDropper2Ports_project.tcl

RSEEncoder4Ports_project:
	@rm -fr RSEEncoder4Ports
	vivado -mode batch -source Create_project.tcl -tclargs ../RSEP4/Encoder/XilinxSwitch generic_4_ports RSEEncoder4Ports

RSEDecoder4Ports_project:
	@rm -fr RSEDecoder4Ports
	vivado -mode batch -source Create_project.tcl -tclargs ../DecoderP4/Decoder/XilinxSwitch generic_4_ports RSEDecoder4Ports

Memcached4Ports_project:
	@rm -fr Memcached4Ports
	vivado -mode batch -source Create_project.tcl -tclargs ../MemcachedP4/Encoder/XilinxSwitch generic_4_ports Memcached4Ports

Compressor4Ports_project:
	@rm -fr Compressor4Ports
	vivado -mode batch -source Create_project.tcl -tclargs ../CompressorP4/Encoder/XilinxSwitch generic_4_ports Compressor4Ports

Decompressor4Ports_project:
	@rm -fr Decompressor4Ports
	vivado -mode batch -source Create_project.tcl -tclargs ../DecompressorP4/Encoder/XilinxSwitch generic_4_ports Decompressor4Ports

RSEEncoder1Port: RSEEncoder1Port_project
	vivado -mode batch -source Build_project.tcl -tclargs RSEEncoder1Port
	@mkdir -p RSEEncoder1Port/RSEEncoder1Port.sdk
	@cp RSEEncoder1Port/RSEEncoder1Port.runs/impl_1/design_1_wrapper.sysdef RSEEncoder1Port/RSEEncoder1Port.sdk/design_1_wrapper.hdf

RSEDecoder1Port: RSEDecoder1Port_project
	vivado -mode batch -source Build_project.tcl -tclargs RSEDecoder1Port
	@mkdir -p RSEDecoder1Port/RSEDecoder1Port.sdk
	@cp RSEDecoder1Port/RSEDecoder1Port.runs/impl_1/design_1_wrapper.sysdef RSEDecoder1Port/RSEDecoder1Port.sdk/design_1_wrapper.hdf

Memcached1Port: Memcached1Port_project
	vivado -mode batch -source Build_project.tcl -tclargs Memcached1Port
	@mkdir -p Memcached1Port/Memcached1Port.sdk
	@cp Memcached1Port/Memcached1Port.runs/impl_1/design_1_wrapper.sysdef Memcached1Port/Memcached1Port.sdk/design_1_wrapper.hdf

Compressor1Port: Compressor1Port_project
	vivado -mode batch -source Build_project.tcl -tclargs Compressor1Port
	@mkdir -p Compressor1Port/Compressor1Port.sdk
	@cp Compressor1Port/Compressor1Port.runs/impl_1/design_1_wrapper.sysdef Compressor1Port/Compressor1Port.sdk/design_1_wrapper.hdf

Decompressor1Port: Decompressor1Port_project
	vivado -mode batch -source Build_project.tcl -tclargs Decompressor1Port
	@mkdir -p Decompressor1Port/Decompressor1Port.sdk
	@cp Decompressor1Port/Decompressor1Port.runs/impl_1/design_1_wrapper.sysdef Decompressor1Port/Decompressor1Port.sdk/design_1_wrapper.hdf

RSEEncoder2Ports: RSEEncoder2Ports_project
	vivado -mode batch -source Build_project.tcl -tclargs RSEEncoder2Ports
	@mkdir -p RSEEncoder2Ports/RSEEncoder2Ports.sdk
	@cp RSEEncoder2Ports/RSEEncoder2Ports.runs/impl_1/design_1_wrapper.sysdef RSEEncoder2Ports/RSEEncoder2Ports.sdk/design_1_wrapper.hdf

RSEDecoder2Ports: RSEDecoder2Ports_project
	vivado -mode batch -source Build_project.tcl -tclargs RSEDecoder2Ports
	@mkdir -p RSEDecoder2Ports/RSEDecoder2Ports.sdk
	@cp RSEDecoder2Ports/RSEDecoder2Ports.runs/impl_1/design_1_wrapper.sysdef RSEDecoder2Ports/RSEDecoder2Ports.sdk/design_1_wrapper.hdf

Memcached2Ports: Memcached2Ports_project
	vivado -mode batch -source Build_project.tcl -tclargs Memcached2Ports
	@mkdir -p Memcached2Ports/Memcached2Ports.sdk
	@cp Memcached2Ports/Memcached2Ports.runs/impl_1/design_1_wrapper.sysdef Memcached2Ports/Memcached2Ports.sdk/design_1_wrapper.hdf

Compressor2Ports: Compressor2Ports_project
	vivado -mode batch -source Build_project.tcl -tclargs Compressor2Ports
	@mkdir -p Compressor2Ports/Compressor2Ports.sdk
	@cp Compressor2Ports/Compressor2Ports.runs/impl_1/design_1_wrapper.sysdef Compressor2Ports/Compressor2Ports.sdk/design_1_wrapper.hdf

Decompressor2Ports: Decompressor2Ports_project
	vivado -mode batch -source Build_project.tcl -tclargs Decompressor2Ports
	@mkdir -p Decompressor2Ports/Decompressor2Ports.sdk
	@cp Decompressor2Ports/Decompressor2Ports.runs/impl_1/design_1_wrapper.sysdef Decompressor2Ports/Decompressor2Ports.sdk/design_1_wrapper.hdf

PacketDropper2Ports: PacketDropper2Ports_project
	vivado -mode batch -source Build_project.tcl -tclargs PacketDropper2Ports
	@mkdir -p PacketDropper2Ports/PacketDropper2Ports.sdk
	@cp PacketDropper2Ports/PacketDropper2Ports.runs/impl_1/design_1_wrapper.sysdef PacketDropper2Ports/PacketDropper2Ports.sdk/design_1_wrapper.hdf

RSEEncoder4Ports: RSEEncoder4Ports_project
	vivado -mode batch -source Build_project.tcl -tclargs RSEEncoder4Ports
	@mkdir -p RSEEncoder4Ports/RSEEncoder4Ports.sdk
	@cp RSEEncoder4Ports/RSEEncoder4Ports.runs/impl_1/design_1_wrapper.sysdef RSEEncoder4Ports/RSEEncoder4Ports.sdk/design_1_wrapper.hdf

RSEDecoder4Ports: RSEDecoder4Ports_project
	vivado -mode batch -source Build_project.tcl -tclargs RSEDecoder4Ports
	@mkdir -p RSEDecoder4Ports/RSEDecoder4Ports.sdk
	@cp RSEDecoder4Ports/RSEDecoder4Ports.runs/impl_1/design_1_wrapper.sysdef RSEDecoder4Ports/RSEDecoder4Ports.sdk/design_1_wrapper.hdf

Memcached4Ports: Memcached4Ports_project
	vivado -mode batch -source Build_project.tcl -tclargs Memcached4Ports
	@mkdir -p Memcached4Ports/Memcached4Ports.sdk
	@cp Memcached4Ports/Memcached4Ports.runs/impl_1/design_1_wrapper.sysdef Memcached4Ports/Memcached4Ports.sdk/design_1_wrapper.hdf

Compressor4Ports: Compressor4Ports_project
	vivado -mode batch -source Build_project.tcl -tclargs Compressor4Ports
	@mkdir -p Compressor4Ports/Compressor4Ports.sdk
	@cp Compressor4Ports/Compressor4Ports.runs/impl_1/design_1_wrapper.sysdef Compressor4Ports/Compressor4Ports.sdk/design_1_wrapper.hdf

Decompressor4Ports: Decompressor4Ports_project
	vivado -mode batch -source Build_project.tcl -tclargs Decompressor4Ports
	@mkdir -p Decompressor4Ports/Decompressor4Ports.sdk
	@cp Decompressor4Ports/Decompressor4Ports.runs/impl_1/design_1_wrapper.sysdef Decompressor4Ports/Decompressor4Ports.sdk/design_1_wrapper.hdf
clean:
	rm -fr RSEEncoder1Port RSEDecoder1Port Memcached1Port Compressor1Port RSEEncoder2Ports RSEDecoder2Ports Memcached2Ports \
               Compressor2Ports PacketDropper2Ports RSEEncoder4Ports RSEDecoder4Ports Memcached4Ports Compressor4Ports \
	       Decompressor1Ports Decompressor2Ports Decompressor4Ports
	rm -f *.jou *.log

