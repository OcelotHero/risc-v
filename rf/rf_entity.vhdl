library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package rf_pkg is
  type rf_io_array is array (positive range <>) of std_logic_vector;
end package rf_pkg;

entity rf is
  generic(DATA_WIDTH: positive := 32;
          N_REG_ENTRY: positive := 32; N_ROB_ENTRY: positive := 24;
          N_COMMIT: positive := 6; N_ACCESS: positive := 4);
  constant REG_ADDR_WIDTH: positive := integer(ceil(log2(real(N_REG_ENTRY))));
  constant ROB_ADDR_WIDTH: positive := integer(ceil(log2(real(N_ROB_ENTRY))));
  port( clk, res_n: in  std_logic;
        caddr:      in  rf_io_array(0 to N_COMMIT-1)(REG_ADDR_WIDTH-1 downto 0);
        cdata:      in  rf_io_array(0 to N_COMMIT-1)(DATA_WIDTH-1 downto 0);
        ctag:       in  rf_io_array(0 to N_COMMIT-1)(ROB_ADDR_WIDTH-1 downto 0);
        daddr:      in  rf_io_array(0 to N_ACCESS-1)(REG_ADDR_WIDTH-1 downto 0);
        dtag:       in  rf_io_array(0 to N_ACCESS-1)(ROB_ADDR_WIDTH-1 downto 0);
        saddr:      in  rf_io_array(0 to 2*N_ACCESS-1)(REG_ADDR_WIDTH-1 downto 0);
        svalid:     out rf_io_array(0 to 2*N_ACCESS-1)(0 downto 0);
        sdata:      out rf_io_array(0 to 2*N_ACCESS-1)(DATA_WIDTH-1 downto 0));
end entity rf;
