open_project RSEFeedbackVivado/RSEFeedbackVivado.xpr

set file_obj [get_files -of_objects [get_filesets sources_1] [list "*fifo_generator_0.xci"]]
generate_target all $file_obj
export_ip_user_files -of_objects $file_obj -no_script -sync -force -quiet
create_ip_run $file_obj
launch_runs -jobs 2 fifo_generator_0_synth_1
export_simulation -of_objects $file_obj -directory RSEFeedbackVivado/RSEFeedbackVivado.ip_user_files/sim_scripts -ip_user_files_dir RSEFeedbackVivado/RSEFeedbackVivado.ip_user_files -ipstatic_source_dir RSEFeedbackVivado/RSEFeedbackVivado.ip_user_files/ipstatic -lib_map_path [list {modelsim=RSEFeedbackVivado/RSEFeedbackVivado.cache/compile_simlib/modelsim} {questa=RSEFeedbackVivado/RSEFeedbackVivado.cache/compile_simlib/questa} {ies=RSEFeedbackVivado/RSEFeedbackVivado.cache/compile_simlib/ies} {vcs=RSEFeedbackVivado/RSEFeedbackVivado.cache/compile_simlib/vcs} {riviera=RSEFeedbackVivado/RSEFeedbackVivado.cache/compile_simlib/riviera}] -use_ip_compiled_libs -force -quiet

set ip_repo_path [file normalize "RSEFeedbackVivado/RSEFeedbackVivado.srcs"]
ipx::package_project -root_dir $ip_repo_path -vendor upenn.edu -library user -taxonomy /UserIP -force
set_property name RSEFeedbackVivado [ipx::current_core]
set_property display_name RSEFeedbackVivado_v1_0 [ipx::current_core]
set_property description "Feedback for RSE booster" [ipx::current_core]
ipx::infer_bus_interface clk_line xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]
ipx::associate_bus_interfaces -busif axis_in -clock clk_line [ipx::current_core]
ipx::associate_bus_interfaces -busif axis_out -clock clk_line [ipx::current_core]
ipx::associate_bus_interfaces -busif rse_in -clock clk_line [ipx::current_core]
ipx::associate_bus_interfaces -busif rse_out -clock clk_line [ipx::current_core]
ipx::add_bus_parameter POLARITY [ipx::get_bus_interfaces clk_line_rst -of_objects [ipx::current_core]]
set_property value ACTIVE_HIGH [ipx::get_bus_parameters POLARITY -of_objects [ipx::get_bus_interfaces clk_line_rst -of_objects [ipx::current_core]]]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
set_property ip_repo_paths $ip_repo_path [current_project]
update_ip_catalog

close_project

