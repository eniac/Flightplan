This directory contains a patch to the P4 compiler that
implements the P4 program analysis and splitting.
To use this, apply the [patch](flightplan.patch_516e1219ec59c06ca5640410423f653ad0fa49d1)
to commit `516e1219ec59c06ca5640410423f653ad0fa49d1` of p4c,
and build the compiler as normal.

The directory also contains the top-level Flightplan [source
header](Flightplan.p4) and the [analysis experiments](analyser_scripts) we
used, together with the[experiment output](analyser_scripts/flightplan_output)
we obtained. That output was fed to the [Flightplanner](flightplanner).
