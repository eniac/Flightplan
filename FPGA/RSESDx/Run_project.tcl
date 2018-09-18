set DIR [lindex $argv 0]
setws $DIR/RSESDx
connect -url tcp:127.0.0.1:3121
source /opt/Xilinx/SDx/2017.1/SDK/scripts/sdk/util/zynqmp_utils.tcl
targets -set -nocase -filter {name =~"APU*" && jtag_cable_name =~ "Digilent JTAG-SMT2NC *"} -index 1
rst -system
after 3000
targets -set -filter {jtag_cable_name =~ "Digilent JTAG-SMT2NC *" && level==0} -index 0
fpga -file $DIR/RSESDx/HW/design_1_wrapper.bit
targets -set -nocase -filter {name =~"APU*" && jtag_cable_name =~ "Digilent JTAG-SMT2NC *"} -index 1
source $DIR/RSESDx/HW/psu_init.tcl
psu_init
after 1000
psu_ps_pl_isolation_removal
after 1000
psu_ps_pl_reset_config
catch {psu_protection}
targets -set -nocase -filter {name =~"*A53*0" && jtag_cable_name =~ "Digilent JTAG-SMT2NC *"} -index 1
rst -processor
dow $DIR/RSESDx/SW/Debug/SW.elf
con
