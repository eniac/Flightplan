// Testbench for the "drop or not" module.
// Nik Sultana, DCOMP project, UPenn, January 2018

module don_test;

reg clk = 0;
always #1 clk = !clk;

reg rst;

reg don_in_valid;
reg don_in_data;
wire don_out_valid;
wire don_out_data;

drop_or_not_0_t don (
  .clk_lookup(clk),
  .rst(rst),
  .tuple_in_drop_or_not_input_VALID(don_in_valid),
  .tuple_in_drop_or_not_input_DATA(don_in_data),
  .tuple_out_drop_or_not_output_VALID(don_out_valid),
  .tuple_out_drop_or_not_output_DATA(don_out_data));


genvar idx;

initial begin
  $dumpfile("don_test.vcd");
  $dumpvars(0,don_test);

  #4
  rst = 1;
  #1
  rst = 0;
  #6
  don_in_data = 1;
  don_in_valid = 1;
  #1
  don_in_data = 0;
  don_in_valid = 0;
  #1

  don_in_data = 1;
  #1
  don_in_valid = 1;
  #1
  don_in_valid = 0;
  #1
  don_in_data = 0;
  #1

  repeat(20) begin
    don_in_data = 1;
    don_in_valid = 1;
    #1;
    don_in_data = 0;
    don_in_valid = 0;
    #1;
  end

  #5
  $finish;
end

endmodule
