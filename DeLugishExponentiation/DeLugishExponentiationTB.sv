// Code your testbench here
// or browse Examples
// Code your testbench here
// or browse Examples
import DeLugishExponentiation_pkg::*;

module DeLugishExponentiationTB;
  
  logic clk = 0;
  logic rstn;
  logic [X_BITS-1:0] x;
  logic [Y_BITS-1:0] y;
  logic out;
  logic in;
  logic in_en;
  logic out_val;
  
  DeLugishExponentiation dut(
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
    x = 'b10000000; //0.5
	in = 1;
    #10;
    out = 1;
    #20
    out = 0;

    x = 'b01000000; //0.25
	in = 1;
    #10;
    out = 1;

    #20
    out = 0;

    x = 'b00100000; //0.125
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