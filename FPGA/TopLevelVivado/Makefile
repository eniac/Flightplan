.PHONY: All RSEEncoder1Port RSEDecoder1Port Memcached1Port RSEEncoder2Ports RSEDecoder2Ports Memcached2Ports \
        PacketDropper2Ports RSEEncoder1Port_project RSEDecoder1Port_project Memcached1Port_project \
        RSEEncoder2Ports_project RSEDecoder2Ports_project Memcached2Ports_project PacketDropper2Ports

All: RSEEncoder1Port RSEDecoder1Port Memcached1Port RSEEncoder2Ports RSEDecoder2Ports Memcached2Ports \
        PacketDropper2Ports

RSEEncoder1Port_project:
	@rm -fr RSEEncoder1Port
	vivado -mode batch -source Create_project.tcl -tclargs ../RSEP4/Encoder/XilinxSwitch generic_1_port RSEEncoder1Port

RSEDecoder1Port_project:
	@rm -fr RSEDecoder1Port
	vivado -mode batch -source Create_project.tcl -tclargs ../DecoderP4/Decoder/XilinxSwitch generic_1_port RSEDecoder1Port

Memcached1Port_project:
	@rm -fr Memcached1Port
	vivado -mode batch -source Create_project.tcl -tclargs ../MemcachedP4/Encoder/XilinxSwitch generic_1_port Memcached1Port

RSEEncoder2Ports_project:
	@rm -fr RSEEncoder2Ports
	vivado -mode batch -source Create_project.tcl -tclargs ../RSEP4/Encoder/XilinxSwitch generic_2_ports RSEEncoder2Ports

RSEDecoder2Ports_project:
	@rm -fr RSEDecoder2Ports
	vivado -mode batch -source Create_project.tcl -tclargs ../DecoderP4/Decoder/XilinxSwitch generic_2_ports RSEDecoder2Ports

Memcached2Ports_project:
	@rm -fr Memcached2Ports
	vivado -mode batch -source Create_project.tcl -tclargs ../MemcachedP4/Encoder/XilinxSwitch generic_2_ports Memcached2Ports

PacketDropper2Ports_project:
	@rm -fr PacketDropper2Ports
	vivado -mode batch -source Create_PacketDropper2Ports_project.tcl

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

RSEEncoder2Ports: RSEEncoder2Ports_project
	vivado -mode batch -source Build_project.tcl -tclargs RSEEncoder2Ports
	@mkdir -p RSEEncoder1Port/RSEEncoder1Port.sdk
	@cp RSEEncoder1Port/RSEEncoder1Port.runs/impl_1/design_1_wrapper.sysdef RSEEncoder1Port/RSEEncoder1Port.sdk/design_1_wrapper.hdf

RSEDecoder2Ports: RSEDecoder2Ports_project
	vivado -mode batch -source Build_project.tcl -tclargs RSEDecoder2Ports
	@mkdir -p RSEDecoder2Ports/RSEDecoder2Ports.sdk
	@cp RSEDecoder2Ports/RSEDecoder2Ports.runs/impl_1/design_1_wrapper.sysdef RSEDecoder2Ports/RSEDecoder2Ports.sdk/design_1_wrapper.hdf

Memcached2Ports: Memcached2Ports_project
	vivado -mode batch -source Build_project.tcl -tclargs Memcached2Ports
	@mkdir -p Memcached2Ports/Memcached2Ports.sdk
	@cp Memcached2Ports/Memcached2Ports.runs/impl_1/design_1_wrapper.sysdef Memcached2Ports/Memcached2Ports.sdk/design_1_wrapper.hdf

PacketDropper2Ports: PacketDropper2Ports_project
	vivado -mode batch -source Build_project.tcl -tclargs PacketDropper2Ports
	@mkdir -p PacketDropper2Ports/PacketDropper2Ports.sdk
	@cp PacketDropper2Ports/PacketDropper2Ports.runs/impl_1/design_1_wrapper.sysdef PacketDropper2Ports/PacketDropper2Ports.sdk/design_1_wrapper.hdf

clean:
	rm -fr RSEEncoder1Port RSEDecoder1Port Memcached1Port RSEEncoder2Ports RSEDecoder2Ports Memcached2Ports PacketDropper2Ports
	rm -f *.jou *.log

