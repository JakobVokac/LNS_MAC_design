package DeLugishExponentiation_pkg;


parameter X_BITS = 14;
parameter Y_BITS = 14;
parameter I = 14;
parameter E_BITS = Y_BITS + $clog2(I) + 1;
parameter L_BITS = E_BITS;

// log_b(1 + 2 >> n) constants
parameter logic [L_BITS-1:0] LOG_CONST [0:I] = {
  `include "log_consts_I_14_bits_19.txt"
};

parameter int EXP_SIZE [0:I] = {
  `include "E_size_I_14_p_19.txt"
};

endpackage