.PHONY: All Create_project Build_project clean

All: Create_project Build_project

Create_project: PacketDropperVivado

Build_project: PacketDropperVivado
	vivado -mode batch -source Build_project.tcl

PacketDropperVivado: Sources/PacketDropper.vhd
	vivado -mode batch -source Create_project.tcl

clean:
	rm -fr PacketDropperVivado *.jou *.log

