set DIR [lindex $argv 0]
set PROJECT [lindex $argv 1]
set DEVICE [lindex $argv 2]
setws $DIR/$PROJECT
connect -url tcp:127.0.0.1:3121
source $::env(SDSOC_ROOT)/SDK/scripts/sdk/util/zynqmp_utils.tcl
targets -set -nocase -filter {name =~"APU*" && jtag_cable_name =~ "Digilent JTAG-SMT2NC *" && jtag_cable_ctx =~ $DEVICE} -index 1
rst -system
after 3000
targets -set -filter {jtag_cable_name =~ "Digilent JTAG-SMT2NC *" && level==0 && jtag_cable_ctx =~ $DEVICE} -index 0
fpga -file $DIR/$PROJECT/HW/design_1_wrapper.bit
targets -set -nocase -filter {name =~"APU*" && jtag_cable_name =~ "Digilent JTAG-SMT2NC *" && jtag_cable_ctx =~ $DEVICE} -index 1
source $DIR/$PROJECT/HW/psu_init.tcl
psu_init
after 1000
psu_ps_pl_isolation_removal
after 1000
psu_ps_pl_reset_config
catch {psu_protection}
targets -set -nocase -filter {name =~"*A53*0" && jtag_cable_name =~ "Digilent JTAG-SMT2NC *" && jtag_cable_ctx =~ $DEVICE} -index 1
rst -processor
dow $DIR/$PROJECT/SW/Debug/SW.elf
con

