library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.im_pkg.all;

entity cpu is
  generic(  DATA_WIDTH : positive := 32; ADDR_WIDTH : positive := 5;
            DM_ADDR_WIDTH : positive := 16;
            K_BIT : positive := 12; PRED_WIDTH : positive := 2);
  port(clk, res_n: in std_logic);
end entity cpu;
