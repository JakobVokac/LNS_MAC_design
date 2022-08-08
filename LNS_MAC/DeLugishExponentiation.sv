import main_pkg::*;

module DeLugishExp(
  input logic clk,
  input logic rstn,
  input logic data_in_valid,
  output logic data_in_enable,
  output logic data_out_valid,
  input logic data_out_enable,
  input logic [X_BITS-1:0] data_in,
  output logic [Y_BITS-1:0] data_out
);
  //Main variables, E has 1 more bit right now (1.0 added to the fractional bits)
  logic [L_BITS-1:0] log_var [I+1];
  logic [E_BITS:0] exp_var [I+1]; 
  logic [E_BITS:0] exp_var_rounded; 
  logic [E_BITS:0] exp_var_truncated;
  logic r_data_out_valid;
  logic n_data_out_valid;
  logic update_data_out;
  logic data_out_available;
  //Used for rounding E to Y_BITS
  parameter bit [Y_BITS:0] zero = 0;
  
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

  //Load in input
  always_comb begin
    if (data_in_enable) begin
      log_var[0] = 0;
      log_var[0][L_BITS-1:L_BITS-X_BITS] = data_in;
      exp_var[0] = 0;
      exp_var[0][E_BITS] = 'b1;
    end
  end

  //Main algorithm - long indexing code for minimal range necessary for computation at each iteration of the loop
  
  genvar ITER;
  generate
  for (ITER = 1; ITER <= I; ITER = ITER + 1) begin
    
    localparam LOG_VAR_SIZE = (L_BITS - 1 - ((0 > (ITER-2)) ? 0 : (ITER-2)));
      
    
    always_comb begin

      // if L_n >= log(1+2^{-n})
      if(!(log_var[ITER-1][LOG_VAR_SIZE:0] < LOG_CONST[ITER][LOG_VAR_SIZE:0])) begin
        
        
        // L_n = L_{n-1} - log(1+2^{-n})
        log_var[ITER][LOG_VAR_SIZE:0] = log_var[ITER-1][LOG_VAR_SIZE:0] - LOG_CONST[ITER][LOG_VAR_SIZE:0];
        
        // E_n = E_{n-1}(1 + 2^{-n})
        if(EXP_SIZE[ITER] - EXP_SIZE[ITER-1] != 0) begin
          automatic logic [EXP_SIZE[ITER]:0] exp_tmp = {exp_var[ITER-1][E_BITS:E_BITS - EXP_SIZE[ITER-1]],zero[(0 > (EXP_SIZE[ITER]-EXP_SIZE[ITER-1]-1) ? 0 : (EXP_SIZE[ITER]-EXP_SIZE[ITER-1]-1)):0]};
          exp_var[ITER][E_BITS:E_BITS - EXP_SIZE[ITER]] = exp_tmp + ( exp_tmp >> ITER );
        end else
          exp_var[ITER] = exp_var[ITER-1] + (exp_var[ITER-1] >> ITER);
      
        
      end else begin
        
        
        // L_n = L_{n-1}
        log_var[ITER][LOG_VAR_SIZE:0] = log_var[ITER-1][LOG_VAR_SIZE:0];
        
        // E_n = E_{n-1}
        if(EXP_SIZE[ITER] - EXP_SIZE[ITER-1] != 0)
          exp_var[ITER][E_BITS:E_BITS - EXP_SIZE[ITER]] = {exp_var[ITER-1][E_BITS:E_BITS - EXP_SIZE[ITER-1]],zero[((0 > (EXP_SIZE[ITER]-EXP_SIZE[ITER-1]-1)) ? 0 : (EXP_SIZE[ITER]-EXP_SIZE[ITER-1]-1)):0]};
        else
          exp_var[ITER] = exp_var[ITER-1];
        
        
      end
    end
    
  end
  endgenerate
    
  
  
  
  //Round and truncate E to range of output (y)
  always_comb begin
    exp_var_rounded = ( exp_var[I] + {zero,exp_var[I][E_BITS-Y_BITS-1:0]} );
    exp_var_truncated = exp_var_rounded[E_BITS-1:E_BITS-Y_BITS];
  end
  
  
  //Output y if enabled
  always_ff @(posedge clk) begin      
    if(update_data_out) begin
      data_out <= exp_var_truncated;
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




  
  