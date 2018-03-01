.PHONY: All Create_project Build_project clean

All: Create_project Build_project

Create_project: RSEFeedbackVivado

Build_project: RSEFeedbackVivado
	vivado -mode batch -source Build_project.tcl

RSEFeedbackVivado: Sources/RSEFeedback.vhd Sources/component.xml Sources/fifo_generator_0/fifo_generator_0.xci
	@sed -e '1 i package Config is' -e '$$ a end package;' -e 's:\s*//.*$$::' -e 's/#define\s\+\(\S\+\)\s\+\(.\+\)/constant \1: integer := \2;/' ../RSEConfig/Configuration.h > Sources/Config.vhd
	vivado -mode batch -source Create_project.tcl

clean:
	rm -fr RSEFeedbackVivado *.jou *.log \
	       $(shell find Sources/fifo_generator_0 -type f ! -path Sources/fifo_generator_0/fifo_generator_0.xci)

