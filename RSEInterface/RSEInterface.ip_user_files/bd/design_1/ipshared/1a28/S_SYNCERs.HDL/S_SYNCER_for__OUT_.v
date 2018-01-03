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
// File name: S_SYNCER_for__OUT_.v
// File created: 2017/10/23 14:31:57
// Created by: Xilinx SDNet Compiler version 2017.2.1, build 1997167

//----------------------------------------------------------------------------

`timescale 1 ns / 100 ps

module S_SYNCER_for__OUT_ (
     packet_in_PACKET0_TVALID, 
     packet_in_PACKET0_TDATA, 
     packet_in_PACKET0_TKEEP, 
     packet_in_PACKET0_TLAST, 
     packet_out_PACKET0_TREADY, 
     backpressure_in, 


     packet_out_PACKET0_TVALID, 
     packet_out_PACKET0_TDATA, 
     packet_out_PACKET0_TKEEP, 
     packet_out_PACKET0_TLAST, 
     packet_in_PACKET0_TREADY, 
     backpressure_out, 

     clk_in_0, 
     clk_out_0, 
     rst_in_0, 
     rst_out_0 

);

//-------------------------------------------------------------
// I/O
//-------------------------------------------------------------
 input		packet_in_PACKET0_TVALID ;
 input	 [63:0] packet_in_PACKET0_TDATA ;
 input	 [7:0] packet_in_PACKET0_TKEEP ;
 input		packet_in_PACKET0_TLAST ;
 input		packet_out_PACKET0_TREADY ;
 input		backpressure_in ;
 output		packet_out_PACKET0_TVALID ;
 output	 [63:0] packet_out_PACKET0_TDATA ;
 output	 [7:0] packet_out_PACKET0_TKEEP ;
 output		packet_out_PACKET0_TLAST ;
 output		packet_in_PACKET0_TREADY ;
 output	reg	backpressure_out ;
 input		clk_in_0 ;
 input		clk_out_0 ;
 input		rst_in_0 ;
 input		rst_out_0 ;






 reg	h2xqvl3p6xln77qx3r58_76;	 initial h2xqvl3p6xln77qx3r58_76 = 1'b0 ;
 wire	a5a13iqtsfjruvgeekauqe5cwxnni3_632 ;
 wire [73:0] qqd62kgbrqrrn0wdw9_671 ;
 wire	cghtgcxqyp0jf50nmkjs29f0ti5b_137 ;
 wire	lz69veis10i86pjwiry_892 ;
 wire	oa8a8rzf3y4gn695jwzktza_634 ;
 wire [8:0] rw2f7woqekp8ndp8upt_543 ;
 wire [8:0] ktkuipbx2sy5nyqi_341 ;
 wire	jpexlwqbwseigjp96sfzszt8_737 ;
 wire	uhy4pzkhm05cjbmgu0p1kr2ya5j3_633 ;
 wire	xh57rdnsl7nj6cqbib3_43 ;
 wire	gpxc9uko3v6i8g1l7m_704 ;
 wire	v3stynerbaea3v1257whq5wpfhjh8_472 ;
 wire	achkq7sipp4v6k0w0vmd_215 ;
 wire	g1rw5ao0dmtc9ito8fvjk68yfj0xpb_421 ;
 reg	oc3fg969lcni8s7at2llijnc92mwege8_717;	 initial oc3fg969lcni8s7at2llijnc92mwege8_717 = 1'b0 ;
 wire	c7k1iip2dbbx70qyepmskguqv6k49_830 ;
 reg	d7zb0uvnn9rmw5mwy_804;	 initial d7zb0uvnn9rmw5mwy_804 = 1'b0 ;
 reg	uddmuo7t8a8c3viuijw1sgg7d_300;	 initial uddmuo7t8a8c3viuijw1sgg7d_300 = 1'b0 ;
 wire	csowxcn9qobdykys8t0_393 ;
 wire [0:0] bu9uwtt1keu4052dakw2i778mt4j7k0l_893 ;
 wire	jp3gxbgaxbg8iy26ewjgzla2oi6_655 ;
 wire	pfdy4ragaun3h7eerynb7mso0v0voyr_700 ;
 wire	ezpq9gktt921uecpbv5h26m74mb_615 ;
 wire [8:0] womgq97mvryh1dd9r_102 ;
 wire [8:0] r2drxvcxjwvnjquie_851 ;
 wire	p72eepn4n0oppl8d64iqm7_140 ;
 wire	kc2lf9va3nc5tjc7tyoudhj4_204 ;
 wire	wgef5me2xl4balry733cgw8o3tim_459 ;
 wire	n5bg90uiz72lorkabvo6b8ndip1zb_269 ;
 wire	pf9lwul7i0agnmsozmewzo_544 ;
 wire	ewidls07nkpqk8td5v_548 ;
 reg	zn0of8kbtaassv0dpedy2cwjrcwd51_207;	 initial zn0of8kbtaassv0dpedy2cwjrcwd51_207 = 1'b0 ;
 reg	bd0yep9khbosm6sc1li5e96_101;	 initial bd0yep9khbosm6sc1li5e96_101 = 1'b1 ;
 reg [8:0] vku9eu0ltg72gmyw4mt_637;	 initial vku9eu0ltg72gmyw4mt_637 = 9'b000000000 ;
 reg	f0mwg2ap5kcalu4rchsegfzhe_90;	 initial f0mwg2ap5kcalu4rchsegfzhe_90 = 1'b0 ;
 wire	q4bmdtz5x91hd1xxos_257 ;
 wire [73:0] s0kog3ybkhz6x6t145ee_523 ;
 wire	nq29j7c830lgnunw_411 ;
 wire [73:0] wwr1zlnlbzpc8kv9jwvd218yj_101 ;
 wire	x7s4skh4utnv6lieyj1w17s9kb47lc_806 ;
 wire	s75dj58leg5q7lvdsp_433 ;
 wire	t5dqeqty00gu6oybb_520 ;
 wire	x2qw46af9avz7p0us_103 ;
 wire	g7a4abry9qr8497b1wgps_58 ;
 wire	z888tap9wz280kvz9i5k1fjptvcf5_204 ;
 wire	y9kpman8rv87u7btl0b8njv_0 ;
 wire	oqrgu9pnstulgsaasf3v8c52sipd_494 ;
 wire	btlun3of9om74njd8q5pfm6ns1lde_446 ;
 wire	afzvnc7dwipwl50l3djfpuvkqoj7gv1_147 ;
 wire	qps7hobrc2ii633ndsd4qan9r61l1fj_664 ;
 wire	ltqi46ajbrkt50i1p18odi42_263 ;
 wire	tj4dj5foik1p1wbbi9yber87szr1tm_732 ;
 wire	fpf6nejei1j19lkqwmuxc3z2_737 ;
 wire [7:0] dbpmdk55oww6qhzwnj9nqa3b_6 ;
 wire [63:0] kzcxzscbp9v0g2a3qavdq4otfpqe3oc1_124 ;
 wire	dkfh8oi080fmwja2z_514 ;
 wire	v69zsnvkxtdjghonvh8simep23hlq8x_211 ;
 wire	akm7vlopr5ichlawdaxb51r53_585 ;
 wire	ysz6zg60k7pvnccoc4bsj0_165 ;
 wire	jw46h9gl9fw7h4u1mybkkgq_339 ;
 wire	yjgskly7c32vvg8xvz24t8eb_376 ;
 wire	fl8vgo2u155bgkjkd0jdyb5_504 ;
 wire	l17a4hyb5kchcacuk3f5jxzmkxt_735 ;
 wire [0:0] avmifuok3feb04b49tjkvzg8t9eexltq_226 ;
 wire	up83rtqnqo005t2pssvx60ua7a2f_99 ;
 wire	w23zk0rrpa7vjxbpv16vdi_652 ;
 wire [8:0] ephypg1u7kqi4ch6qsbp033pmr1rjv_584 ;
 wire	iutx6z5egorvip7dh3345tvz6qk8r5_387 ;
 wire	j6l6wmzeluukv9v9kzws0hv7nocwe_653 ;
 wire	birtducx99qvq87g_203 ;
 wire	n4elntsflypp8473nnip07jvbpajv_629 ;
 wire	yu8u2zqb7t6p6grlswp8u_220 ;
 wire	p7mexjyqaxfz66k92ztziku3ckyo6ju_109 ;
 wire	ox0vkva9sftq8x8p9n_906 ;
 wire	qw399ax4vddnpr4pb4599lq_526 ;


 assign q4bmdtz5x91hd1xxos_257 = 
	 ~(backpressure_in) ;
 assign s0kog3ybkhz6x6t145ee_523 = 
	{packet_in_PACKET0_TVALID, packet_in_PACKET0_TDATA, packet_in_PACKET0_TKEEP, packet_in_PACKET0_TLAST} ;
 assign nq29j7c830lgnunw_411 	= packet_in_PACKET0_TVALID ;
 assign wwr1zlnlbzpc8kv9jwvd218yj_101 	= s0kog3ybkhz6x6t145ee_523[73:0] ;
 assign x7s4skh4utnv6lieyj1w17s9kb47lc_806 = 
	n4elntsflypp8473nnip07jvbpajv_629 | ox0vkva9sftq8x8p9n_906 ;
 assign s75dj58leg5q7lvdsp_433 = 
	1'b0 ;
 assign t5dqeqty00gu6oybb_520 = 
	1'b1 ;
 assign x2qw46af9avz7p0us_103 = 
	 ~(c7k1iip2dbbx70qyepmskguqv6k49_830) ;
 assign g7a4abry9qr8497b1wgps_58 = 
	p7mexjyqaxfz66k92ztziku3ckyo6ju_109 & x7s4skh4utnv6lieyj1w17s9kb47lc_806 & tj4dj5foik1p1wbbi9yber87szr1tm_732 ;
 assign z888tap9wz280kvz9i5k1fjptvcf5_204 = 
	x2qw46af9avz7p0us_103 & oc3fg969lcni8s7at2llijnc92mwege8_717 & tj4dj5foik1p1wbbi9yber87szr1tm_732 & n4elntsflypp8473nnip07jvbpajv_629 & p7mexjyqaxfz66k92ztziku3ckyo6ju_109 ;
 assign y9kpman8rv87u7btl0b8njv_0 = 
	g7a4abry9qr8497b1wgps_58 | z888tap9wz280kvz9i5k1fjptvcf5_204 ;
 assign oqrgu9pnstulgsaasf3v8c52sipd_494 = 
	q4bmdtz5x91hd1xxos_257 & y9kpman8rv87u7btl0b8njv_0 ;
 assign btlun3of9om74njd8q5pfm6ns1lde_446 = 
	backpressure_in & h2xqvl3p6xln77qx3r58_76 & p7mexjyqaxfz66k92ztziku3ckyo6ju_109 & birtducx99qvq87g_203 & ox0vkva9sftq8x8p9n_906 & x2qw46af9avz7p0us_103 ;
 assign afzvnc7dwipwl50l3djfpuvkqoj7gv1_147 = 
	oqrgu9pnstulgsaasf3v8c52sipd_494 | btlun3of9om74njd8q5pfm6ns1lde_446 ;
 assign qps7hobrc2ii633ndsd4qan9r61l1fj_664 	= afzvnc7dwipwl50l3djfpuvkqoj7gv1_147 ;
 assign ltqi46ajbrkt50i1p18odi42_263 = 
	1'b0 ;
 assign tj4dj5foik1p1wbbi9yber87szr1tm_732 = 
	 ~(cghtgcxqyp0jf50nmkjs29f0ti5b_137) ;
 assign fpf6nejei1j19lkqwmuxc3z2_737 	= qqd62kgbrqrrn0wdw9_671[0] ;
 assign dbpmdk55oww6qhzwnj9nqa3b_6 	= qqd62kgbrqrrn0wdw9_671[8:1] ;
 assign kzcxzscbp9v0g2a3qavdq4otfpqe3oc1_124 	= qqd62kgbrqrrn0wdw9_671[72:9] ;
 assign dkfh8oi080fmwja2z_514 	= qqd62kgbrqrrn0wdw9_671[73] ;
 assign v69zsnvkxtdjghonvh8simep23hlq8x_211 	= oc3fg969lcni8s7at2llijnc92mwege8_717 ;
 assign akm7vlopr5ichlawdaxb51r53_585 	= packet_in_PACKET0_TVALID ;
 assign ysz6zg60k7pvnccoc4bsj0_165 = 
	1'b0 ;
 assign jw46h9gl9fw7h4u1mybkkgq_339 = 
	1'b1 ;
 assign yjgskly7c32vvg8xvz24t8eb_376 = (
	((zn0of8kbtaassv0dpedy2cwjrcwd51_207 == 1'b1) && (packet_in_PACKET0_TVALID == 1'b1))?1'b1:
	((bd0yep9khbosm6sc1li5e96_101 == 1'b1) && (packet_in_PACKET0_TVALID == 1'b1))?1'b1:
	0)  ;
 assign fl8vgo2u155bgkjkd0jdyb5_504 = (
	((packet_in_PACKET0_TVALID == 1'b1) && (packet_in_PACKET0_TLAST == 1'b1))?1'b1:
	0)  ;
 assign l17a4hyb5kchcacuk3f5jxzmkxt_735 = (
	((packet_in_PACKET0_TVALID == 1'b1) && (packet_in_PACKET0_TLAST == 1'b0))?1'b1:
	0)  ;
 assign avmifuok3feb04b49tjkvzg8t9eexltq_226 = yjgskly7c32vvg8xvz24t8eb_376 ;
 assign up83rtqnqo005t2pssvx60ua7a2f_99 	= afzvnc7dwipwl50l3djfpuvkqoj7gv1_147 ;
 assign w23zk0rrpa7vjxbpv16vdi_652 = 
	1'b0 ;
 assign ephypg1u7kqi4ch6qsbp033pmr1rjv_584 	= womgq97mvryh1dd9r_102[8:0] ;
 assign iutx6z5egorvip7dh3345tvz6qk8r5_387 = (
	((ephypg1u7kqi4ch6qsbp033pmr1rjv_584 != vku9eu0ltg72gmyw4mt_637))?1'b1:
	0)  ;
 assign j6l6wmzeluukv9v9kzws0hv7nocwe_653 = bu9uwtt1keu4052dakw2i778mt4j7k0l_893 ;
 assign birtducx99qvq87g_203 = bu9uwtt1keu4052dakw2i778mt4j7k0l_893 ;
 assign n4elntsflypp8473nnip07jvbpajv_629 = 
	 ~(birtducx99qvq87g_203) ;
 assign yu8u2zqb7t6p6grlswp8u_220 	= jp3gxbgaxbg8iy26ewjgzla2oi6_655 ;
 assign p7mexjyqaxfz66k92ztziku3ckyo6ju_109 = 
	 ~(jp3gxbgaxbg8iy26ewjgzla2oi6_655) ;
 assign ox0vkva9sftq8x8p9n_906 = 
	tj4dj5foik1p1wbbi9yber87szr1tm_732 ;
 assign qw399ax4vddnpr4pb4599lq_526 = 
	f0mwg2ap5kcalu4rchsegfzhe_90 ;
 assign packet_out_PACKET0_TVALID 	= v69zsnvkxtdjghonvh8simep23hlq8x_211 ;
 assign packet_out_PACKET0_TDATA 	= kzcxzscbp9v0g2a3qavdq4otfpqe3oc1_124[63:0] ;
 assign packet_out_PACKET0_TKEEP 	= dbpmdk55oww6qhzwnj9nqa3b_6[7:0] ;
 assign packet_out_PACKET0_TLAST 	= fpf6nejei1j19lkqwmuxc3z2_737 ;
 assign packet_in_PACKET0_TREADY 	= packet_out_PACKET0_TREADY ;


assign g1rw5ao0dmtc9ito8fvjk68yfj0xpb_421 = (
	((afzvnc7dwipwl50l3djfpuvkqoj7gv1_147 == 1'b1))?t5dqeqty00gu6oybb_520 :
	((q4bmdtz5x91hd1xxos_257 == 1'b1))?s75dj58leg5q7lvdsp_433 :
	oc3fg969lcni8s7at2llijnc92mwege8_717 ) ;

assign c7k1iip2dbbx70qyepmskguqv6k49_830 = (
	((oc3fg969lcni8s7at2llijnc92mwege8_717 == 1'b1) && (q4bmdtz5x91hd1xxos_257 == 1'b1))?s75dj58leg5q7lvdsp_433 :
	oc3fg969lcni8s7at2llijnc92mwege8_717 ) ;



always @(posedge clk_out_0)
begin
  if (rst_in_0) 
  begin
	h2xqvl3p6xln77qx3r58_76 <= 1'b0 ;
	oc3fg969lcni8s7at2llijnc92mwege8_717 <= 1'b0 ;
	d7zb0uvnn9rmw5mwy_804 <= 1'b0 ;
	uddmuo7t8a8c3viuijw1sgg7d_300 <= 1'b0 ;
	vku9eu0ltg72gmyw4mt_637 <= 9'b000000000 ;
	f0mwg2ap5kcalu4rchsegfzhe_90 <= 1'b0 ;
	backpressure_out <= 1'b0 ;
   end
  else
  begin
		h2xqvl3p6xln77qx3r58_76 <= backpressure_in ;
		oc3fg969lcni8s7at2llijnc92mwege8_717 <= g1rw5ao0dmtc9ito8fvjk68yfj0xpb_421 ;
		d7zb0uvnn9rmw5mwy_804 <= tj4dj5foik1p1wbbi9yber87szr1tm_732 ;
		uddmuo7t8a8c3viuijw1sgg7d_300 <= afzvnc7dwipwl50l3djfpuvkqoj7gv1_147 ;
		vku9eu0ltg72gmyw4mt_637 <= ephypg1u7kqi4ch6qsbp033pmr1rjv_584 ;
		f0mwg2ap5kcalu4rchsegfzhe_90 <= lz69veis10i86pjwiry_892 ;
		backpressure_out <= qw399ax4vddnpr4pb4599lq_526 ;
  end
end

always @(posedge clk_in_0)
begin
  if (rst_in_0) 
  begin
	zn0of8kbtaassv0dpedy2cwjrcwd51_207 <= 1'b0 ;
	bd0yep9khbosm6sc1li5e96_101 <= 1'b1 ;
   end
  else
  begin
	if (l17a4hyb5kchcacuk3f5jxzmkxt_735) 
	begin 
	  zn0of8kbtaassv0dpedy2cwjrcwd51_207 <= 1'b0 ;
	 end 
	else 
	begin 
		if (fl8vgo2u155bgkjkd0jdyb5_504) 
		begin 
			zn0of8kbtaassv0dpedy2cwjrcwd51_207 <= jw46h9gl9fw7h4u1mybkkgq_339 ;
		end 
	end 
	if (yjgskly7c32vvg8xvz24t8eb_376) 
	begin 
		bd0yep9khbosm6sc1li5e96_101 <= ysz6zg60k7pvnccoc4bsj0_165 ;
	end 
  end
end

defparam dc6iubco7vtqvnbzg_761.WRITE_DATA_WIDTH = 74; 
defparam dc6iubco7vtqvnbzg_761.FIFO_WRITE_DEPTH = 512; 
defparam dc6iubco7vtqvnbzg_761.PROG_FULL_THRESH = 320; 
defparam dc6iubco7vtqvnbzg_761.PROG_EMPTY_THRESH = 320; 
defparam dc6iubco7vtqvnbzg_761.READ_MODE = "STD"; 
defparam dc6iubco7vtqvnbzg_761.WR_DATA_COUNT_WIDTH = 9; 
defparam dc6iubco7vtqvnbzg_761.RD_DATA_COUNT_WIDTH = 9; 
defparam dc6iubco7vtqvnbzg_761.DOUT_RESET_VALUE = "0"; 
defparam dc6iubco7vtqvnbzg_761.FIFO_MEMORY_TYPE = "bram"; 

xpm_fifo_sync dc6iubco7vtqvnbzg_761 (
	.wr_en(nq29j7c830lgnunw_411),
	.din(wwr1zlnlbzpc8kv9jwvd218yj_101),
	.rd_en(qps7hobrc2ii633ndsd4qan9r61l1fj_664),
	.sleep(ltqi46ajbrkt50i1p18odi42_263),
	.injectsbiterr(),
	.injectdbiterr(),


	.prog_empty(a5a13iqtsfjruvgeekauqe5cwxnni3_632), 
	.dout(qqd62kgbrqrrn0wdw9_671), 
	.empty(cghtgcxqyp0jf50nmkjs29f0ti5b_137), 
	.prog_full(lz69veis10i86pjwiry_892), 
	.full(oa8a8rzf3y4gn695jwzktza_634), 
	.rd_data_count(rw2f7woqekp8ndp8upt_543), 
	.wr_data_count(ktkuipbx2sy5nyqi_341), 
	.wr_rst_busy(jpexlwqbwseigjp96sfzszt8_737), 
	.rd_rst_busy(uhy4pzkhm05cjbmgu0p1kr2ya5j3_633), 
	.overflow(xh57rdnsl7nj6cqbib3_43), 
	.underflow(gpxc9uko3v6i8g1l7m_704), 
	.sbiterr(v3stynerbaea3v1257whq5wpfhjh8_472), 
	.dbiterr(achkq7sipp4v6k0w0vmd_215), 

	.wr_clk(clk_in_0), 
	.rst(rst_in_0) 
); 

defparam gpcguky47b3va7uhcqqy_376.WRITE_DATA_WIDTH = 1; 
defparam gpcguky47b3va7uhcqqy_376.FIFO_WRITE_DEPTH = 512; 
defparam gpcguky47b3va7uhcqqy_376.PROG_FULL_THRESH = 320; 
defparam gpcguky47b3va7uhcqqy_376.PROG_EMPTY_THRESH = 320; 
defparam gpcguky47b3va7uhcqqy_376.READ_MODE = "FWFT"; 
defparam gpcguky47b3va7uhcqqy_376.WR_DATA_COUNT_WIDTH = 9; 
defparam gpcguky47b3va7uhcqqy_376.RD_DATA_COUNT_WIDTH = 9; 
defparam gpcguky47b3va7uhcqqy_376.DOUT_RESET_VALUE = "0"; 
defparam gpcguky47b3va7uhcqqy_376.FIFO_MEMORY_TYPE = "lutram"; 

xpm_fifo_sync gpcguky47b3va7uhcqqy_376 (
	.wr_en(akm7vlopr5ichlawdaxb51r53_585),
	.din(avmifuok3feb04b49tjkvzg8t9eexltq_226),
	.rd_en(up83rtqnqo005t2pssvx60ua7a2f_99),
	.sleep(w23zk0rrpa7vjxbpv16vdi_652),
	.injectsbiterr(),
	.injectdbiterr(),


	.prog_empty(csowxcn9qobdykys8t0_393), 
	.dout(bu9uwtt1keu4052dakw2i778mt4j7k0l_893), 
	.empty(jp3gxbgaxbg8iy26ewjgzla2oi6_655), 
	.prog_full(pfdy4ragaun3h7eerynb7mso0v0voyr_700), 
	.full(ezpq9gktt921uecpbv5h26m74mb_615), 
	.rd_data_count(womgq97mvryh1dd9r_102), 
	.wr_data_count(r2drxvcxjwvnjquie_851), 
	.wr_rst_busy(p72eepn4n0oppl8d64iqm7_140), 
	.rd_rst_busy(kc2lf9va3nc5tjc7tyoudhj4_204), 
	.overflow(wgef5me2xl4balry733cgw8o3tim_459), 
	.underflow(n5bg90uiz72lorkabvo6b8ndip1zb_269), 
	.sbiterr(pf9lwul7i0agnmsozmewzo_544), 
	.dbiterr(ewidls07nkpqk8td5v_548), 

	.wr_clk(clk_in_0), 
	.rst(rst_in_0) 
); 

endmodule 
