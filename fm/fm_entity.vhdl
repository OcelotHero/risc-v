library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package fm_pkg is
  type bank_size_array is array(natural range <>) of natural range 0 to 64;
end package fm_pkg;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.fm_pkg.all;

entity fm is
  generic(N_RS_BANK: positive := 2;
          BANK_SIZE: bank_size_array(0 to N_RS_BANK-1) := (10, 6));
  port( clk, res_n:   in  std_logic;
        claim, free:  in  bank_size_array(0 to N_RS_BANK-1);
        empty:        out bank_size_array(0 to N_RS_BANK-1));
end entity fm;
