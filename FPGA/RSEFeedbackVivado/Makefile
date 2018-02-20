.PHONY: All Create_project Build_project clean

All: Create_project Build_project

Create_project: RSEFeedbackVivado
Build_project: RSEFeedbackVivado
	vivado -mode batch -source Build_project.tcl

RSEFeedbackVivado: Sources/RSEFeedback.vhd Sources/component.xml Sources/fifo_generator_0/fifo_generator_0.xci
	vivado -mode batch -source Create_project.tcl

clean:
	rm -fr RSEFeedbackVivado *.jou *.log \
	       $(shell find Sources/fifo_generator_0 -type f ! -path Sources/fifo_generator_0/fifo_generator_0.xci)

