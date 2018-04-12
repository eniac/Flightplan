.PHONY: All Create_project Build_project clean

All: Create_project Build_project

Create_project: TupleGeneratorVivado

Build_project: TupleGeneratorVivado
	vivado -mode batch -source Build_project.tcl

TupleGeneratorVivado: Sources/TupleGenerator.vhd
	vivado -mode batch -source Create_project.tcl

clean:
	rm -fr TupleGeneratorVivado *.jou *.log

