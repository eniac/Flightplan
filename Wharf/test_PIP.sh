#!/bin/bash

p4test \
        -DTARGET_BMV2 \
        -I ../FPGA/RSEConfig/ \
        -I ./Sources \
        --testJson \
        Sources/CheckedFragment.p4
