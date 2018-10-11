.PHONY: All Create_project Build_project clean

All: Build_project

Create_project:
	vivado -mode batch -source Create_project.tcl

Build_project: Create_project
	vivado -mode batch -source Build_project.tcl
	@mkdir -p PacketDropperTopVivado/PacketDropperTopVivado.sdk
	@cp PacketDropperTopVivado/PacketDropperTopVivado.runs/impl_1/design_1_wrapper.sysdef PacketDropperTopVivado/PacketDropperTopVivado.sdk/design_1_wrapper.hdf

clean:
	rm -fr PacketDropperTopVivado vivado*.jou vivado*.log

