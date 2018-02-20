.PHONY: All Create_project Build_project clean

All: Build_project

Create_project: RSEVivado
Build_project: Create_project
	vivado -mode batch -source Build_project.tcl

RSEVivado: Sources/Constraints.xdc Sources/design_1.bd Sources/design_1_wrapper.vhd
	vivado -mode batch -source Create_project.tcl

clean:
	rm -fr RSEVivado vivado.jou vivado.log Sources/design_1.bxml Sources/design_1_ooc.xdc \
               Sources/ip Sources/ui Sources/hdl Sources/hw_handoff Sources/ipshared

