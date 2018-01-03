//----------------------------------------------------------------------------
//   This file is owned and controlled by Xilinx and must be used solely    //
//   for design, simulation, implementation and creation of design files    //
//   limited to Xilinx devices or technologies. Use with non-Xilinx         //
//   devices or technologies is expressly prohibited and immediately        //
//   terminates your license.                                               //
//                                                                          //
//   XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS" SOLELY   //
//   FOR USE IN DEVELOPING PROGRAMS AND SOLUTIONS FOR XILINX DEVICES.  BY   //
//   PROVIDING THIS DESIGN, CODE, OR INFORMATION AS ONE POSSIBLE            //
//   IMPLEMENTATION OF THIS FEATURE, APPLICATION OR STANDARD, XILINX IS     //
//   MAKING NO REPRESENTATION THAT THIS IMPLEMENTATION IS FREE FROM ANY     //
//   CLAIMS OF INFRINGEMENT, AND YOU ARE RESPONSIBLE FOR OBTAINING ANY      //
//   RIGHTS YOU MAY REQUIRE FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY      //
//   DISCLAIMS ANY WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE  //
//   IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR         //
//   REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF        //
//   INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A  //
//   PARTICULAR PURPOSE.                                                    //
//                                                                          //
//   Xilinx products are not intended for use in life support appliances,   //
//   devices, or systems.  Use in such applications are expressly           //
//   prohibited.                                                            //
//                                                                          //
//   (c) Copyright 1995-2015 Xilinx, Inc.                                   //
//   All rights reserved.                                                   //
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------


//----------------------------------------------------------------------------
// File name: S_SYNCER_for_RemoveHeaders.v
// File created: 2017/10/23 14:31:57
// Created by: Xilinx SDNet Compiler version 2017.2.1, build 1997167

//----------------------------------------------------------------------------

