set DIR [lindex $argv 0]
setws $DIR/PacketDropperTopSDx
deleteprojects -name SW
createapp -name SW -app {Empty Application} -proc psu_cortexa53_0 -hwproject HW -bsp BSP -lang c -arch 64
importsources -name SW -path $DIR/Sources
projects -build -type app -name SW

set DEVICE [lindex $argv 1]
connect -url tcp:127.0.0.1:3121
source $::env(SDSOC_ROOT)/SDK/scripts/sdk/util/zynqmp_utils.tcl
targets -set -nocase -filter {name =~"*A53*0" && jtag_cable_name =~ "Digilent JTAG-SMT2NC *" && jtag_cable_ctx =~ $DEVICE} -index 1
rst -processor
dow $DIR/PacketDropperTopSDx/SW/Debug/SW.elf
con

