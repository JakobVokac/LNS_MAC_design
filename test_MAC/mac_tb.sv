// Code your testbench here
// or browse Examples

  
module mac_tb();
  
  logic clk = 0;
  logic clr;
  logic rstn;
  logic data_in_valid;
  logic data_out_enable;

  logic signed [14:0] data_in_x;
  logic signed [14:0] data_in_y;

  
  logic data_in_nat;
  logic data_out_nat;

  logic data_in_enable;
  logic data_out_valid;
  logic signed [14:0] data_out;
  
  mac dut(
    .clk(clk),
    .clr(clr),
    .rstn(rstn),
    .data_in_valid(data_in_valid),
    .data_out_enable(data_out_enable),
    .data_in_x(data_in_x),
    .data_in_y(data_in_y),


    .data_in_enable(data_in_enable),
    .data_out_valid(data_out_valid),
    .r_accum(data_out)

  );

  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
        
    
 
    data_in_valid = 0;
    data_out_enable = 1;
    clr = 0;
    rstn = 0;
    
    
    //Set accumulate to 0
    #20
    clr = 1;
    rstn = 1;
    #20;
    clr = 0;
    #20;

  end

  
  always begin
    clk = ~clk;
    #5;
  end
  
endmodule