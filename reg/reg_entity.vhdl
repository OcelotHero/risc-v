library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package reg_pkg is
  type data_array is array (natural range <>) of std_logic_vector;
end package reg_pkg;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.reg_pkg.all;

entity reg is
  generic(DATA_WIDTH: positive := 32; N_REG: positive := 1);
  port( clk, res_n: in  std_logic;
        stall:      in  std_logic := '0';
        d:          in  data_array(0 to N_REG-1)(DATA_WIDTH-1 downto 0);
        q:          out data_array(0 to N_REG-1)(DATA_WIDTH-1 downto 0) := (others => (others => '0')));
end entity reg;
