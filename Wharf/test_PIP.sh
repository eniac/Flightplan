#!/bin/bash

~/p4c/build/p4test \
        -DTARGET_BMV2 \
        -I ~/P4Boosters/FPGA/RSEConfig/ \
        -I ~/P4Boosters/Wharf \
        -I ~/P4Boosters/Wharf/Sources \
        --testJson \
        Sources/CheckedFragment.p4
