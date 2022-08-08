import DeLugishLogarithm_pkg::*;

module DeLugishLogarithm(
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
  logic [L_BITS-1:0] log_var_rounded; 
  logic [L_BITS-1:0] log_var_truncated;
  logic [E_BITS:0] comp_data_in;
  //Used for rounding E to Y_BITS
  parameter bit [Y_BITS:0] zero = 0;
  
  logic r_data_out_valid;
  logic n_data_out_valid;
  logic update_data_out;
  logic data_out_available;

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
      comp_data_in = {'b1, data_in, zero[E_BITS - X_BITS -1:0]};
      log_var[0] = 0;
      exp_var[0] = 0;
      exp_var[0][E_BITS] = 'b1;
      
    end
  end

  //Main algorithm - long indexing code for minimal range necessary for computation at each iteration of the loop


  for (genvar ITER = 1; ITER <= I; ITER = ITER + 1) begin
    logic [E_BITS:E_BITS - EXP_SIZE[ITER]] exp_tmp;
    always_comb begin
      

      if(EXP_SIZE[ITER] - EXP_SIZE[ITER-1] != 0)
        exp_tmp = {exp_var[ITER-1][E_BITS:E_BITS - EXP_SIZE[ITER-1]],zero[((0 > (EXP_SIZE[ITER]-EXP_SIZE[ITER-1]-1)) ? 0 : (EXP_SIZE[ITER]-EXP_SIZE[ITER-1]-1) ):0]} + ({exp_var[ITER-1][E_BITS:E_BITS - EXP_SIZE[ITER-1]],zero[((0 > (EXP_SIZE[ITER]-EXP_SIZE[ITER-1]-1)) ? 0 : (EXP_SIZE[ITER]-EXP_SIZE[ITER-1]-1) ):0]} >> ITER);
      else
        exp_tmp = exp_var[ITER-1] + (exp_var[ITER-1] >> ITER);
      
      if( (comp_data_in[E_BITS:E_BITS - EXP_SIZE[ITER]] >= exp_tmp[E_BITS:E_BITS - EXP_SIZE[ITER]] ) ) begin
        log_var[ITER] = log_var[ITER-1] + LOG_CONST[ITER];

        if(EXP_SIZE[ITER] - EXP_SIZE[ITER-1] != 0)
          exp_var[ITER][E_BITS:E_BITS - EXP_SIZE[ITER]] = exp_tmp[E_BITS:E_BITS - EXP_SIZE[ITER]];
        else
          exp_var[ITER] = exp_tmp;
      end else begin
        if(EXP_SIZE[ITER] - EXP_SIZE[ITER-1] != 0)
          exp_var[ITER][E_BITS:E_BITS - EXP_SIZE[ITER]] = {exp_var[ITER-1][E_BITS:E_BITS - EXP_SIZE[ITER-1]],zero[((0 > (EXP_SIZE[ITER]-EXP_SIZE[ITER-1]-1)) ? 0 : (EXP_SIZE[ITER]-EXP_SIZE[ITER-1]-1) ):0]};
        else
          exp_var[ITER] = exp_var[ITER-1];
        log_var[ITER] = log_var[ITER-1];
      end 
    end
  end
  
  
  
  //Round and truncate E to range of output (y)
  always_comb begin
    log_var_rounded = log_var[I];
    log_var_rounded = ( log_var_rounded + {zero[Y_BITS-1:0],log_var_rounded[L_BITS-Y_BITS-1:0]} );
    log_var_truncated = log_var_rounded[L_BITS-1:L_BITS-Y_BITS];
  end
  

  //Output y if enabled
  always_ff @(posedge clk) begin      
    if(update_data_out) begin
      data_out <= log_var_truncated;
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




  
  