#!/bin/sh
lli=${LLVMINTERP-lli}
exec $lli \
    /home/gyzuh/University/DComp/Repository/P4Boosters/RSECore/RSECore/solution1/.autopilot/db/a.g.bc ${1+"$@"}
