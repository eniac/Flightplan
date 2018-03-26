.PHONY: All Create_project Build_project clean

All: Create_project Build_project

Create_project: RSEInputBufferVivado

Build_project: RSEInputBufferVivado
	vivado -mode batch -source Build_project.tcl

RSEInputBufferVivado: Sources/RSEInputBuffer.vhd Sources/packet_fifo.xci Sources/valid_fifo.xci
	vivado -mode batch -source Create_project.tcl

clean:
	rm -fr RSEInputBufferVivado *.jou *.log

