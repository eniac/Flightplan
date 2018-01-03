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
// File name: S_RESETTER_line.v
// File created: 2017/10/23 14:31:57
// Created by: Xilinx SDNet Compiler version 2017.2.1, build 1997167

//----------------------------------------------------------------------------

`timescale 1 ns / 100 ps

module S_RESETTER_line (


     reset_out_active_high, 
     reset_out_active_low, 
     init_done, 

     clk, 
     rst 

);

//-------------------------------------------------------------
// I/O
//-------------------------------------------------------------
 output		reset_out_active_high ;
 output		reset_out_active_low ;
 output	reg	init_done ;
 input		clk ;
 input		rst ;






 reg	j6xsfsuotgs0xc2etmbqh5zv_23;	 initial j6xsfsuotgs0xc2etmbqh5zv_23 = 1'b0 ;
 reg	dw525uvqysqvlw4q_464;	 initial dw525uvqysqvlw4q_464 = 1'b0 ;
 reg [4:0] k27ojsy8iu71xt5l4x_206;	 initial k27ojsy8iu71xt5l4x_206 = 5'b00000 ;
 reg [4:0] wgy062h70j44rdp6x9us2a8twl4ed_85;	 initial wgy062h70j44rdp6x9us2a8twl4ed_85 = 5'b00000 ;
 wire	aubqjirh5p1qms31eq5xq7hgyknxycxw_817 ;
 reg	oo6ekqn0vqv7jwh4_262;	 initial oo6ekqn0vqv7jwh4_262 = 1'b1 ;
 reg	bwepb7on53oxfqih_230;	 initial bwepb7on53oxfqih_230 = 1'b0 ;
 reg	knox4ns3qi1to8z83s8et67g5bj9k1e_133;	 initial knox4ns3qi1to8z83s8et67g5bj9k1e_133 = 1'b1 ;
 reg	g5xvcuyvyafac7earj9bha0br975tbes_530;	 initial g5xvcuyvyafac7earj9bha0br975tbes_530 = 1'b0 ;
 wire [4:0] g8fz9gghje2z90ljh1xgynltwzb_14 ;
 wire [4:0] plbeww0tmudpv3qjkm9iomiaazusm_200 ;
 wire	kkw8xqcvbdn9dz2cjfr8yax10y46oo_573 ;
 wire	ur5el4i01glfdheg6yl_236 ;
 wire	q57mwyir2vpmuo17r8nczwqu_170 ;
 wire	hap7v6h061m7lri2clh_277 ;
 wire	as25aigyw3y5iadkzpuj_796 ;
 wire	zf3ot013jhyigciui5xapov3_229 ;
 wire	eizwafpz3312gzzepkkxl8_769 ;
 wire	s2pkdssmicewr4gs5q_244 ;
 wire	ei78hfpx1srgc604wctjqird69k97o_726 ;
 wire	yrahw6uljpvr74jxlejwgytf62c3h_582 ;
 wire	mhlsg3869rrps4jtc_80 ;
 wire	x74bh6hq9yoakigncu2tbto3tmugzd1c_230 ;


 assign g8fz9gghje2z90ljh1xgynltwzb_14 = 
	k27ojsy8iu71xt5l4x_206 + 1 ;
 assign plbeww0tmudpv3qjkm9iomiaazusm_200 = 
	wgy062h70j44rdp6x9us2a8twl4ed_85 + 1 ;
 assign kkw8xqcvbdn9dz2cjfr8yax10y46oo_573 = (
	((k27ojsy8iu71xt5l4x_206 > 5'b00000))?1'b1:
	0)  ;
 assign ur5el4i01glfdheg6yl_236 = 
	rst | dw525uvqysqvlw4q_464 ;
 assign q57mwyir2vpmuo17r8nczwqu_170 = 
	ur5el4i01glfdheg6yl_236 | kkw8xqcvbdn9dz2cjfr8yax10y46oo_573 ;
 assign hap7v6h061m7lri2clh_277 = (
	((dw525uvqysqvlw4q_464 == 1'b1) && (x74bh6hq9yoakigncu2tbto3tmugzd1c_230 == 1'b1) && (k27ojsy8iu71xt5l4x_206 == 5'b00000))?1'b1:
	((k27ojsy8iu71xt5l4x_206 != 5'b00000) && (dw525uvqysqvlw4q_464 != 1'b1))?1'b1:
	0)  ;
 assign as25aigyw3y5iadkzpuj_796 = (
	((j6xsfsuotgs0xc2etmbqh5zv_23 == 1'b1))?1'b1:
	0)  ;
 assign zf3ot013jhyigciui5xapov3_229 = (
	((k27ojsy8iu71xt5l4x_206 == 5'b01111) && (dw525uvqysqvlw4q_464 != 1'b1) && (x74bh6hq9yoakigncu2tbto3tmugzd1c_230 == 1'b1))?1'b1:
	((wgy062h70j44rdp6x9us2a8twl4ed_85 != 5'b00000) && (wgy062h70j44rdp6x9us2a8twl4ed_85 != 5'b01111) && (dw525uvqysqvlw4q_464 != 1'b1) && (x74bh6hq9yoakigncu2tbto3tmugzd1c_230 == 1'b1))?1'b1:
	0)  ;
 assign eizwafpz3312gzzepkkxl8_769 = (
	((wgy062h70j44rdp6x9us2a8twl4ed_85 == 5'b01111))?1'b1:
	0)  ;
 assign s2pkdssmicewr4gs5q_244 = 
	1'b1 ;
 assign ei78hfpx1srgc604wctjqird69k97o_726 = 
	1'b0 ;
 assign yrahw6uljpvr74jxlejwgytf62c3h_582 = 
	 ~(aubqjirh5p1qms31eq5xq7hgyknxycxw_817) ;
 assign mhlsg3869rrps4jtc_80 = (
	((wgy062h70j44rdp6x9us2a8twl4ed_85 == 5'b01111))?1'b1:
	0)  ;
 assign x74bh6hq9yoakigncu2tbto3tmugzd1c_230 = 
	1'b1 ;
 assign reset_out_active_high 	= knox4ns3qi1to8z83s8et67g5bj9k1e_133 ;
 assign reset_out_active_low 	= g5xvcuyvyafac7earj9bha0br975tbes_530 ;


assign aubqjirh5p1qms31eq5xq7hgyknxycxw_817 = (
	((q57mwyir2vpmuo17r8nczwqu_170 == 1'b1) && (k27ojsy8iu71xt5l4x_206 < 5'b10000))?s2pkdssmicewr4gs5q_244 :
1'b0) ;



always @(posedge clk)
begin
		j6xsfsuotgs0xc2etmbqh5zv_23 <= rst ;
		dw525uvqysqvlw4q_464 <= j6xsfsuotgs0xc2etmbqh5zv_23 ;
	if (as25aigyw3y5iadkzpuj_796) 
	begin 
	  k27ojsy8iu71xt5l4x_206 <= 5'b00000 ;
	 end 
	else 
	begin 
		if (hap7v6h061m7lri2clh_277) 
		begin 
			k27ojsy8iu71xt5l4x_206 <= g8fz9gghje2z90ljh1xgynltwzb_14 ;
		end 
	end 
	if (as25aigyw3y5iadkzpuj_796) 
	begin 
	  wgy062h70j44rdp6x9us2a8twl4ed_85 <= 5'b00000 ;
	 end 
	else 
	begin 
		if (zf3ot013jhyigciui5xapov3_229) 
		begin 
			wgy062h70j44rdp6x9us2a8twl4ed_85 <= plbeww0tmudpv3qjkm9iomiaazusm_200 ;
		end 
	end 
	if (rst) 
	begin 
	  oo6ekqn0vqv7jwh4_262 <= 1'b1 ;
	 end 
	else 
	begin 
			oo6ekqn0vqv7jwh4_262 <= aubqjirh5p1qms31eq5xq7hgyknxycxw_817 ;
	end 
	if (rst) 
	begin 
	  bwepb7on53oxfqih_230 <= 1'b0 ;
	 end 
	else 
	begin 
			bwepb7on53oxfqih_230 <= yrahw6uljpvr74jxlejwgytf62c3h_582 ;
	end 
	if (rst) 
	begin 
	  knox4ns3qi1to8z83s8et67g5bj9k1e_133 <= 1'b1 ;
	 end 
	else 
	begin 
			knox4ns3qi1to8z83s8et67g5bj9k1e_133 <= oo6ekqn0vqv7jwh4_262 ;
	end 
	if (rst) 
	begin 
	  g5xvcuyvyafac7earj9bha0br975tbes_530 <= 1'b0 ;
	 end 
	else 
	begin 
			g5xvcuyvyafac7earj9bha0br975tbes_530 <= bwepb7on53oxfqih_230 ;
	end 
		init_done <= mhlsg3869rrps4jtc_80 ;
end

endmodule 
