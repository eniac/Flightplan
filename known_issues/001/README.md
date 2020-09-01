**The source code(p4) line doesn't make it to the compiler output(JSON).**

The observation is deterministic. It is observed every time autotest1 is executed.
The command used to execute autotest1: "MODE=autotest1 ./tests.sh"

Line 221 of FPRuntime.p4 doesn't execute.
We can detect it as follows:
"If the received packet's header 'FPNak' bit is SET, then we check the outgoing packet's header InvalidCodeFlow bit. If this bit is SET, we know that invoked=1 didn't execute."

The description of snapshots read as follows:

"FPRuntime-JSON_tbl_act_27.png" contains
the highlighted line:56 [FPRuntime.p4: last line of relink() function, which is called by check_nak() function] and
tbl_act_27 [ALV_part1.json].
"FPRuntime-JSON_act_23.png" contains
the highlighted line:56 [FPRuntime.p4: last line of relink() function, which is called by check_nak() function] and
act_23 [ALV_part1.json] which is linked with tbl_act_27.
"FPRuntime-JSON_tbl_act_28.png" contains
the highlighted line:221,222 [FPRuntime.p4: inside check_nak() function right after relink() function call] and
tbl_act_28 [ALV_part1.json], which is called right after tbl_act_27.
tbl_act_28 is now modified to start with line221.
"FPRuntime-JSON_act_26_A.png" contains
the highlighted line:221,222 [FPRuntime.p4: inside check_nak() function right after relink() function call] and
act_26 [ALV_part1.json] which is linked with tbl_act_28.
The highlighted part in the JSON is the code manually added to include line 221
"FPRuntime-JSON_act_26_B.png" contains
the highlighted line:221,222 [FPRuntime.p4: inside check_nak() function right after relink() function call] and
the remaining act_26 [ALV_part1.json] which is linked with tbl_act_28.
"p0e0_log_file_comparison.png" contains
The p0e0 log file before and after the change in JSON.
The above half of the image is the p0e0 after changes in JSON, this shows the execution of line221.
It also shows the condition "1 == invoked" to be True, which is expected on execution of line 221.
The "ALV_part1.json" and "FPRuntime.p4" file have also been attached for ready reference.