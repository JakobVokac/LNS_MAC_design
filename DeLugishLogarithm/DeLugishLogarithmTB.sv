// Code your testbench here
// or browse Examples
// Code your testbench here
// or browse Examples

import DeLugishLogarithm_pkg::*;


module DeLugishLogarithmTB;
   
  logic clk = 0;
  logic rstn;
  logic [X_BITS-1:0] x;
  logic [Y_BITS-1:0] y;
  logic out;
  logic in;
  logic in_en;
  logic out_val;
  
  DeLugishLogarithm dut(
    .clk(clk),
    .rstn(rstn),
    .data_in(x),
    .data_in_valid(in),
    .data_out(y),
    .data_out_enable(out),
    .data_in_enable(in_en),
    .data_out_valid(out_val)
  );
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1);
    rstn = 0;
    in = 0;
    out = 0;
    #10;
    rstn = 1;
    #10;
    x = 'b10011010; //exp 1.601525 => 0111 1000 (10010)
	in = 1;
    #10;
    out = 1;
    #20
    out = 0;

    x = 'b10000000; //exp 1.5 => 0110 0111 (110011001001)
	in = 1;
    #10;
    out = 1;

    #20
    out = 0;

    x = 'b01000000; //exp 1.25 => 0011 1001 (000111111111)
	in = 1;
    #10;
    out = 1;
    
    rstn = 0;
  end
    
    
  always begin
    clk <= ~clk; 
    #5;
  end
  
endmodule