open_project PacketDropperVivado/PacketDropperVivado.xpr

set ip_repo_path [file normalize "PacketDropperVivado/PacketDropperVivado.srcs"]
ipx::package_project -root_dir $ip_repo_path -vendor upenn.edu -library user -taxonomy /UserIP -force
set_property name PacketDropperVivado [ipx::current_core]
set_property display_name PacketDropperVivado_v1_0 [ipx::current_core]
set_property description "Packet dropper" [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
set_property ip_repo_paths $ip_repo_path [current_project]
update_ip_catalog

close_project

