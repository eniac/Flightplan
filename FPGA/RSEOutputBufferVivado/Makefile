.PHONY: All Create_project Build_project clean

All: Create_project Build_project

Create_project: RSEOutputBufferVivado

Build_project: RSEOutputBufferVivado
	vivado -mode batch -source Build_project.tcl

RSEOutputBufferVivado: Sources/RSEOutputBuffer.vhd Sources/fifo.xci
	vivado -mode batch -source Create_project.tcl

clean:
	rm -fr RSEOutputBufferVivado *.jou *.log

