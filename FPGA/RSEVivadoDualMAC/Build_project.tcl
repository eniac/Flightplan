open_project RSEVivado/RSEVivado.xpr
reset_run synth_1
generate_target all [get_files -of_objects [get_filesets sources_1] [list "*design_1.bd"]]
launch_runs impl_1 -to_step write_bitstream -jobs 2
wait_on_run impl_1
set impl_status [get_property STATUS [get_runs impl_1]]
set impl_progress [get_property PROGRESS [get_runs impl_1]]
if {$impl_status != "write_bitstream Complete!" || $impl_progress != "100%"} {
  puts "Synthesis failed."
  exit 1
}
close_project

