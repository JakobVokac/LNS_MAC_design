import main_pkg::*;

parameter NUM_DATA_IN = 32;
module main_tb();
  
  logic clk;
  logic clr;
  logic rstn;
  logic data_in_valid;
  logic data_out_enable;
  logic signed [IN_BITS:0] data_in_x_arr [NUM_DATA_IN];
  logic signed [IN_BITS:0] data_in_y_arr [NUM_DATA_IN]; 
//   logic signed data_in_x_arr [NUM_DATA_IN] = {
//    'sb001000000,
//    'sb001100000,
//    'sb000100000,
//    'sb000110000
//   };
//   logic signed [IN_BITS:0] data_in_y_arr [NUM_DATA_IN] = {
//    'sb01001000,
//    'sb01010000,
//    'sb01011000,
//    'sb01100000
//   };
  logic signed [IN_BITS:0] data_in_x;
  logic signed [IN_BITS:0] data_in_y;
  logic data_in_x_nat_sign;
  logic data_in_y_nat_sign;
  
  logic data_in_nat;
  logic data_out_nat;

  logic data_in_enable;
  logic data_out_valid;
  logic signed [OUT_BITS:0] data_out;

  main dut(
    .clk(clk),
    .clr(clr),
    .rstn(rstn),
    .data_in_valid(data_in_valid),
    .data_out_enable(data_out_enable),
    .data_in_x(data_in_x),
    .data_in_y(data_in_y),
    .data_in_x_nat_sign(data_in_x_nat_sign),
    .data_in_y_nat_sign(data_in_y_nat_sign),

    .data_in_nat(data_in_nat),
    .data_out_nat(data_out_nat),

    .data_in_enable(data_in_enable),
    .data_out_valid(data_out_valid),
    .data_out(data_out)
  );

  initial begin
        
    
    data_in_nat = 1;
    data_out_nat = 1;

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
    $readmemb("data_in_x.txt",data_in_x_arr);
    $readmemb("data_in_y.txt",data_in_y_arr);
    

    //Accumulate over input
    for(int i = 0; i < NUM_DATA_IN; i++) begin

      data_in_x = data_in_x_arr[i];
      data_in_y = data_in_y_arr[i];
   	  data_in_valid = 1;

      //Wait for data_out to update and assert correct computation
      wait(clk == 0);
      wait(data_out_valid == 1);

      $display("Data_out: %b", data_out);
      
      //Wait for dut to reset params (TODO: fix this?)
      wait(clk == 0);
      wait(clk == 1);

      
    end
  end
  
  always @(negedge clk) begin
    if(data_out_valid) begin
      data_in_valid = 0;
    end
  end
  
  always begin
    clk = ~clk; #5;
  end
endmodule