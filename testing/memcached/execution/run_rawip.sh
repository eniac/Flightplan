#!/bin/bash

for i in {2..5};do
	python raw2ip.py test_multiple_run/fpga_inline_rerun_${i}/fpga_inline_rerun_${i}_1.00/moongen
	python raw2ip.py test_multiple_run/fpga_inline_rerun_${i}/fpga_inline_rerun_${i}_10.00/moongen
	python raw2ip.py test_multiple_run/fpga_inline_rerun_${i}/fpga_inline_rerun_${i}_25.00/moongen
	python raw2ip.py test_multiple_run/fpga_inline_rerun_${i}/fpga_inline_rerun_${i}_30.00/moongen
	python raw2ip.py test_multiple_run/fpga_inline_rerun_${i}/fpga_inline_rerun_${i}_32.00/moongen
	python raw2ip.py test_multiple_run/fpga_inline_rerun_${i}/fpga_inline_rerun_${i}_34.00/moongen
done	
