#If required use the below command and launch symbol server from an external shell.
#symbol_server -S -s tcp::1534
connect -path [list tcp::1534 tcp:hactar.seas.upenn.edu:3121]
source /home/gyzuh/SDx/SDx/2017.1/SDK/scripts/sdk/util/zynqmp_utils.tcl
targets -set -nocase -filter {name =~"APU*" && jtag_cable_name =~ "Digilent JTAG-SMT2NC 210308A47676"} -index 1
source /home/gyzuh/University/DComp/Repository/P4Boosters/FPGA/ForwarderSDx/Forwarder_hardware/psu_init.tcl
psu_init
after 1000
psu_ps_pl_isolation_removal
after 1000
psu_ps_pl_reset_config
catch {psu_protection}
targets -set -nocase -filter {name =~"*A53*0" && jtag_cable_name =~ "Digilent JTAG-SMT2NC 210308A47676"} -index 1
rst -processor
dow /home/gyzuh/University/DComp/Repository/P4Boosters/FPGA/ForwarderSDx/Forwarder_software/Debug/Forwarder_software.elf
bpadd -addr &main
