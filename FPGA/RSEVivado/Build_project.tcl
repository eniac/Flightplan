open_project RSEVivado/RSEVivado.xpr
generate_target all [get_files Sources/design_1.bd]
launch_runs impl_1 -to_step write_bitstream -jobs 2
wait_on_run impl_1
set synth_status [get_property STATUS [get_runs synth_1]]
set synth_progress [get_property PROGRESS [get_runs synth_1]]
if {$synth_status != "synth_design Complete!" || $synth_progress != "100%"} {
  puts "Synthesis failed."
  exit 1
}
close_project

