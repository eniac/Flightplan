
//MODULE DECLARATION
module design_1_zynq_ultra_ps_e_0_0(
      maxihpm0_lpd_aclk,
      maxigp2_awid,
      maxigp2_awaddr,
      maxigp2_awlen,
      maxigp2_awsize,
      maxigp2_awburst,
      maxigp2_awlock,
      maxigp2_awcache,
      maxigp2_awprot,
      maxigp2_awvalid,
      maxigp2_awuser,
      maxigp2_awready,
      maxigp2_wdata,
      maxigp2_wstrb,
      maxigp2_wlast,
      maxigp2_wvalid,
      maxigp2_wready,
      maxigp2_bid,
      maxigp2_bresp,
      maxigp2_bvalid,
      maxigp2_bready,
      maxigp2_arid,
      maxigp2_araddr,
      maxigp2_arlen,
      maxigp2_arsize,
      maxigp2_arburst,
      maxigp2_arlock,
      maxigp2_arcache,
      maxigp2_arprot,
      maxigp2_arvalid,
      maxigp2_aruser,
      maxigp2_arready,
      maxigp2_rid,
      maxigp2_rdata,
      maxigp2_rresp,
      maxigp2_rlast,
      maxigp2_rvalid,
      maxigp2_rready,
      maxigp2_awqos,
      maxigp2_arqos,
      pl_resetn0,
      pl_clk0,
      pl_clk1
);

//INPUT AND OUTPUT PORTS

    input maxihpm0_lpd_aclk;
    output [15:0] maxigp2_awid;
    output [39:0] maxigp2_awaddr;
    output [7:0] maxigp2_awlen;
    output [2:0] maxigp2_awsize;
    output [1:0] maxigp2_awburst;
    output maxigp2_awlock;
    output [3:0] maxigp2_awcache;
    output [2:0] maxigp2_awprot;
    output maxigp2_awvalid;
    output [15:0] maxigp2_awuser;
    input maxigp2_awready;
    output [127:0] maxigp2_wdata;
    output [15:0] maxigp2_wstrb;
    output maxigp2_wlast;
    output maxigp2_wvalid;
    input maxigp2_wready;
    input [15:0] maxigp2_bid;
    input [1:0] maxigp2_bresp;
    input maxigp2_bvalid;
    output maxigp2_bready;
    output [15:0] maxigp2_arid;
    output [39:0] maxigp2_araddr;
    output [7:0] maxigp2_arlen;
    output [2:0] maxigp2_arsize;
    output [1:0] maxigp2_arburst;
    output maxigp2_arlock;
    output [3:0] maxigp2_arcache;
    output [2:0] maxigp2_arprot;
    output maxigp2_arvalid;
    output [15:0] maxigp2_aruser;
    input maxigp2_arready;
    input [15:0] maxigp2_rid;
    input [127:0] maxigp2_rdata;
    input [1:0] maxigp2_rresp;
    input maxigp2_rlast;
    input maxigp2_rvalid;
    output maxigp2_rready;
    output [3:0] maxigp2_awqos;
    output [3:0] maxigp2_arqos;
    output pl_resetn0;
    output pl_clk0;
    output pl_clk1;

//REG DECLARATIONS

    reg  [15:0] maxigp2_awid;
    reg  [39:0] maxigp2_awaddr;
    reg  [7:0] maxigp2_awlen;
    reg  [2:0] maxigp2_awsize;
    reg  [1:0] maxigp2_awburst;
    reg  maxigp2_awlock;
    reg  [3:0] maxigp2_awcache;
    reg  [2:0] maxigp2_awprot;
    reg  maxigp2_awvalid;
    reg  [15:0] maxigp2_awuser;
    reg  [127:0] maxigp2_wdata;
    reg  [15:0] maxigp2_wstrb;
    reg  maxigp2_wlast;
    reg  maxigp2_wvalid;
    reg  maxigp2_bready;
    reg  [15:0] maxigp2_arid;
    reg  [39:0] maxigp2_araddr;
    reg  [7:0] maxigp2_arlen;
    reg  [2:0] maxigp2_arsize;
    reg  [1:0] maxigp2_arburst;
    reg  maxigp2_arlock;
    reg  [3:0] maxigp2_arcache;
    reg  [2:0] maxigp2_arprot;
    reg  maxigp2_arvalid;
    reg  [15:0] maxigp2_aruser;
    reg  maxigp2_rready;
    reg  [3:0] maxigp2_awqos;
    reg  [3:0] maxigp2_arqos;
    reg  pl_resetn0;
    reg  pl_clk0;
    reg  pl_clk1;

initial
 begin


   $display("WARNING: Zynq UltraScale IP doesn't support simulation");
     end
endmodule
