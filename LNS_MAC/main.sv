import main_pkg::*;

module main(
  input logic clk,
  input logic rstn,
  input logic clr,
  input logic data_in_valid,
  input logic data_out_enable,
  input logic signed [IN_BITS:0] data_in_x,
  input logic signed [IN_BITS:0] data_in_y,
  input logic data_in_x_nat_sign,
  input logic data_in_y_nat_sign,
  
  input logic data_in_nat,
  input logic data_out_nat,

  output logic data_in_enable,
  output logic data_out_valid,
  output logic signed [OUT_BITS:0] data_out
);
  parameter bit [OUT_BITS:0] NEG_MAX = ~0;
  parameter bit [OUT_BITS-1:0] zero = 0;
  
  logic [IN_BITS:0] mac_data_in_x;
  logic [IN_BITS:0] mac_data_in_y;
  logic [OUT_BITS:0] mac_data_out;
  logic [OUT_BITS:0] signed_mac_data_out;
  
  logic update_data_out;
  logic data_out_available;
  logic r_data_out_valid;
  logic n_data_out_valid;
  logic data_out_right_format;
  
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
  
  logic [IN_BITS-1:0] logx_data_out;
  logic logx_data_in_valid;
  logic logx_data_out_enable;
  
  logic logx_data_in_enable;
  logic logx_data_out_valid; 
  DeLugishLog log_x(
    .clk(clk),
    .rstn(rstn),
    .data_in(data_in_x[IN_BITS-1:0]),
    .data_in_valid(logx_data_in_valid),
    .data_out(logx_data_out),
    .data_out_enable(logx_data_out_enable),
    .data_in_enable(logx_data_in_enable),
    .data_out_valid(logx_data_out_valid)
  );
  
  logic [IN_BITS-1:0] logy_data_out;
  logic logy_data_in_valid;
  logic logy_data_out_enable;
  
  logic logy_data_in_enable;
  logic logy_data_out_valid; 
  DeLugishLog log_y(
    .clk(clk),
    .rstn(rstn),
    .data_in(data_in_y[IN_BITS-1:0]),
    .data_in_valid(logy_data_in_valid),
    .data_out(logy_data_out),
    .data_out_enable(logy_data_out_enable),
    .data_in_enable(logy_data_in_enable),
    .data_out_valid(logy_data_out_valid)
  );
  
  logic mac_data_in_x_nat_sign;
  logic mac_data_in_y_nat_sign;
  logic mac_data_out_nat_sign;
  
  logic mac_data_in_valid;
  logic mac_data_out_enable;
  
  logic mac_data_in_enable;
  logic mac_data_out_valid;
  logic mac_clr;
  log_mac mac(
    .clk(clk),
    .rstn(rstn),
    .clr(mac_clr),
    .data_in_valid(mac_data_in_valid),
    .data_out_enable(mac_data_out_enable),
    .data_in_x(mac_data_in_x),
    .data_in_y(mac_data_in_y),

    .data_in_x_nat_sign(mac_data_in_x_nat_sign),
    .data_in_y_nat_sign(mac_data_in_y_nat_sign),
  
    .data_in_enable(mac_data_in_enable),
    .data_out_valid(mac_data_out_valid),
    .r_accum(mac_data_out),
    .r_accum_nat_sign(mac_data_out_nat_sign)
  );
  
  logic exp_data_in_valid;
  logic exp_data_in_enable;
  logic exp_data_out_valid;
  logic exp_data_out_enable;
  
  logic [OUT_BITS-1:0] exp_data_in;
  logic [OUT_BITS-1:0] exp_data_out;
  
  DeLugishExp exp_out(
    .clk(clk),
    .rstn(rstn),
    .data_in_valid(exp_data_in_valid),
    .data_in_enable(exp_data_in_enable),
    .data_out_valid(exp_data_out_valid),
    .data_out_enable(exp_data_out_enable),
    .data_in(exp_data_in),
    .data_out(exp_data_out)
  );
  
  parameter bit SIGN_PAD = 'b0;
  
  always_comb begin
    if(data_in_nat) begin
      mac_data_in_x_nat_sign = data_in_x[IN_BITS];
      mac_data_in_y_nat_sign = data_in_y[IN_BITS];
      mac_data_in_x = {SIGN_PAD,logx_data_out[IN_BITS-1:0]};
      mac_data_in_y = {SIGN_PAD,logy_data_out[IN_BITS-1:0]};
    end else begin
      mac_data_in_x_nat_sign = data_in_x_nat_sign;
      mac_data_in_y_nat_sign = data_in_y_nat_sign;
      mac_data_in_x = data_in_x;
      mac_data_in_y = data_in_y;
    end 
  end
  
  always_comb begin 
    logx_data_out_enable = data_in_nat;
    logy_data_out_enable = data_in_nat;
  end
  
  always_comb begin
    if(data_in_enable & data_in_valid) begin
      if (data_in_nat == 0) begin
        mac_data_in_valid = 1;
      end else begin
        logx_data_in_valid = 1;
        logy_data_in_valid = 1;
        mac_data_in_valid = (logx_data_out_valid & logy_data_out_valid);
      end
    end else begin
      mac_data_in_valid = 0;
    end
  end
  
  always_comb begin
    if(data_out_nat) begin
      if(mac_data_out_valid) begin
        exp_data_in = mac_data_out;
        exp_data_in_valid = 1;
      end else begin
        exp_data_in_valid = 0;
      end
    end else begin
      if(mac_data_out_valid) begin
        if(mac_data_out_nat_sign == 0) begin
          signed_mac_data_out = NEG_MAX;
        end else begin
          signed_mac_data_out = mac_data_out;
        end
      end
    end
  end
  
  always_comb begin
    if(data_out_nat) begin
      exp_data_out_enable = data_out_enable;
    end 
    mac_data_out_enable = data_out_enable;
    mac_clr = clr;
  end
  
  always_ff @(posedge clk) begin      
    if(update_data_out) begin
      data_out <= signed_mac_data_out;
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
      