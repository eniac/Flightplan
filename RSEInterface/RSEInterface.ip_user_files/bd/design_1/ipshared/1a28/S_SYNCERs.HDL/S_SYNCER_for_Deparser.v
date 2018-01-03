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
// File name: S_SYNCER_for_Deparser.v
// File created: 2017/10/23 14:31:57
// Created by: Xilinx SDNet Compiler version 2017.2.1, build 1997167

//----------------------------------------------------------------------------

`timescale 1 ns / 100 ps

module S_SYNCER_for_Deparser (
     packet_in_PACKET2_SOF, 
     packet_in_PACKET2_EOF, 
     packet_in_PACKET2_VAL, 
     packet_in_PACKET2_DAT, 
     packet_in_PACKET2_CNT, 
     packet_in_PACKET2_ERR, 
     packet_out_PACKET2_RDY, 
     tuple_in_TUPLE0_VALID, 
     tuple_in_TUPLE0_DATA, 
     tuple_in_TUPLE1_VALID, 
     tuple_in_TUPLE1_DATA, 
     backpressure_in, 


     packet_out_PACKET2_SOF, 
     packet_out_PACKET2_EOF, 
     packet_out_PACKET2_VAL, 
     packet_out_PACKET2_DAT, 
     packet_out_PACKET2_CNT, 
     packet_out_PACKET2_ERR, 
     packet_in_PACKET2_RDY, 
     tuple_out_TUPLE0_VALID, 
     tuple_out_TUPLE0_DATA, 
     tuple_out_TUPLE1_VALID, 
     tuple_out_TUPLE1_DATA, 
     backpressure_out, 

     clk_in_0, 
     clk_out_0, 
     clk_in_1, 
     clk_out_1, 
     clk_in_2, 
     clk_out_2, 
     rst_in_0, 
     rst_out_0, 
     rst_in_1, 
     rst_out_1, 
     rst_in_2, 
     rst_out_2 

);

//-------------------------------------------------------------
// I/O
//-------------------------------------------------------------
 input		packet_in_PACKET2_SOF ;
 input		packet_in_PACKET2_EOF ;
 input		packet_in_PACKET2_VAL ;
 input	 [63:0] packet_in_PACKET2_DAT ;
 input	 [3:0] packet_in_PACKET2_CNT ;
 input		packet_in_PACKET2_ERR ;
 input		packet_out_PACKET2_RDY ;
 input		tuple_in_TUPLE0_VALID ;
 input	 [820:0] tuple_in_TUPLE0_DATA ;
 input		tuple_in_TUPLE1_VALID ;
 input	 [22:0] tuple_in_TUPLE1_DATA ;
 input		backpressure_in ;
 output		packet_out_PACKET2_SOF ;
 output		packet_out_PACKET2_EOF ;
 output		packet_out_PACKET2_VAL ;
 output	 [63:0] packet_out_PACKET2_DAT ;
 output	 [3:0] packet_out_PACKET2_CNT ;
 output		packet_out_PACKET2_ERR ;
 output		packet_in_PACKET2_RDY ;
 output		tuple_out_TUPLE0_VALID ;
 output	 [820:0] tuple_out_TUPLE0_DATA ;
 output		tuple_out_TUPLE1_VALID ;
 output	 [22:0] tuple_out_TUPLE1_DATA ;
 output	reg	backpressure_out ;
 input		clk_in_0 ;
 input		clk_out_0 ;
 input		clk_in_1 ;
 input		clk_out_1 ;
 input		clk_in_2 ;
 input		clk_out_2 ;
 input		rst_in_0 ;
 input		rst_out_0 ;
 input		rst_in_1 ;
 input		rst_out_1 ;
 input		rst_in_2 ;
 input		rst_out_2 ;






 reg	ciw0xljpqwjibmkfc3y49qfs_198;	 initial ciw0xljpqwjibmkfc3y49qfs_198 = 1'b0 ;
 wire	tcr92l5dk6z1yqsx0tfk_47 ;
 wire [71:0] ysaacn866ep7c0oy7gs5cy9b_227 ;
 wire	r1uxaeafoazl2bkljiy_133 ;
 wire	rixfgl9t1auzjoevq9jnfkh_475 ;
 wire	c3olrvm5alz9ns5l6hdhpa3kmpm7lpz_823 ;
 wire [8:0] qapomvzucblud5p61_639 ;
 wire [8:0] nh206goqwcpso3k3u7dt02su_797 ;
 wire	b5lvzlhljx8b926p8lsn080b2x78_481 ;
 wire	c1w249engdfdm9ocmtk_779 ;
 wire	n82khb1nyoafi64g739u9sls4u_568 ;
 wire	qc7qyb5gdflszr5yrzwr4ptfj26e8yu7_216 ;
 wire	d02ildvhwke7jygvrmexxzgw_841 ;
 wire	amryg6xj2xokr320k1tkse0bm7_462 ;
 wire	mb6f10f57nj69sjxxyoy_401 ;
 reg	moinaxudsfdxjk6qeqbq6z_604;	 initial moinaxudsfdxjk6qeqbq6z_604 = 1'b0 ;
 wire	xnnfeb80xo9y7p40y4l6uzisef_642 ;
 reg	ahwef50eble2xrg0i2q20s_488;	 initial ahwef50eble2xrg0i2q20s_488 = 1'b0 ;
 reg	wgvmqdmfxmxuiismfijb9boscu7hl_248;	 initial wgvmqdmfxmxuiismfijb9boscu7hl_248 = 1'b0 ;
 wire	h2xevrid09zfqtr6qspm_190 ;
 wire [0:0] edvut540wdb8mevl6mg1i620f7hpt46_277 ;
 wire	dyaykuyjdo5wdz9r627innzvwv49e9k_758 ;
 wire	ku970nh0ttuyc6okgkic_856 ;
 wire	ubn90glmf5eafyvyf_599 ;
 wire [8:0] feqtq9cglcwzyqbweo_801 ;
 wire [8:0] s2qb8r1jbub1zz2cav88m833r_21 ;
 wire	b72on1ifqvj4k2e4ic6mfduswnq6y_326 ;
 wire	av1litph7nmx8ivwf42no0nn312vw7lc_374 ;
 wire	gh7m7h9d7ou9490n1k6ld7jlaq8y1e_868 ;
 wire	a89w1f7d9qqr5gemfmbesbb2_873 ;
 wire	yn35tcn56zg1ksy6krxo_825 ;
 wire	ew4f2jqu20k5gn2fqpie450zqi4kn07g_639 ;
 reg [8:0] rc30gpr48a1fecaj_514;	 initial rc30gpr48a1fecaj_514 = 9'b000000000 ;
 reg	e0s2xnynj489e9prz_613;	 initial e0s2xnynj489e9prz_613 = 1'b0 ;
 wire	qkeag4fz9lv8c0fx6fp_627 ;
 wire [820:0] ex64ine9nv0bqx4lo5qm_862 ;
 wire	fog3x92f0hvxf4rjgghg_323 ;
 wire	kasezejqafin7zu4s_322 ;
 wire	yc2nfqihyqcpsm3lcsahtl_544 ;
 wire [7:0] w5c3kh91tu08ow8b6jq_699 ;
 wire [7:0] n8rb5325q7z2kpmzb8zzbx9agejnhl9_605 ;
 wire	pxxc9a8p5rj8zzkvfxs8e4jj7xq_665 ;
 wire	e1k15icmgu6zsfy0_375 ;
 wire	r8whgf9iroqqcx2e4d_142 ;
 wire	pqpq5zypuo76vjw3e1r1fm_830 ;
 wire	k963vnniygq2mrvuq50apaxj9t1_771 ;
 wire	da3emy0k50cqmrv7_132 ;
 wire	otk5cwc7c15i4ow337j2exn7_609 ;
 wire [22:0] m3il95eefjpisb4mxxes_601 ;
 wire	vpee2mw2jo0rks6dj2boyu1in49bj_210 ;
 wire	vkilw659p3mqlj2d28jfjku6v67p_421 ;
 wire	lsomfwx3skesgmoksyou1f2f_143 ;
 wire [7:0] kpa2cvnm0lv7tu2zucuppwhe1w8rblp_2 ;
 wire [7:0] hm5mikfzpyda5d47vganqh24qaz8_644 ;
 wire	ef5cj9qiz780a1zdzftd_596 ;
 wire	yhc45ho0fxc29a3wqsxzbvf2653owms_182 ;
 wire	g73c6lmsak5s8tosn9tkylcx_473 ;
 wire	arequli3tcn96jb17_282 ;
 wire	cjgb3fkvpnypefp35o4dj1_669 ;
 wire	r9yirdawvvt5qt8h37gstd8h2nbnl4_259 ;
 reg	xn5thqk9a056ca1d7ceq1p6_223;	 initial xn5thqk9a056ca1d7ceq1p6_223 = 1'b0 ;
 reg	j4hlo821enpvjzgavkib9e3y5y_749;	 initial j4hlo821enpvjzgavkib9e3y5y_749 = 1'b0 ;
 reg	xt83kkeq0r15lyirhsto_805;	 initial xt83kkeq0r15lyirhsto_805 = 1'b0 ;
 wire	i9boj1glaa81vdpd832akul4_480 ;
 wire [71:0] mr9f5ed55q1fc0t8u89chh_711 ;
 wire	ksyt5yqt1gmx8xce2apy8k90bhwooyra_839 ;
 wire [71:0] xoj2tleywlceqwassmip_131 ;
 wire	zf0uym12ovxgs06x0kvo381erxc_108 ;
 wire	zpi1ypm4sp1enhge7khpfiy7j3e_382 ;
 wire	n5anbih7vz1vy6xso4unru_61 ;
 wire	vuydadm2wn3euveta19jtj9qp6oeh_566 ;
 wire	c9hhv73o44j0489wz6_476 ;
 wire	u788cu39qihe5botpsk4tndc4_392 ;
 wire	hrjt38zqu55ccifxavyhbz4ni_481 ;
 wire	n3vk8rqyoibor602_831 ;
 wire	z8xsehjsqlr0x3mubng0dfh9hu4_37 ;
 wire	hp41upusp04xqwg1k2ub0f94s5bly_32 ;
 wire [3:0] h9fhaeiyhuliaq661_523 ;
 wire [63:0] pd1ytifjm6snashgf19c9ii29_653 ;
 wire	sas5aqyp4sjzvmdmx18qxh_187 ;
 wire	djgiiime4rsbtoadrvk2_771 ;
 wire	w8jfu8uj2uqnpe2ndnipzwln125vx_646 ;
 wire	ej8ea3hepu4njyozb5d5xw6l9zgkv_803 ;
 wire	s7pcsc8mqxi5idxia4xlsfzuwrxx_188 ;
 wire [0:0] u1s9fbb70e7cg8t29gpd4zzb7k_266 ;
 wire	q1fskm2p0a77jv0i7_277 ;
 wire	ecyp1i2a76nrzusbolh3uu5n4rv_113 ;
 wire [8:0] fm4hyjmr6vfbqx51604mrcjjzm00_902 ;
 wire	lhbglhvhn21vt7uxjqt7wym3fif3u_21 ;
 wire	xvs1cjjbm10e7bh157ku59_881 ;
 wire	whaz05jn5hxx2zw2c_185 ;
 wire	p6sh9sn9ilvv9t4yihaadzbb_507 ;
 wire	bzxmfdht72q3ysiqata81_440 ;
 wire	o2pgftdgi9ash63wov_298 ;
 wire	xgo76w63serbtp9kqkvrey0zlu5izp8_547 ;
 wire [820:0] bp6q7cuq5o90invyqhtt_483 ;
 wire	tdk1dk8p835po3c1oc9thyz3z_473 ;
 wire [820:0] lf5ae3tcserkrmkmouyidctzdar8x_433 ;
 wire	zsr7yo3auum8bsd3yz3hryg92b4dn6g_213 ;
 wire	sys5umfsiko4xnjza_611 ;
 wire	d78t6l9tzt95q8tldotnn8putaz66k6_454 ;
 wire [22:0] edtcf5n1plka0u60rixvow29w3_24 ;
 wire	v89lbqwhp6v8cxopqsc8_410 ;
 wire [22:0] ykdq9ujw7us0epnqqbmdeuv2edyp_891 ;
 wire	lau6nuuz8dyx1xkjrbjbb10zt_540 ;
 wire	zjeu7wu9h876o04ij_50 ;
 wire	fedbx2vd29dyecdnbxq6gnxaepdpl_306 ;
 wire	uy1meim4dbpliqsw_671 ;
 wire	x91w7wlo0yzhgedxc5mffspnft8t03t_140 ;


 assign i9boj1glaa81vdpd832akul4_480 = 
	 ~(backpressure_in) ;
 assign mr9f5ed55q1fc0t8u89chh_711 = 
	{packet_in_PACKET2_SOF, packet_in_PACKET2_EOF, packet_in_PACKET2_VAL, packet_in_PACKET2_DAT, packet_in_PACKET2_CNT, packet_in_PACKET2_ERR} ;
 assign ksyt5yqt1gmx8xce2apy8k90bhwooyra_839 	= packet_in_PACKET2_VAL ;
 assign xoj2tleywlceqwassmip_131 	= mr9f5ed55q1fc0t8u89chh_711[71:0] ;
 assign zf0uym12ovxgs06x0kvo381erxc_108 = 
	p6sh9sn9ilvv9t4yihaadzbb_507 | uy1meim4dbpliqsw_671 ;
 assign zpi1ypm4sp1enhge7khpfiy7j3e_382 = 
	1'b0 ;
 assign n5anbih7vz1vy6xso4unru_61 = 
	1'b1 ;
 assign vuydadm2wn3euveta19jtj9qp6oeh_566 = 
	 ~(xnnfeb80xo9y7p40y4l6uzisef_642) ;
 assign c9hhv73o44j0489wz6_476 = 
	i9boj1glaa81vdpd832akul4_480 & o2pgftdgi9ash63wov_298 & zf0uym12ovxgs06x0kvo381erxc_108 ;
 assign u788cu39qihe5botpsk4tndc4_392 	= c9hhv73o44j0489wz6_476 ;
 assign hrjt38zqu55ccifxavyhbz4ni_481 	= u788cu39qihe5botpsk4tndc4_392 ;
 assign n3vk8rqyoibor602_831 = 
	1'b0 ;
 assign z8xsehjsqlr0x3mubng0dfh9hu4_37 = 
	 ~(r1uxaeafoazl2bkljiy_133) ;
 assign hp41upusp04xqwg1k2ub0f94s5bly_32 	= ysaacn866ep7c0oy7gs5cy9b_227[0] ;
 assign h9fhaeiyhuliaq661_523 	= ysaacn866ep7c0oy7gs5cy9b_227[4:1] ;
 assign pd1ytifjm6snashgf19c9ii29_653 	= ysaacn866ep7c0oy7gs5cy9b_227[68:5] ;
 assign sas5aqyp4sjzvmdmx18qxh_187 	= ysaacn866ep7c0oy7gs5cy9b_227[69] ;
 assign djgiiime4rsbtoadrvk2_771 	= ysaacn866ep7c0oy7gs5cy9b_227[70] ;
 assign w8jfu8uj2uqnpe2ndnipzwln125vx_646 	= ysaacn866ep7c0oy7gs5cy9b_227[71] ;
 assign ej8ea3hepu4njyozb5d5xw6l9zgkv_803 = 
	wgvmqdmfxmxuiismfijb9boscu7hl_248 & sas5aqyp4sjzvmdmx18qxh_187 ;
 assign s7pcsc8mqxi5idxia4xlsfzuwrxx_188 	= packet_in_PACKET2_VAL ;
 assign u1s9fbb70e7cg8t29gpd4zzb7k_266 = packet_in_PACKET2_SOF ;
 assign q1fskm2p0a77jv0i7_277 	= u788cu39qihe5botpsk4tndc4_392 ;
 assign ecyp1i2a76nrzusbolh3uu5n4rv_113 = 
	1'b0 ;
 assign fm4hyjmr6vfbqx51604mrcjjzm00_902 	= feqtq9cglcwzyqbweo_801[8:0] ;
 assign lhbglhvhn21vt7uxjqt7wym3fif3u_21 = (
	((fm4hyjmr6vfbqx51604mrcjjzm00_902 != rc30gpr48a1fecaj_514))?1'b1:
	0)  ;
 assign xvs1cjjbm10e7bh157ku59_881 = edvut540wdb8mevl6mg1i620f7hpt46_277 ;
 assign whaz05jn5hxx2zw2c_185 = edvut540wdb8mevl6mg1i620f7hpt46_277 ;
 assign p6sh9sn9ilvv9t4yihaadzbb_507 = 
	 ~(whaz05jn5hxx2zw2c_185) ;
 assign bzxmfdht72q3ysiqata81_440 	= dyaykuyjdo5wdz9r627innzvwv49e9k_758 ;
 assign o2pgftdgi9ash63wov_298 = 
	 ~(dyaykuyjdo5wdz9r627innzvwv49e9k_758) ;
 assign xgo76w63serbtp9kqkvrey0zlu5izp8_547 = 
	i9boj1glaa81vdpd832akul4_480 & uy1meim4dbpliqsw_671 & o2pgftdgi9ash63wov_298 & xvs1cjjbm10e7bh157ku59_881 ;
 assign bp6q7cuq5o90invyqhtt_483 = 
	tuple_in_TUPLE0_DATA ;
 assign tdk1dk8p835po3c1oc9thyz3z_473 	= tuple_in_TUPLE0_VALID ;
 assign lf5ae3tcserkrmkmouyidctzdar8x_433 	= bp6q7cuq5o90invyqhtt_483[820:0] ;
 assign zsr7yo3auum8bsd3yz3hryg92b4dn6g_213 = 
	 ~(fog3x92f0hvxf4rjgghg_323) ;
 assign sys5umfsiko4xnjza_611 	= xgo76w63serbtp9kqkvrey0zlu5izp8_547 ;
 assign d78t6l9tzt95q8tldotnn8putaz66k6_454 = 
	1'b0 ;
 assign edtcf5n1plka0u60rixvow29w3_24 = 
	tuple_in_TUPLE1_DATA ;
 assign v89lbqwhp6v8cxopqsc8_410 	= tuple_in_TUPLE1_VALID ;
 assign ykdq9ujw7us0epnqqbmdeuv2edyp_891 	= edtcf5n1plka0u60rixvow29w3_24[22:0] ;
 assign lau6nuuz8dyx1xkjrbjbb10zt_540 = 
	 ~(vpee2mw2jo0rks6dj2boyu1in49bj_210) ;
 assign zjeu7wu9h876o04ij_50 	= xgo76w63serbtp9kqkvrey0zlu5izp8_547 ;
 assign fedbx2vd29dyecdnbxq6gnxaepdpl_306 = 
	1'b0 ;
 assign uy1meim4dbpliqsw_671 = 
	z8xsehjsqlr0x3mubng0dfh9hu4_37 & zsr7yo3auum8bsd3yz3hryg92b4dn6g_213 & lau6nuuz8dyx1xkjrbjbb10zt_540 ;
 assign x91w7wlo0yzhgedxc5mffspnft8t03t_140 = 
	xn5thqk9a056ca1d7ceq1p6_223 | j4hlo821enpvjzgavkib9e3y5y_749 | xt83kkeq0r15lyirhsto_805 ;
 assign packet_out_PACKET2_SOF 	= w8jfu8uj2uqnpe2ndnipzwln125vx_646 ;
 assign packet_out_PACKET2_EOF 	= djgiiime4rsbtoadrvk2_771 ;
 assign packet_out_PACKET2_VAL 	= ej8ea3hepu4njyozb5d5xw6l9zgkv_803 ;
 assign packet_out_PACKET2_DAT 	= pd1ytifjm6snashgf19c9ii29_653[63:0] ;
 assign packet_out_PACKET2_CNT 	= h9fhaeiyhuliaq661_523[3:0] ;
 assign packet_out_PACKET2_ERR 	= hp41upusp04xqwg1k2ub0f94s5bly_32 ;
 assign packet_in_PACKET2_RDY 	= packet_out_PACKET2_RDY ;
 assign tuple_out_TUPLE0_VALID 	= e0s2xnynj489e9prz_613 ;
 assign tuple_out_TUPLE0_DATA 	= ex64ine9nv0bqx4lo5qm_862[820:0] ;
 assign tuple_out_TUPLE1_VALID 	= e0s2xnynj489e9prz_613 ;
 assign tuple_out_TUPLE1_DATA 	= m3il95eefjpisb4mxxes_601[22:0] ;


assign mb6f10f57nj69sjxxyoy_401 = (
	((u788cu39qihe5botpsk4tndc4_392 == 1'b1))?n5anbih7vz1vy6xso4unru_61 :
	((i9boj1glaa81vdpd832akul4_480 == 1'b1))?zpi1ypm4sp1enhge7khpfiy7j3e_382 :
	moinaxudsfdxjk6qeqbq6z_604 ) ;

assign xnnfeb80xo9y7p40y4l6uzisef_642 = (
	((moinaxudsfdxjk6qeqbq6z_604 == 1'b1) && (i9boj1glaa81vdpd832akul4_480 == 1'b1))?zpi1ypm4sp1enhge7khpfiy7j3e_382 :
	moinaxudsfdxjk6qeqbq6z_604 ) ;



always @(posedge clk_out_0)
begin
  if (rst_in_0) 
  begin
	ciw0xljpqwjibmkfc3y49qfs_198 <= 1'b0 ;
	moinaxudsfdxjk6qeqbq6z_604 <= 1'b0 ;
	ahwef50eble2xrg0i2q20s_488 <= 1'b0 ;
	wgvmqdmfxmxuiismfijb9boscu7hl_248 <= 1'b0 ;
	rc30gpr48a1fecaj_514 <= 9'b000000000 ;
	xn5thqk9a056ca1d7ceq1p6_223 <= 1'b0 ;
	backpressure_out <= 1'b0 ;
   end
  else
  begin
		ciw0xljpqwjibmkfc3y49qfs_198 <= backpressure_in ;
		moinaxudsfdxjk6qeqbq6z_604 <= mb6f10f57nj69sjxxyoy_401 ;
		ahwef50eble2xrg0i2q20s_488 <= z8xsehjsqlr0x3mubng0dfh9hu4_37 ;
		wgvmqdmfxmxuiismfijb9boscu7hl_248 <= u788cu39qihe5botpsk4tndc4_392 ;
		rc30gpr48a1fecaj_514 <= fm4hyjmr6vfbqx51604mrcjjzm00_902 ;
		xn5thqk9a056ca1d7ceq1p6_223 <= rixfgl9t1auzjoevq9jnfkh_475 ;
		backpressure_out <= x91w7wlo0yzhgedxc5mffspnft8t03t_140 ;
  end
end

always @(posedge clk_out_1)
begin
  if (rst_in_0) 
  begin
	e0s2xnynj489e9prz_613 <= 1'b0 ;
	j4hlo821enpvjzgavkib9e3y5y_749 <= 1'b0 ;
   end
  else
  begin
		e0s2xnynj489e9prz_613 <= xgo76w63serbtp9kqkvrey0zlu5izp8_547 ;
		j4hlo821enpvjzgavkib9e3y5y_749 <= kasezejqafin7zu4s_322 ;
  end
end

always @(posedge clk_out_2)
begin
  if (rst_in_0) 
  begin
	xt83kkeq0r15lyirhsto_805 <= 1'b0 ;
   end
  else
  begin
		xt83kkeq0r15lyirhsto_805 <= vkilw659p3mqlj2d28jfjku6v67p_421 ;
  end
end

defparam sts2pskoy5lvri6mljt_419.WRITE_DATA_WIDTH = 72; 
defparam sts2pskoy5lvri6mljt_419.FIFO_WRITE_DEPTH = 512; 
defparam sts2pskoy5lvri6mljt_419.PROG_FULL_THRESH = 334; 
defparam sts2pskoy5lvri6mljt_419.PROG_EMPTY_THRESH = 334; 
defparam sts2pskoy5lvri6mljt_419.READ_MODE = "STD"; 
defparam sts2pskoy5lvri6mljt_419.WR_DATA_COUNT_WIDTH = 9; 
defparam sts2pskoy5lvri6mljt_419.RD_DATA_COUNT_WIDTH = 9; 
defparam sts2pskoy5lvri6mljt_419.DOUT_RESET_VALUE = "0"; 
defparam sts2pskoy5lvri6mljt_419.FIFO_MEMORY_TYPE = "bram"; 

xpm_fifo_sync sts2pskoy5lvri6mljt_419 (
	.wr_en(ksyt5yqt1gmx8xce2apy8k90bhwooyra_839),
	.din(xoj2tleywlceqwassmip_131),
	.rd_en(hrjt38zqu55ccifxavyhbz4ni_481),
	.sleep(n3vk8rqyoibor602_831),
	.injectsbiterr(),
	.injectdbiterr(),


	.prog_empty(tcr92l5dk6z1yqsx0tfk_47), 
	.dout(ysaacn866ep7c0oy7gs5cy9b_227), 
	.empty(r1uxaeafoazl2bkljiy_133), 
	.prog_full(rixfgl9t1auzjoevq9jnfkh_475), 
	.full(c3olrvm5alz9ns5l6hdhpa3kmpm7lpz_823), 
	.rd_data_count(qapomvzucblud5p61_639), 
	.wr_data_count(nh206goqwcpso3k3u7dt02su_797), 
	.wr_rst_busy(b5lvzlhljx8b926p8lsn080b2x78_481), 
	.rd_rst_busy(c1w249engdfdm9ocmtk_779), 
	.overflow(n82khb1nyoafi64g739u9sls4u_568), 
	.underflow(qc7qyb5gdflszr5yrzwr4ptfj26e8yu7_216), 
	.sbiterr(d02ildvhwke7jygvrmexxzgw_841), 
	.dbiterr(amryg6xj2xokr320k1tkse0bm7_462), 

	.wr_clk(clk_in_0), 
	.rst(rst_in_0) 
); 

defparam wfys2gmuep9p0hn3d1qkgq5_1765.WRITE_DATA_WIDTH = 1; 
defparam wfys2gmuep9p0hn3d1qkgq5_1765.FIFO_WRITE_DEPTH = 512; 
defparam wfys2gmuep9p0hn3d1qkgq5_1765.PROG_FULL_THRESH = 334; 
defparam wfys2gmuep9p0hn3d1qkgq5_1765.PROG_EMPTY_THRESH = 334; 
defparam wfys2gmuep9p0hn3d1qkgq5_1765.READ_MODE = "FWFT"; 
defparam wfys2gmuep9p0hn3d1qkgq5_1765.WR_DATA_COUNT_WIDTH = 9; 
defparam wfys2gmuep9p0hn3d1qkgq5_1765.RD_DATA_COUNT_WIDTH = 9; 
defparam wfys2gmuep9p0hn3d1qkgq5_1765.DOUT_RESET_VALUE = "0"; 
defparam wfys2gmuep9p0hn3d1qkgq5_1765.FIFO_MEMORY_TYPE = "lutram"; 

xpm_fifo_sync wfys2gmuep9p0hn3d1qkgq5_1765 (
	.wr_en(s7pcsc8mqxi5idxia4xlsfzuwrxx_188),
	.din(u1s9fbb70e7cg8t29gpd4zzb7k_266),
	.rd_en(q1fskm2p0a77jv0i7_277),
	.sleep(ecyp1i2a76nrzusbolh3uu5n4rv_113),
	.injectsbiterr(),
	.injectdbiterr(),


	.prog_empty(h2xevrid09zfqtr6qspm_190), 
	.dout(edvut540wdb8mevl6mg1i620f7hpt46_277), 
	.empty(dyaykuyjdo5wdz9r627innzvwv49e9k_758), 
	.prog_full(ku970nh0ttuyc6okgkic_856), 
	.full(ubn90glmf5eafyvyf_599), 
	.rd_data_count(feqtq9cglcwzyqbweo_801), 
	.wr_data_count(s2qb8r1jbub1zz2cav88m833r_21), 
	.wr_rst_busy(b72on1ifqvj4k2e4ic6mfduswnq6y_326), 
	.rd_rst_busy(av1litph7nmx8ivwf42no0nn312vw7lc_374), 
	.overflow(gh7m7h9d7ou9490n1k6ld7jlaq8y1e_868), 
	.underflow(a89w1f7d9qqr5gemfmbesbb2_873), 
	.sbiterr(yn35tcn56zg1ksy6krxo_825), 
	.dbiterr(ew4f2jqu20k5gn2fqpie450zqi4kn07g_639), 

	.wr_clk(clk_in_0), 
	.rst(rst_in_0) 
); 

defparam wuidpc9gzvkgxevnoz_1070.WRITE_DATA_WIDTH = 821; 
defparam wuidpc9gzvkgxevnoz_1070.FIFO_WRITE_DEPTH = 256; 
defparam wuidpc9gzvkgxevnoz_1070.PROG_FULL_THRESH = 65; 
defparam wuidpc9gzvkgxevnoz_1070.PROG_EMPTY_THRESH = 65; 
defparam wuidpc9gzvkgxevnoz_1070.READ_MODE = "STD"; 
defparam wuidpc9gzvkgxevnoz_1070.WR_DATA_COUNT_WIDTH = 8; 
defparam wuidpc9gzvkgxevnoz_1070.RD_DATA_COUNT_WIDTH = 8; 
defparam wuidpc9gzvkgxevnoz_1070.DOUT_RESET_VALUE = "0"; 
defparam wuidpc9gzvkgxevnoz_1070.FIFO_MEMORY_TYPE = "bram"; 

xpm_fifo_async wuidpc9gzvkgxevnoz_1070 (
	.wr_en(tdk1dk8p835po3c1oc9thyz3z_473),
	.din(lf5ae3tcserkrmkmouyidctzdar8x_433),
	.rd_en(sys5umfsiko4xnjza_611),
	.sleep(d78t6l9tzt95q8tldotnn8putaz66k6_454),
	.injectsbiterr(),
	.injectdbiterr(),


	.prog_empty(qkeag4fz9lv8c0fx6fp_627), 
	.dout(ex64ine9nv0bqx4lo5qm_862), 
	.empty(fog3x92f0hvxf4rjgghg_323), 
	.prog_full(kasezejqafin7zu4s_322), 
	.full(yc2nfqihyqcpsm3lcsahtl_544), 
	.rd_data_count(w5c3kh91tu08ow8b6jq_699), 
	.wr_data_count(n8rb5325q7z2kpmzb8zzbx9agejnhl9_605), 
	.wr_rst_busy(pxxc9a8p5rj8zzkvfxs8e4jj7xq_665), 
	.rd_rst_busy(e1k15icmgu6zsfy0_375), 
	.overflow(r8whgf9iroqqcx2e4d_142), 
	.underflow(pqpq5zypuo76vjw3e1r1fm_830), 
	.sbiterr(k963vnniygq2mrvuq50apaxj9t1_771), 
	.dbiterr(da3emy0k50cqmrv7_132), 

	.wr_clk(clk_in_1), 

	.rd_clk(clk_out_1), 
	.rst(rst_in_1) 
); 

defparam faz78j79mcyke60ajqil8heqyp_391.WRITE_DATA_WIDTH = 23; 
defparam faz78j79mcyke60ajqil8heqyp_391.FIFO_WRITE_DEPTH = 256; 
defparam faz78j79mcyke60ajqil8heqyp_391.PROG_FULL_THRESH = 72; 
defparam faz78j79mcyke60ajqil8heqyp_391.PROG_EMPTY_THRESH = 72; 
defparam faz78j79mcyke60ajqil8heqyp_391.READ_MODE = "STD"; 
defparam faz78j79mcyke60ajqil8heqyp_391.WR_DATA_COUNT_WIDTH = 8; 
defparam faz78j79mcyke60ajqil8heqyp_391.RD_DATA_COUNT_WIDTH = 8; 
defparam faz78j79mcyke60ajqil8heqyp_391.DOUT_RESET_VALUE = "0"; 
defparam faz78j79mcyke60ajqil8heqyp_391.FIFO_MEMORY_TYPE = "lutram"; 

xpm_fifo_async faz78j79mcyke60ajqil8heqyp_391 (
	.wr_en(v89lbqwhp6v8cxopqsc8_410),
	.din(ykdq9ujw7us0epnqqbmdeuv2edyp_891),
	.rd_en(zjeu7wu9h876o04ij_50),
	.sleep(fedbx2vd29dyecdnbxq6gnxaepdpl_306),
	.injectsbiterr(),
	.injectdbiterr(),


	.prog_empty(otk5cwc7c15i4ow337j2exn7_609), 
	.dout(m3il95eefjpisb4mxxes_601), 
	.empty(vpee2mw2jo0rks6dj2boyu1in49bj_210), 
	.prog_full(vkilw659p3mqlj2d28jfjku6v67p_421), 
	.full(lsomfwx3skesgmoksyou1f2f_143), 
	.rd_data_count(kpa2cvnm0lv7tu2zucuppwhe1w8rblp_2), 
	.wr_data_count(hm5mikfzpyda5d47vganqh24qaz8_644), 
	.wr_rst_busy(ef5cj9qiz780a1zdzftd_596), 
	.rd_rst_busy(yhc45ho0fxc29a3wqsxzbvf2653owms_182), 
	.overflow(g73c6lmsak5s8tosn9tkylcx_473), 
	.underflow(arequli3tcn96jb17_282), 
	.sbiterr(cjgb3fkvpnypefp35o4dj1_669), 
	.dbiterr(r9yirdawvvt5qt8h37gstd8h2nbnl4_259), 

	.wr_clk(clk_in_2), 

	.rd_clk(clk_out_2), 
	.rst(rst_in_2) 
); 

endmodule 
