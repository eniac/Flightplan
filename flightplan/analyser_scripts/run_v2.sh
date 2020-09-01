#!/bin/bash
# Nik Sultana, UPenn, August 2020

~/p4c/build/p4test \
        -DTARGET_BMV2 \
        -I /home/nik/P4Boosters/FPGA/RSEConfig/ \
        -I /home/nik/P4Boosters/FPGA/MemcachedP4/ \
        -I /home/nik/P4Boosters/FPGA/RSEVivadoHLS/ \
        -I /home/nik/P4Boosters/Wharf/Sources/ \
	-I /home/nik/p4c/t/Wharf \
        --pp ./test_output/pretty_printed.p4 \
        --dump ./test_output \
        --top4 FrontEndLast,FrontEndDump,MidEndLast,Flightplan \
        --testJson \
        --flightplan \
        --flightplan_dest flightplan_output \
        --flightplan_mode analyse \
        --flightplan_runtime ${RUNTIME} \
	${MORE_PARAMS} \
	${P4_FILE}
