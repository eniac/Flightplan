open_project RSEFeedbackVivado/RSEFeedbackVivado.xpr
generate_target all [get_files Sources/fifo_generator_0/fifo_generator_0.xci]
export_ip_user_files -of_objects [get_files Sources/fifo_generator_0/fifo_generator_0.xci] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] Sources/fifo_generator_0/fifo_generator_0.xci]
launch_runs -jobs 4 fifo_generator_0_synth_1
export_simulation -of_objects [get_files Sources/fifo_generator_0/fifo_generator_0.xci] -directory RSEFeedbackVivado/RSEFeedbackVivado.ip_user_files/sim_scripts -ip_user_files_dir RSEFeedbackVivado/RSEFeedbackVivado.ip_user_files -ipstatic_source_dir RSEFeedbackVivado/RSEFeedbackVivado.ip_user_files/ipstatic -lib_map_path [list {modelsim=RSEFeedbackVivado/RSEFeedbackVivado.cache/compile_simlib/modelsim} {questa=RSEFeedbackVivado/RSEFeedbackVivado.cache/compile_simlib/questa} {ies=RSEFeedbackVivado/RSEFeedbackVivado.cache/compile_simlib/ies} {vcs=RSEFeedbackVivado/RSEFeedbackVivado.cache/compile_simlib/vcs} {riviera=RSEFeedbackVivado/RSEFeedbackVivado.cache/compile_simlib/riviera}] -use_ip_compiled_libs -force -quiet
ipx::open_ipxact_file Sources/component.xml
ipx::merge_project_changes files [ipx::current_core]
set_property core_revision 7 [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
set_property  ip_repo_paths Sources [current_project]
update_ip_catalog
close_project

