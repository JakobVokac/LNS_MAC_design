// Code your testbench here
// or browse Examples

import lns_mac_pkg::*;

module lns_mac_tb();
  
  logic test_data_in_valid;
  logic clk;
  logic clr;
  logic rstn;
  logic data_in_valid;
  logic data_out_enable;
  logic signed [IN_BITS:0] data_in_x_arr [0:NUM_DATA_IN - 1];
  logic signed [IN_BITS:0] data_in_y_arr [0:NUM_DATA_IN - 1]; 
  logic signed [IN_BITS:0] data_in_x;
  logic signed [IN_BITS:0] data_in_y;
  logic data_in_x_nat_sign;
  logic data_in_y_nat_sign;
  
  logic data_in_nat;
  logic data_out_nat;

  logic data_in_enable;
  logic data_out_valid;
  logic signed [OUT_BITS:0] data_out;
  logic data_out_nat_sign;
  
  lns_mac dut(
    .clk(clk),
    .clr(clr),
    .rstn(rstn),
    .data_in_valid(data_in_valid),
    .data_out_enable(data_out_enable),
    .data_in_x(data_in_x),
    .data_in_y(data_in_y),
    .data_in_x_nat_sign(data_in_x_nat_sign),
    .data_in_y_nat_sign(data_in_y_nat_sign),


    .data_in_enable(data_in_enable),
    .data_out_valid(data_out_valid),
    .r_accum(data_out),
    .r_accum_nat_sign(data_out_nat_sign)
  );

  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
        
    
    //Initialize dut
    data_in_x_nat_sign = 1;
    data_in_y_nat_sign = 1;

    data_in_valid = 0;
    data_out_enable = 1;
    clr = 0;
    clk = 0;
    rstn = 0;
    
    
    //Set accumulate to 0
    #20
    clr = 1;
    rstn = 1;
    #20;
    clr = 0;
    #20;

    
    //Read input values for dut
    $readmemb("data_in_x.txt",data_in_x_arr);
    $readmemb("data_in_y.txt",data_in_y_arr);
    

    //Accumulate over input
    for(int i = 0; i < 32; i++) begin

      data_in_x = data_in_x_arr[i];
      data_in_y = data_in_y_arr[i];
   	  data_in_valid = 1;

      //Wait for data_out to update and assert correct computation
      wait(data_out_valid == 1);
      assert(data_out == test_accum);
      
      //Wait for dut to reset params (TODO: fix this?)
      wait(clk == 0);
      wait(clk == 1);
      wait(clk == 0);
      wait(clk == 1);
      
    end
   
    
  end

  
  //Simulated MAC for testing
  parameter bit [OUT_BITS - IN_BITS - 1:0] ZERO_PAD = 0;
  parameter bit [OUT_BITS:0] NEG_MAX = ~0;
  logic test_mul_nat_sign;
  logic signed [IN_BITS:0] test_mul;
  logic signed [OUT_BITS:0] test_mul_ext;

  logic signed [OUT_BITS:0] diff;
  logic signed [OUT_BITS:0] diff_log;
  
  logic test_accum_nat_sign;
  logic signed [OUT_BITS:0] test_accum = 'sb000000000;

  
  always_comb begin

    //When data for dut is ready, compute multiply-accumulate to check result of dut
    if(data_in_valid) begin
      test_mul_nat_sign = !(data_in_x_nat_sign ^ data_in_y_nat_sign);
      test_mul = data_in_x + data_in_y;
      test_mul_ext = {test_mul,ZERO_PAD};

      if (test_accum < test_mul_ext)
        diff = test_mul_ext - test_accum;
      else
        diff = test_accum - test_mul_ext;

      if(test_accum_nat_sign ^ test_mul_nat_sign) begin

        case (diff)
          `include "GaussLogSubLUT15plus1bit.txt"
        endcase      


        test_accum_nat_sign = !(test_accum < test_mul_ext);
      end else begin

        case (diff)
          `include "GaussLogAddLUT15plus1bit.txt"
        endcase

      end

      if (test_accum < test_mul_ext)
        test_accum = test_mul_ext + diff_log;
      else
        test_accum = test_accum + diff_log;
      
    end
  end
  
  
  always begin
    clk = ~clk; #5;
  end
  
  
  //When data out is updated reset data_in_valid to void accumulating the same multiply twice
  always @(negedge clk) begin
    if(data_out_valid) begin
      data_in_valid = 0;
    end
  end
  
endmodule