onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+design_1 -L xil_defaultlib -L xpm -L gtwizard_ultrascale_v1_6_6 -L xxv_ethernet_v2_1_0 -L xlconstant_v1_1_3 -L util_vector_logic_v2_0_1 -L lib_cdc_v1_0_2 -L proc_sys_reset_v5_0_10 -L gigantic_mux -L generic_baseblocks_v2_1_0 -L fifo_generator_v13_1_4 -L axi_data_fifo_v2_1_11 -L axi_infrastructure_v1_1_0 -L axi_register_slice_v2_1_12 -L axi_protocol_converter_v2_1_12 -L axi_clock_converter_v2_1_11 -L blk_mem_gen_v8_3_6 -L axi_dwidth_converter_v2_1_12 -L axis_infrastructure_v1_1_0 -L axis_data_fifo_v1_1_13 -L axis_clock_converter_v1_1_13 -L axis_register_slice_v1_1_11 -L axis_subset_converter_v1_1_11 -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.design_1 xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {design_1.udo}

run -all

endsim

quit -force
