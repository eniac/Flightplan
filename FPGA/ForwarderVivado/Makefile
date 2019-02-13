.PHONY: Forwarder Forwarder_project

All: Forwarder

Forwarder_project:
	@rm -fr ForwarderVivado
	vivado -mode batch -source Create_project.tcl

Forwarder: Forwarder_project
	vivado -mode batch -source Build_project.tcl
	@mkdir -p ForwarderVivado/ForwarderVivado.sdk
	@cp ForwarderVivado/ForwarderVivado.runs/impl_1/design_1_wrapper.sysdef ForwarderVivado/ForwarderVivado.sdk/design_1_wrapper.hdf

clean:
	rm -fr ForwarderVivado
	rm -f *.jou *.log

