import numpy as np
from fxpmath import Fxp
import os

leading_bit = False
I_range = np.arange(5,20)
bits_range = np.arange(10,35)

for I in I_range:
  for bits in bits_range:
    with open(('log_consts_I_'+str(I)+'_bits_'+str(bits)+'.txt'),'w+',1) as txt:
      for i in range(I):
        x = np.log(1 + np.power(2.0,-i))
        y = Fxp(x, signed=False, n_word=bits, n_frac = bits)
        txt.write('\'b'+('0' if leading_bit else '')+y.bin(frac_dot=leading_bit)+('' if i == I-1  else ',')+'\n')