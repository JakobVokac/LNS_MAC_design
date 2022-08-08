// Code your design here
parameter IN_BITS = 14;
parameter OUT_BITS = IN_BITS;

module mac(
  input logic clk,
  input logic rstn,
  input logic clr,
  input logic data_in_valid,
  input logic data_out_enable,
  input logic signed [IN_BITS:0] data_in_x,
  input logic signed [IN_BITS:0] data_in_y,
  
  output logic data_in_enable,
  output logic data_out_valid,
  output logic signed [OUT_BITS:0] r_accum
);
  logic n_data_out_valid;
  logic r_data_out_valid;
  logic data_out_available;
  logic update_data_out;
  
  logic signed [OUT_BITS:0] n_accum;

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
  
  always_comb begin
    if(data_in_valid) begin
      if(clr == 1) begin
        n_accum = 0;
      end else begin
        n_accum = r_accum;
      end
      
      n_accum = n_accum + data_in_x * data_in_y;
    end
  end
  
  always_ff @(posedge clk or negedge rstn ) begin      
    
    if(rstn == 0) begin
      r_accum <= 0;
    end else begin
      if(update_data_out) begin
        r_accum <= n_accum;
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