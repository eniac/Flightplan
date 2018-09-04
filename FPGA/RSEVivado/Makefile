.PHONY: All Create_project Build_project clean

All: Build_project

Memcached: MemVivado Build_project
Decoder: DecoderVivado Build_project

Create_project: RSEVivado
Build_project: Create_project
	vivado -mode batch -source Build_project.tcl
	@mkdir -p RSEVivado/RSEVivado.sdk
	@cp RSEVivado/RSEVivado.runs/impl_1/design_1_wrapper.sysdef RSEVivado/RSEVivado.sdk/design_1_wrapper.hdf

RSEVivado: Sources/Constraints.xdc Sources/design_1.bd Sources/design_1_wrapper.vhd
	sed -e 's/PATH_OF_XILINXSWITCH/..\/RSEP4\/Encoder\/XilinxSwitch/g' Create_project_template.tcl > Create_project.tcl
	vivado -mode batch -source Create_project.tcl

DecoderVivado: Sources/Constraints.xdc Sources/design_1.bd Sources/design_1_wrapper.vhd
	sed -e 's/PATH_OF_XILINXSWITCH/..\/DecoderP4\/Decoder\/XilinxSwitch/g' Create_project_template.tcl > Create_project.tcl
	vivado -mode batch -source Create_project.tcl

MemVivado: Sources/Constraints.xdc Sources/design_1.bd Sources/design_1_wrapper.vhd
	sed -e 's/PATH_OF_XILINXSWITCH/..\/MemcachedP4\/Encoder\/XilinxSwitch/g' Create_project_template.tcl > Create_project.tcl
	vivado -mode batch -source Create_project.tcl

clean:
	rm -fr RSEVivado vivado.jou vivado.log
	rm -fr Create_project.tcl

