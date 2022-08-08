import main_pkg::*;

module log_mac(
  input logic clk,
  input logic rstn,
  input logic clr,
  input logic data_in_valid,
  input logic data_out_enable,
  input logic signed [IN_BITS:0] data_in_x,
  input logic signed [IN_BITS:0] data_in_y,

  input logic data_in_x_nat_sign,
  input logic data_in_y_nat_sign,
  
  output logic data_in_enable,
  output logic data_out_valid,
  output logic signed [OUT_BITS:0] r_accum,
  output logic r_accum_nat_sign
);
  
  parameter bit [OUT_BITS - IN_BITS - 1:0] ZERO_PAD = 0;
  parameter bit [OUT_BITS:0] NEG_MAX = ~0;
  
  logic mul_nat_sign;
  logic signed [IN_BITS:0] mul;
  logic signed [OUT_BITS:0] mul_ext;

  logic signed [OUT_BITS:0] diff;
  logic signed [OUT_BITS:0] diff_log;
  

  logic n_accum_nat_sign;
  logic signed [OUT_BITS:0] n_accum;

  logic update_data_out;
  logic data_out_available;
  logic r_data_out_valid;
  logic n_data_out_valid;
  
  always_comb begin
    data_out_valid = r_data_out_valid;
  end

  always_comb begin
    data_out_available = r_data_out_valid == 0 | data_out_enable == 1;
    data_in_enable = data_out_available;
    update_data_out = data_out_available & data_in_valid;
    if (data_in_valid == 1) begin
      n_data_out_valid = 1;
    end else if (data_out_enable == 1) begin
      n_data_out_valid = 0;
    end else begin
      n_data_out_valid = r_data_out_valid;
    end
  end

generate
  always_comb begin
    
    if(clr == 1) begin
      $display("n_accum clear at %t",$time);
      n_accum = 0;
      n_accum_nat_sign = 0;
    end else begin
      $display("n_accum copy at %t",$time);
      n_accum = r_accum;
      n_accum_nat_sign = r_accum_nat_sign;

    end 
    
    mul_nat_sign = !(data_in_x_nat_sign ^ data_in_y_nat_sign);
    mul = data_in_x + data_in_y;

     
    if(IN_BITS != OUT_BITS) begin
      mul_ext = {mul,ZERO_PAD};
    end else begin
      mul_ext = mul;
    end


    $display("n_accum = %b, mul_ext = %b",n_accum,mul_ext);
    
    if (n_accum < mul_ext)
      diff = mul_ext - n_accum;
    else
      diff = n_accum - mul_ext;
    
    $display("diff = %b",diff);

    
    if(n_accum_nat_sign ^ mul_nat_sign) begin
      $display("diff = %b",diff);

      case (diff)
        `include "GaussLogSubLUT14plus1bit.txt"
      endcase      
      $display("diff_log = %b",diff_log);


      n_accum_nat_sign = !(n_accum < mul_ext);
    end else begin
      $display("diff = %b",diff);

      case (diff)
        `include "GaussLogAddLUT14plus1bit.txt"
      endcase
      $display("diff_log = %b",diff_log);

    end
    

    if (n_accum < mul_ext)
      n_accum = mul_ext + diff_log;
    else
      n_accum = n_accum + diff_log;

  end
endgenerate  
  
  always_ff @(posedge clk or negedge rstn ) begin      
    
    if(rstn == 0) begin
      r_accum <= 0;
      r_accum_nat_sign <= 0;
    end else begin
      if(update_data_out) begin
        r_accum <= n_accum;
        r_accum_nat_sign <= n_accum_nat_sign;
      end
    end
  end
  
  
  always_ff @( posedge clk or negedge rstn ) begin
    if (rstn == 0) begin
      r_data_out_valid <= 0;
    end else begin
      r_data_out_valid <= n_data_out_valid;
    end
  end
  
endmodule
      