`timescale 1 ns / 100 ps

module S_SYNCER_for_RemoveHeaders (
     packet_in_PACKET3_SOF, 
     packet_in_PACKET3_EOF, 
     packet_in_PACKET3_VAL, 
     packet_in_PACKET3_DAT, 
     packet_in_PACKET3_CNT, 
     packet_in_PACKET3_ERR, 
     packet_out_PACKET3_RDY, 
     tuple_in_TUPLE0_VALID, 
     tuple_in_TUPLE0_DATA, 
     tuple_in_TUPLE1_VALID, 
     tuple_in_TUPLE1_DATA, 
     tuple_in_TUPLE2_VALID, 
     tuple_in_TUPLE2_DATA, 
     backpressure_in, 


     packet_out_PACKET3_SOF, 
     packet_out_PACKET3_EOF, 
     packet_out_PACKET3_VAL, 
     packet_out_PACKET3_DAT, 
     packet_out_PACKET3_CNT, 
     packet_out_PACKET3_ERR, 
     packet_in_PACKET3_RDY, 
     tuple_out_TUPLE0_VALID, 
     tuple_out_TUPLE0_DATA, 
     tuple_out_TUPLE1_VALID, 
     tuple_out_TUPLE1_DATA, 
     tuple_out_TUPLE2_VALID, 
     tuple_out_TUPLE2_DATA, 
     backpressure_out, 

     clk_in_0, 
     clk_out_0, 
     clk_in_1, 
     clk_out_1, 
     clk_in_2, 
     clk_out_2, 
     clk_in_3, 
     clk_out_3, 
     rst_in_0, 
     rst_out_0, 
     rst_in_1, 
     rst_out_1, 
     rst_in_2, 
     rst_out_2, 
     rst_in_3, 
     rst_out_3 

);

//-------------------------------------------------------------
// I/O
//-------------------------------------------------------------
 input		packet_in_PACKET3_SOF ;
 input		packet_in_PACKET3_EOF ;
 input		packet_in_PACKET3_VAL ;
 input	 [63:0] packet_in_PACKET3_DAT ;
 input	 [3:0] packet_in_PACKET3_CNT ;
 input		packet_in_PACKET3_ERR ;
 input		packet_out_PACKET3_RDY ;
 input		tuple_in_TUPLE0_VALID ;
 input	 [31:0] tuple_in_TUPLE0_DATA ;
 input		tuple_in_TUPLE1_VALID ;
 input	 [820:0] tuple_in_TUPLE1_DATA ;
 input		tuple_in_TUPLE2_VALID ;
 input	 [22:0] tuple_in_TUPLE2_DATA ;
 input		backpressure_in ;
 output		packet_out_PACKET3_SOF ;
 output		packet_out_PACKET3_EOF ;
 output		packet_out_PACKET3_VAL ;
 output	 [63:0] packet_out_PACKET3_DAT ;
 output	 [3:0] packet_out_PACKET3_CNT ;
 output		packet_out_PACKET3_ERR ;
 output		packet_in_PACKET3_RDY ;
 output		tuple_out_TUPLE0_VALID ;
 output	 [31:0] tuple_out_TUPLE0_DATA ;
 output		tuple_out_TUPLE1_VALID ;
 output	 [820:0] tuple_out_TUPLE1_DATA ;
 output		tuple_out_TUPLE2_VALID ;
 output	 [22:0] tuple_out_TUPLE2_DATA ;
 output	reg	backpressure_out ;
 input		clk_in_0 ;
 input		clk_out_0 ;
 input		clk_in_1 ;
 input		clk_out_1 ;
 input		clk_in_2 ;
 input		clk_out_2 ;
 input		clk_in_3 ;
 input		clk_out_3 ;
 input		rst_in_0 ;
 input		rst_out_0 ;
 input		rst_in_1 ;
 input		rst_out_1 ;
 input		rst_in_2 ;
 input		rst_out_2 ;
 input		rst_in_3 ;
 input		rst_out_3 ;






 reg	tiaj1nbi55zrf6ukdy7dvdwqel_840;	 initial tiaj1nbi55zrf6ukdy7dvdwqel_840 = 1'b0 ;
 wire	rvc5cgvbqggz3k5i_606 ;
 wire [71:0] uvo51flf76xs3dyfucck9s_372 ;
 wire	q607ajy8ew1wq4k7_221 ;
 wire	dzvh4vxfdwcqs6wu4shck0xfh0_753 ;
 wire	wu9zev365f40nbnmrhwft1ja9u1m3e_335 ;
 wire [8:0] gvd2udahb66ng9sy5_169 ;
 wire [8:0] z80cpo6h9kwjq6oo_129 ;
 wire	xl6o26k7prd6llmqtmz_831 ;
 wire	a6ug8o8pa8lqjeb4sbf1_17 ;
 wire	uukfyb0v910s0abagwjk_672 ;
 wire	csudlty0i9ish78w3luj6kwbpv9c_619 ;
 wire	htam5lbwqnf2n24061g9jio8reqk6z_247 ;
 wire	f5gb6fapizsazwo3kj_35 ;
 wire	mjy6aqzwiah8zw874zp_860 ;
 reg	qgtcm2l4pnyhk5dmkz7s7kjwmbbbmut_875;	 initial qgtcm2l4pnyhk5dmkz7s7kjwmbbbmut_875 = 1'b0 ;
 wire	xdf2rxmuucv800a6igsxcxbo4em59_401 ;
 reg	hfvtelwjhislprxxp5hylgjx9xtlwn6_821;	 initial hfvtelwjhislprxxp5hylgjx9xtlwn6_821 = 1'b0 ;
 reg	os5yok43q3k6hjn6og1hvhz7n0fw6oxr_459;	 initial os5yok43q3k6hjn6og1hvhz7n0fw6oxr_459 = 1'b0 ;
 wire	v30vu8bia6qj3f8vum9kvbnb_58 ;
 wire [0:0] ho282ixebe319z1yo75p_413 ;
 wire	hmi0ifgiecwljfc5ys_355 ;
 wire	wis9tv24iixmvrr5w_502 ;
 wire	eemw0236ts2u3qizfog_559 ;
 wire [8:0] opyrm0iuvof6k17wumtmhw_525 ;
 wire [8:0] aw9vvo9veecgwzr22qe2v9pp_72 ;
 wire	gby130pt3pno1oto834st_330 ;
 wire	jtgo59ccpvgud881f8iw_421 ;
 wire	fypfivhqfs1wi926xa7krsf_819 ;
 wire	mex051rcu7h8b4uyl6p9xj6hnud_582 ;
 wire	rmkzowkryfadh8eq7f53h_672 ;
 wire	a8rcy1q8xbsm54rma37xp5jcdag722_361 ;
 reg [8:0] p3chx0xihqjqp8l1iuitc7gz9yyx_308;	 initial p3chx0xihqjqp8l1iuitc7gz9yyx_308 = 9'b000000000 ;
 reg	acicg10p71zyff6jz9nvhs8ip7f0bt_771;	 initial acicg10p71zyff6jz9nvhs8ip7f0bt_771 = 1'b0 ;
 wire	o4z11fd0r6iu4ulvearqmwnwd4tyif_324 ;
 wire [31:0] lxyawkij87pwo8k0a98c1tieyo_350 ;
 wire	sql1xboltmm57uumubsat0ac_522 ;
 wire	ypv937hitisvvhb95f7t5lv_794 ;
 wire	puoqlctrxopxhh0d1dbg9345_262 ;
 wire [7:0] eh7fmcoznej6i0oldtehqcy_756 ;
 wire [7:0] bpn85ua9bqgp82x0hrd7vp_418 ;
 wire	t9ehnj9bufvhiy6kidhfo7whjr6xlb38_423 ;
 wire	p5nbtc32pfrxlz0ds0c6_760 ;
 wire	t35078bum6o3m0j2fdpdnyzctz_527 ;
 wire	ne2x9lfn17939fcr2fe3ctxp2bj_645 ;
 wire	nyypzuz6onz2p47tr9zhumaglerwvig9_562 ;
 wire	mq59ludylji7ta8ew_504 ;
 wire	velb18exlxogvq41lzszrzkrn_525 ;
 wire [820:0] wdxih2b0hphy6gnzarzzqe42yr5nf_320 ;
 wire	n4nfy15bn6tcpdvbvzp_43 ;
 wire	dpvrezok4qqhwavq7y_767 ;
 wire	yssm788n871yema8izlvhindqze91_529 ;
 wire [7:0] qdm24vwe63p0kzj09ss2q_728 ;
 wire [7:0] un0ditzgx8i8h6bljoatj01_468 ;
 wire	qfzjwy2i803h0d42d0zff6s0sdtc7ltm_698 ;
 wire	uirg1rqxb6r8800l3edcy59q15uo1oj_800 ;
 wire	ukffi34g8887akqhtnal1lk4ml_78 ;
 wire	d7rxpw8gko8q0mtkn5w0o0rn_132 ;
 wire	fauxif1v12ht31c5m8d11_165 ;
 wire	j0in8an4bg857wp6z5mp6uqxvcgwmgk5_219 ;
 wire	fcxjhqpz4zm3nutqwwd_461 ;
 wire [22:0] dvafc2357i94ei0orwgiwd1m_711 ;
 wire	dcuu9f9i2rd63967nab_63 ;
 wire	bnluooedrxcqjye4voh_766 ;
 wire	jdr75udrueiksa52wla33m_705 ;
 wire [7:0] nq7mdk317yabgx036_319 ;
 wire [7:0] lg10r4m4lzhgkwyhqra_250 ;
 wire	ox8wbi7so6x523uwjoq7zib2gv_811 ;
 wire	aivbygnrl1jrd9in_413 ;
 wire	swktat7jg7cdaev5gmr_300 ;
 wire	ngi1q1i2hv07bp6jr3zrzhv_498 ;
 wire	w7puuqw8pn3b3oa2ctnls4xw8z06505_180 ;
 wire	oby8hynb4egmtcbr0j_27 ;
 reg	a5gztyjomnq89gvxqk4t_147;	 initial a5gztyjomnq89gvxqk4t_147 = 1'b0 ;
 reg	vhpypps1lkdbjclih3im32ng2d1tmnfe_500;	 initial vhpypps1lkdbjclih3im32ng2d1tmnfe_500 = 1'b0 ;
 reg	l42paenoaml39ch2_769;	 initial l42paenoaml39ch2_769 = 1'b0 ;
 reg	jggsg5wi5k4u3zq8sreh2m9py_219;	 initial jggsg5wi5k4u3zq8sreh2m9py_219 = 1'b0 ;
 wire	zr4j18ir80hecv4elxvexx9stg553l_861 ;
 wire [71:0] j2tx9d5le0bnu2w66v0c1w2_122 ;
 wire	hsm9opar1juhgs94qzft242bj7c18_502 ;
 wire [71:0] z4wrojdoz0ivpqcp6ekom4exo772m_148 ;
 wire	dqp7whw9f1j8xpuvopi9nkwlerm6y_259 ;
 wire	tqjvu0amin8c7p75gic38pkj4ypq4g_234 ;
 wire	sjisw8ztunw0d9lf_717 ;
 wire	ys4ojvevne452y1vbuii65xut6qibr_106 ;
 wire	n61jo7vu1r86zfyg39_284 ;
 wire	p845fr2spjczml7bvgknc93ztmsp37zm_661 ;
 wire	wqdd402b5lrhw2559vo_736 ;
 wire	q4ozk2h2si20292y2ph2l9ejodb6t9_805 ;
 wire	wc6ug6a2ciatk17dv_484 ;
 wire	g7vii692t0uo354ibed0qsdwxk77zr_100 ;
 wire [3:0] vx6z5t88ix0txxrq_823 ;
 wire [63:0] n2qer9fdb5xvlwqmtpssqbc_210 ;
 wire	v6pj775lle6asee3b30l3pvwn_201 ;
 wire	hs8zdo9kicf4r395g9alr_392 ;
 wire	eqgn3xjlq48ovywq7neb441xtcv_653 ;
 wire	wsqoje2n1v44tj7pl83xm0jechq4n9a_272 ;
 wire	cj6o9bgzr6ym1b5c92wtx0780r_657 ;
 wire [0:0] o9stq274d52n3cadze40ly_879 ;
 wire	tfhjri21i20g9o0c8mc1sczoxchyn_317 ;
 wire	x93d5t7kamuodmn6uzxw7nt38usue_698 ;
 wire [8:0] i7ws5ucorphfjaebt94rhob8t2yzzbs1_283 ;
 wire	amf3hqaxnwgvmu3u_839 ;
 wire	i0eams6p90447s4p8o6uqed_73 ;
 wire	xku960zn74e7otgr7mcr_68 ;
 wire	y9cv6ackfqxjqyr1i0tfd8upjywv_257 ;
 wire	x5wb324hail89l83gw97ek3elb_130 ;
 wire	p9v19q9yckzrihxw5dg7fy0e4sv840_516 ;
 wire	znojwl4mo04wrpbawjw3jjcgsk8ar_451 ;
 wire [31:0] t2z224021a0nizh7of0eh6ue6alo_51 ;
 wire	hmmhlxrfoxdzygj9rwa_496 ;
 wire [31:0] h0ru5zd2s31kcaiuwx1v6z20zxjxqxl_42 ;
 wire	xmv17gkrwk3hh549_312 ;
 wire	aig29ttuqtbe1hzs56ro7we05172h91a_346 ;
 wire	s0azn6fyfwovlvd7ae5zua_97 ;
 wire [820:0] kihekt3be27xgpe4t4wx9iz1n8y_632 ;
 wire	fnkpb9hnespy445z5_165 ;
 wire [820:0] zkgz7jtmag2458kb6wahty8zz0gs_800 ;
 wire	cutbzc879kclq0hge5k_79 ;
 wire	vhp50roc7i954uwk0db73_858 ;
 wire	uyv0wlf0p1urbxy0qmel6iz91z2er1r_607 ;
 wire [22:0] p1blc1x0b4qemz0w0e6jja2b_729 ;
 wire	vmffwgo4ovd7fpyraq1j9zm_851 ;
 wire [22:0] iknacz1vp3mt9yj7b8l_60 ;
 wire	nd0dxxue0kll3rzn6s0u_875 ;
 wire	j83zh6w0llxlxjruya78erz_407 ;
 wire	z8gf3sfensanbom2cc9_580 ;
 wire	gvt7qwp1d3mu9mddz6winy6tfcrf8_705 ;
 wire	j87gnykeik6ea5upa7_68 ;


 assign zr4j18ir80hecv4elxvexx9stg553l_861 = 
	 ~(backpressure_in) ;
 assign j2tx9d5le0bnu2w66v0c1w2_122 = 
	{packet_in_PACKET3_SOF, packet_in_PACKET3_EOF, packet_in_PACKET3_VAL, packet_in_PACKET3_DAT, packet_in_PACKET3_CNT, packet_in_PACKET3_ERR} ;
 assign hsm9opar1juhgs94qzft242bj7c18_502 	= packet_in_PACKET3_VAL ;
 assign z4wrojdoz0ivpqcp6ekom4exo772m_148 	= j2tx9d5le0bnu2w66v0c1w2_122[71:0] ;
 assign dqp7whw9f1j8xpuvopi9nkwlerm6y_259 = 
	y9cv6ackfqxjqyr1i0tfd8upjywv_257 | gvt7qwp1d3mu9mddz6winy6tfcrf8_705 ;
 assign tqjvu0amin8c7p75gic38pkj4ypq4g_234 = 
	1'b0 ;
 assign sjisw8ztunw0d9lf_717 = 
	1'b1 ;
 assign ys4ojvevne452y1vbuii65xut6qibr_106 = 
	 ~(xdf2rxmuucv800a6igsxcxbo4em59_401) ;
 assign n61jo7vu1r86zfyg39_284 = 
	zr4j18ir80hecv4elxvexx9stg553l_861 & p9v19q9yckzrihxw5dg7fy0e4sv840_516 & dqp7whw9f1j8xpuvopi9nkwlerm6y_259 ;
 assign p845fr2spjczml7bvgknc93ztmsp37zm_661 	= n61jo7vu1r86zfyg39_284 ;
 assign wqdd402b5lrhw2559vo_736 	= p845fr2spjczml7bvgknc93ztmsp37zm_661 ;
 assign q4ozk2h2si20292y2ph2l9ejodb6t9_805 = 
	1'b0 ;
 assign wc6ug6a2ciatk17dv_484 = 
	 ~(q607ajy8ew1wq4k7_221) ;
 assign g7vii692t0uo354ibed0qsdwxk77zr_100 	= uvo51flf76xs3dyfucck9s_372[0] ;
 assign vx6z5t88ix0txxrq_823 	= uvo51flf76xs3dyfucck9s_372[4:1] ;
 assign n2qer9fdb5xvlwqmtpssqbc_210 	= uvo51flf76xs3dyfucck9s_372[68:5] ;
 assign v6pj775lle6asee3b30l3pvwn_201 	= uvo51flf76xs3dyfucck9s_372[69] ;
 assign hs8zdo9kicf4r395g9alr_392 	= uvo51flf76xs3dyfucck9s_372[70] ;
 assign eqgn3xjlq48ovywq7neb441xtcv_653 	= uvo51flf76xs3dyfucck9s_372[71] ;
 assign wsqoje2n1v44tj7pl83xm0jechq4n9a_272 = 
	os5yok43q3k6hjn6og1hvhz7n0fw6oxr_459 & v6pj775lle6asee3b30l3pvwn_201 ;
 assign cj6o9bgzr6ym1b5c92wtx0780r_657 	= packet_in_PACKET3_VAL ;
 assign o9stq274d52n3cadze40ly_879 = packet_in_PACKET3_SOF ;
 assign tfhjri21i20g9o0c8mc1sczoxchyn_317 	= p845fr2spjczml7bvgknc93ztmsp37zm_661 ;
 assign x93d5t7kamuodmn6uzxw7nt38usue_698 = 
	1'b0 ;
 assign i7ws5ucorphfjaebt94rhob8t2yzzbs1_283 	= opyrm0iuvof6k17wumtmhw_525[8:0] ;
 assign amf3hqaxnwgvmu3u_839 = (
	((i7ws5ucorphfjaebt94rhob8t2yzzbs1_283 != p3chx0xihqjqp8l1iuitc7gz9yyx_308))?1'b1:
	0)  ;
 assign i0eams6p90447s4p8o6uqed_73 = ho282ixebe319z1yo75p_413 ;
 assign xku960zn74e7otgr7mcr_68 = ho282ixebe319z1yo75p_413 ;
 assign y9cv6ackfqxjqyr1i0tfd8upjywv_257 = 
	 ~(xku960zn74e7otgr7mcr_68) ;
 assign x5wb324hail89l83gw97ek3elb_130 	= hmi0ifgiecwljfc5ys_355 ;
 assign p9v19q9yckzrihxw5dg7fy0e4sv840_516 = 
	 ~(hmi0ifgiecwljfc5ys_355) ;
 assign znojwl4mo04wrpbawjw3jjcgsk8ar_451 = 
	zr4j18ir80hecv4elxvexx9stg553l_861 & gvt7qwp1d3mu9mddz6winy6tfcrf8_705 & p9v19q9yckzrihxw5dg7fy0e4sv840_516 & i0eams6p90447s4p8o6uqed_73 ;
 assign t2z224021a0nizh7of0eh6ue6alo_51 = 
	tuple_in_TUPLE0_DATA ;
 assign hmmhlxrfoxdzygj9rwa_496 	= tuple_in_TUPLE0_VALID ;
 assign h0ru5zd2s31kcaiuwx1v6z20zxjxqxl_42 	= t2z224021a0nizh7of0eh6ue6alo_51[31:0] ;
 assign xmv17gkrwk3hh549_312 = 
	 ~(sql1xboltmm57uumubsat0ac_522) ;
 assign aig29ttuqtbe1hzs56ro7we05172h91a_346 	= znojwl4mo04wrpbawjw3jjcgsk8ar_451 ;
 assign s0azn6fyfwovlvd7ae5zua_97 = 
	1'b0 ;
 assign kihekt3be27xgpe4t4wx9iz1n8y_632 = 
	tuple_in_TUPLE1_DATA ;
 assign fnkpb9hnespy445z5_165 	= tuple_in_TUPLE1_VALID ;
 assign zkgz7jtmag2458kb6wahty8zz0gs_800 	= kihekt3be27xgpe4t4wx9iz1n8y_632[820:0] ;
 assign cutbzc879kclq0hge5k_79 = 
	 ~(n4nfy15bn6tcpdvbvzp_43) ;
 assign vhp50roc7i954uwk0db73_858 	= znojwl4mo04wrpbawjw3jjcgsk8ar_451 ;
 assign uyv0wlf0p1urbxy0qmel6iz91z2er1r_607 = 
	1'b0 ;
 assign p1blc1x0b4qemz0w0e6jja2b_729 = 
	tuple_in_TUPLE2_DATA ;
 assign vmffwgo4ovd7fpyraq1j9zm_851 	= tuple_in_TUPLE2_VALID ;
 assign iknacz1vp3mt9yj7b8l_60 	= p1blc1x0b4qemz0w0e6jja2b_729[22:0] ;
 assign nd0dxxue0kll3rzn6s0u_875 = 
	 ~(dcuu9f9i2rd63967nab_63) ;
 assign j83zh6w0llxlxjruya78erz_407 	= znojwl4mo04wrpbawjw3jjcgsk8ar_451 ;
 assign z8gf3sfensanbom2cc9_580 = 
	1'b0 ;
 assign gvt7qwp1d3mu9mddz6winy6tfcrf8_705 = 
	wc6ug6a2ciatk17dv_484 & xmv17gkrwk3hh549_312 & cutbzc879kclq0hge5k_79 & nd0dxxue0kll3rzn6s0u_875 ;
 assign j87gnykeik6ea5upa7_68 = 
	a5gztyjomnq89gvxqk4t_147 | vhpypps1lkdbjclih3im32ng2d1tmnfe_500 | l42paenoaml39ch2_769 | jggsg5wi5k4u3zq8sreh2m9py_219 ;
 assign packet_out_PACKET3_SOF 	= eqgn3xjlq48ovywq7neb441xtcv_653 ;
 assign packet_out_PACKET3_EOF 	= hs8zdo9kicf4r395g9alr_392 ;
 assign packet_out_PACKET3_VAL 	= wsqoje2n1v44tj7pl83xm0jechq4n9a_272 ;
 assign packet_out_PACKET3_DAT 	= n2qer9fdb5xvlwqmtpssqbc_210[63:0] ;
 assign packet_out_PACKET3_CNT 	= vx6z5t88ix0txxrq_823[3:0] ;
 assign packet_out_PACKET3_ERR 	= g7vii692t0uo354ibed0qsdwxk77zr_100 ;
 assign packet_in_PACKET3_RDY 	= packet_out_PACKET3_RDY ;
 assign tuple_out_TUPLE0_VALID 	= acicg10p71zyff6jz9nvhs8ip7f0bt_771 ;
 assign tuple_out_TUPLE0_DATA 	= lxyawkij87pwo8k0a98c1tieyo_350[31:0] ;
 assign tuple_out_TUPLE1_VALID 	= acicg10p71zyff6jz9nvhs8ip7f0bt_771 ;
 assign tuple_out_TUPLE1_DATA 	= wdxih2b0hphy6gnzarzzqe42yr5nf_320[820:0] ;
 assign tuple_out_TUPLE2_VALID 	= acicg10p71zyff6jz9nvhs8ip7f0bt_771 ;
 assign tuple_out_TUPLE2_DATA 	= dvafc2357i94ei0orwgiwd1m_711[22:0] ;


assign mjy6aqzwiah8zw874zp_860 = (
	((p845fr2spjczml7bvgknc93ztmsp37zm_661 == 1'b1))?sjisw8ztunw0d9lf_717 :
	((zr4j18ir80hecv4elxvexx9stg553l_861 == 1'b1))?tqjvu0amin8c7p75gic38pkj4ypq4g_234 :
	qgtcm2l4pnyhk5dmkz7s7kjwmbbbmut_875 ) ;

assign xdf2rxmuucv800a6igsxcxbo4em59_401 = (
	((qgtcm2l4pnyhk5dmkz7s7kjwmbbbmut_875 == 1'b1) && (zr4j18ir80hecv4elxvexx9stg553l_861 == 1'b1))?tqjvu0amin8c7p75gic38pkj4ypq4g_234 :
	qgtcm2l4pnyhk5dmkz7s7kjwmbbbmut_875 ) ;



always @(posedge clk_out_0)
begin
  if (rst_in_0) 
  begin
	tiaj1nbi55zrf6ukdy7dvdwqel_840 <= 1'b0 ;
	qgtcm2l4pnyhk5dmkz7s7kjwmbbbmut_875 <= 1'b0 ;
	hfvtelwjhislprxxp5hylgjx9xtlwn6_821 <= 1'b0 ;
	os5yok43q3k6hjn6og1hvhz7n0fw6oxr_459 <= 1'b0 ;
	p3chx0xihqjqp8l1iuitc7gz9yyx_308 <= 9'b000000000 ;
	a5gztyjomnq89gvxqk4t_147 <= 1'b0 ;
	backpressure_out <= 1'b0 ;
   end
  else
  begin
		tiaj1nbi55zrf6ukdy7dvdwqel_840 <= backpressure_in ;
		qgtcm2l4pnyhk5dmkz7s7kjwmbbbmut_875 <= mjy6aqzwiah8zw874zp_860 ;
		hfvtelwjhislprxxp5hylgjx9xtlwn6_821 <= wc6ug6a2ciatk17dv_484 ;
		os5yok43q3k6hjn6og1hvhz7n0fw6oxr_459 <= p845fr2spjczml7bvgknc93ztmsp37zm_661 ;
		p3chx0xihqjqp8l1iuitc7gz9yyx_308 <= i7ws5ucorphfjaebt94rhob8t2yzzbs1_283 ;
		a5gztyjomnq89gvxqk4t_147 <= dzvh4vxfdwcqs6wu4shck0xfh0_753 ;
		backpressure_out <= j87gnykeik6ea5upa7_68 ;
  end
end

always @(posedge clk_out_1)
begin
  if (rst_in_0) 
  begin
	acicg10p71zyff6jz9nvhs8ip7f0bt_771 <= 1'b0 ;
	vhpypps1lkdbjclih3im32ng2d1tmnfe_500 <= 1'b0 ;
   end
  else
  begin
		acicg10p71zyff6jz9nvhs8ip7f0bt_771 <= znojwl4mo04wrpbawjw3jjcgsk8ar_451 ;
		vhpypps1lkdbjclih3im32ng2d1tmnfe_500 <= ypv937hitisvvhb95f7t5lv_794 ;
  end
end

always @(posedge clk_out_2)
begin
  if (rst_in_0) 
  begin
	l42paenoaml39ch2_769 <= 1'b0 ;
   end
  else
  begin
		l42paenoaml39ch2_769 <= dpvrezok4qqhwavq7y_767 ;
  end
end

always @(posedge clk_out_3)
begin
  if (rst_in_0) 
  begin
	jggsg5wi5k4u3zq8sreh2m9py_219 <= 1'b0 ;
   end
  else
  begin
		jggsg5wi5k4u3zq8sreh2m9py_219 <= bnluooedrxcqjye4voh_766 ;
  end
end

defparam l61esl7k4rhoiyvov_982.WRITE_DATA_WIDTH = 72; 
defparam l61esl7k4rhoiyvov_982.FIFO_WRITE_DEPTH = 512; 
defparam l61esl7k4rhoiyvov_982.PROG_FULL_THRESH = 320; 
defparam l61esl7k4rhoiyvov_982.PROG_EMPTY_THRESH = 320; 
defparam l61esl7k4rhoiyvov_982.READ_MODE = "STD"; 
defparam l61esl7k4rhoiyvov_982.WR_DATA_COUNT_WIDTH = 9; 
defparam l61esl7k4rhoiyvov_982.RD_DATA_COUNT_WIDTH = 9; 
defparam l61esl7k4rhoiyvov_982.DOUT_RESET_VALUE = "0"; 
defparam l61esl7k4rhoiyvov_982.FIFO_MEMORY_TYPE = "bram"; 

xpm_fifo_sync l61esl7k4rhoiyvov_982 (
	.wr_en(hsm9opar1juhgs94qzft242bj7c18_502),
	.din(z4wrojdoz0ivpqcp6ekom4exo772m_148),
	.rd_en(wqdd402b5lrhw2559vo_736),
	.sleep(q4ozk2h2si20292y2ph2l9ejodb6t9_805),
	.injectsbiterr(),
	.injectdbiterr(),


	.prog_empty(rvc5cgvbqggz3k5i_606), 
	.dout(uvo51flf76xs3dyfucck9s_372), 
	.empty(q607ajy8ew1wq4k7_221), 
	.prog_full(dzvh4vxfdwcqs6wu4shck0xfh0_753), 
	.full(wu9zev365f40nbnmrhwft1ja9u1m3e_335), 
	.rd_data_count(gvd2udahb66ng9sy5_169), 
	.wr_data_count(z80cpo6h9kwjq6oo_129), 
	.wr_rst_busy(xl6o26k7prd6llmqtmz_831), 
	.rd_rst_busy(a6ug8o8pa8lqjeb4sbf1_17), 
	.overflow(uukfyb0v910s0abagwjk_672), 
	.underflow(csudlty0i9ish78w3luj6kwbpv9c_619), 
	.sbiterr(htam5lbwqnf2n24061g9jio8reqk6z_247), 
	.dbiterr(f5gb6fapizsazwo3kj_35), 

	.wr_clk(clk_in_0), 
	.rst(rst_in_0) 
); 

defparam xolqsgi4jps1syvq1zrovmbtep_526.WRITE_DATA_WIDTH = 1; 
defparam xolqsgi4jps1syvq1zrovmbtep_526.FIFO_WRITE_DEPTH = 512; 
defparam xolqsgi4jps1syvq1zrovmbtep_526.PROG_FULL_THRESH = 320; 
defparam xolqsgi4jps1syvq1zrovmbtep_526.PROG_EMPTY_THRESH = 320; 
defparam xolqsgi4jps1syvq1zrovmbtep_526.READ_MODE = "FWFT"; 
defparam xolqsgi4jps1syvq1zrovmbtep_526.WR_DATA_COUNT_WIDTH = 9; 
defparam xolqsgi4jps1syvq1zrovmbtep_526.RD_DATA_COUNT_WIDTH = 9; 
defparam xolqsgi4jps1syvq1zrovmbtep_526.DOUT_RESET_VALUE = "0"; 
defparam xolqsgi4jps1syvq1zrovmbtep_526.FIFO_MEMORY_TYPE = "lutram"; 

xpm_fifo_sync xolqsgi4jps1syvq1zrovmbtep_526 (
	.wr_en(cj6o9bgzr6ym1b5c92wtx0780r_657),
	.din(o9stq274d52n3cadze40ly_879),
	.rd_en(tfhjri21i20g9o0c8mc1sczoxchyn_317),
	.sleep(x93d5t7kamuodmn6uzxw7nt38usue_698),
	.injectsbiterr(),
	.injectdbiterr(),


	.prog_empty(v30vu8bia6qj3f8vum9kvbnb_58), 
	.dout(ho282ixebe319z1yo75p_413), 
	.empty(hmi0ifgiecwljfc5ys_355), 
	.prog_full(wis9tv24iixmvrr5w_502), 
	.full(eemw0236ts2u3qizfog_559), 
	.rd_data_count(opyrm0iuvof6k17wumtmhw_525), 
	.wr_data_count(aw9vvo9veecgwzr22qe2v9pp_72), 
	.wr_rst_busy(gby130pt3pno1oto834st_330), 
	.rd_rst_busy(jtgo59ccpvgud881f8iw_421), 
	.overflow(fypfivhqfs1wi926xa7krsf_819), 
	.underflow(mex051rcu7h8b4uyl6p9xj6hnud_582), 
	.sbiterr(rmkzowkryfadh8eq7f53h_672), 
	.dbiterr(a8rcy1q8xbsm54rma37xp5jcdag722_361), 

	.wr_clk(clk_in_0), 
	.rst(rst_in_0) 
); 

defparam f0bbchof5srb9qrfko_2492.WRITE_DATA_WIDTH = 32; 
defparam f0bbchof5srb9qrfko_2492.FIFO_WRITE_DEPTH = 256; 
defparam f0bbchof5srb9qrfko_2492.PROG_FULL_THRESH = 65; 
defparam f0bbchof5srb9qrfko_2492.PROG_EMPTY_THRESH = 65; 
defparam f0bbchof5srb9qrfko_2492.READ_MODE = "STD"; 
defparam f0bbchof5srb9qrfko_2492.WR_DATA_COUNT_WIDTH = 8; 
defparam f0bbchof5srb9qrfko_2492.RD_DATA_COUNT_WIDTH = 8; 
defparam f0bbchof5srb9qrfko_2492.DOUT_RESET_VALUE = "0"; 
defparam f0bbchof5srb9qrfko_2492.FIFO_MEMORY_TYPE = "lutram"; 

xpm_fifo_async f0bbchof5srb9qrfko_2492 (
	.wr_en(hmmhlxrfoxdzygj9rwa_496),
	.din(h0ru5zd2s31kcaiuwx1v6z20zxjxqxl_42),
	.rd_en(aig29ttuqtbe1hzs56ro7we05172h91a_346),
	.sleep(s0azn6fyfwovlvd7ae5zua_97),
	.injectsbiterr(),
	.injectdbiterr(),


	.prog_empty(o4z11fd0r6iu4ulvearqmwnwd4tyif_324), 
	.dout(lxyawkij87pwo8k0a98c1tieyo_350), 
	.empty(sql1xboltmm57uumubsat0ac_522), 
	.prog_full(ypv937hitisvvhb95f7t5lv_794), 
	.full(puoqlctrxopxhh0d1dbg9345_262), 
	.rd_data_count(eh7fmcoznej6i0oldtehqcy_756), 
	.wr_data_count(bpn85ua9bqgp82x0hrd7vp_418), 
	.wr_rst_busy(t9ehnj9bufvhiy6kidhfo7whjr6xlb38_423), 
	.rd_rst_busy(p5nbtc32pfrxlz0ds0c6_760), 
	.overflow(t35078bum6o3m0j2fdpdnyzctz_527), 
	.underflow(ne2x9lfn17939fcr2fe3ctxp2bj_645), 
	.sbiterr(nyypzuz6onz2p47tr9zhumaglerwvig9_562), 
	.dbiterr(mq59ludylji7ta8ew_504), 

	.wr_clk(clk_in_1), 

	.rd_clk(clk_out_1), 
	.rst(rst_in_1) 
); 

defparam wc2g28o12vc15l72acr_466.WRITE_DATA_WIDTH = 821; 
defparam wc2g28o12vc15l72acr_466.FIFO_WRITE_DEPTH = 256; 
defparam wc2g28o12vc15l72acr_466.PROG_FULL_THRESH = 65; 
defparam wc2g28o12vc15l72acr_466.PROG_EMPTY_THRESH = 65; 
defparam wc2g28o12vc15l72acr_466.READ_MODE = "STD"; 
defparam wc2g28o12vc15l72acr_466.WR_DATA_COUNT_WIDTH = 8; 
defparam wc2g28o12vc15l72acr_466.RD_DATA_COUNT_WIDTH = 8; 
defparam wc2g28o12vc15l72acr_466.DOUT_RESET_VALUE = "0"; 
defparam wc2g28o12vc15l72acr_466.FIFO_MEMORY_TYPE = "bram"; 

xpm_fifo_async wc2g28o12vc15l72acr_466 (
	.wr_en(fnkpb9hnespy445z5_165),
	.din(zkgz7jtmag2458kb6wahty8zz0gs_800),
	.rd_en(vhp50roc7i954uwk0db73_858),
	.sleep(uyv0wlf0p1urbxy0qmel6iz91z2er1r_607),
	.injectsbiterr(),
	.injectdbiterr(),


	.prog_empty(velb18exlxogvq41lzszrzkrn_525), 
	.dout(wdxih2b0hphy6gnzarzzqe42yr5nf_320), 
	.empty(n4nfy15bn6tcpdvbvzp_43), 
	.prog_full(dpvrezok4qqhwavq7y_767), 
	.full(yssm788n871yema8izlvhindqze91_529), 
	.rd_data_count(qdm24vwe63p0kzj09ss2q_728), 
	.wr_data_count(un0ditzgx8i8h6bljoatj01_468), 
	.wr_rst_busy(qfzjwy2i803h0d42d0zff6s0sdtc7ltm_698), 
	.rd_rst_busy(uirg1rqxb6r8800l3edcy59q15uo1oj_800), 
	.overflow(ukffi34g8887akqhtnal1lk4ml_78), 
	.underflow(d7rxpw8gko8q0mtkn5w0o0rn_132), 
	.sbiterr(fauxif1v12ht31c5m8d11_165), 
	.dbiterr(j0in8an4bg857wp6z5mp6uqxvcgwmgk5_219), 

	.wr_clk(clk_in_2), 

	.rd_clk(clk_out_2), 
	.rst(rst_in_2) 
); 

defparam jprhpgwvpbrci2aqedh0a9chpdkf_47.WRITE_DATA_WIDTH = 23; 
defparam jprhpgwvpbrci2aqedh0a9chpdkf_47.FIFO_WRITE_DEPTH = 256; 
defparam jprhpgwvpbrci2aqedh0a9chpdkf_47.PROG_FULL_THRESH = 65; 
defparam jprhpgwvpbrci2aqedh0a9chpdkf_47.PROG_EMPTY_THRESH = 65; 
defparam jprhpgwvpbrci2aqedh0a9chpdkf_47.READ_MODE = "STD"; 
defparam jprhpgwvpbrci2aqedh0a9chpdkf_47.WR_DATA_COUNT_WIDTH = 8; 
defparam jprhpgwvpbrci2aqedh0a9chpdkf_47.RD_DATA_COUNT_WIDTH = 8; 
defparam jprhpgwvpbrci2aqedh0a9chpdkf_47.DOUT_RESET_VALUE = "0"; 
defparam jprhpgwvpbrci2aqedh0a9chpdkf_47.FIFO_MEMORY_TYPE = "lutram"; 

xpm_fifo_async jprhpgwvpbrci2aqedh0a9chpdkf_47 (
	.wr_en(vmffwgo4ovd7fpyraq1j9zm_851),
	.din(iknacz1vp3mt9yj7b8l_60),
	.rd_en(j83zh6w0llxlxjruya78erz_407),
	.sleep(z8gf3sfensanbom2cc9_580),
	.injectsbiterr(),
	.injectdbiterr(),


	.prog_empty(fcxjhqpz4zm3nutqwwd_461), 
	.dout(dvafc2357i94ei0orwgiwd1m_711), 
	.empty(dcuu9f9i2rd63967nab_63), 
	.prog_full(bnluooedrxcqjye4voh_766), 
	.full(jdr75udrueiksa52wla33m_705), 
	.rd_data_count(nq7mdk317yabgx036_319), 
	.wr_data_count(lg10r4m4lzhgkwyhqra_250), 
	.wr_rst_busy(ox8wbi7so6x523uwjoq7zib2gv_811), 
	.rd_rst_busy(aivbygnrl1jrd9in_413), 
	.overflow(swktat7jg7cdaev5gmr_300), 
	.underflow(ngi1q1i2hv07bp6jr3zrzhv_498), 
	.sbiterr(w7puuqw8pn3b3oa2ctnls4xw8z06505_180), 
	.dbiterr(oby8hynb4egmtcbr0j_27), 

	.wr_clk(clk_in_3), 

	.rd_clk(clk_out_3), 
	.rst(rst_in_3) 
); 

endmodule 
