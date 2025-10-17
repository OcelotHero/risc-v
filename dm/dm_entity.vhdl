library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dm is
  generic(ADDR_WIDTH : positive := 16; DATA_WIDTH : positive := 32);
  port( clk:                  in  std_logic;
        mem_mode:             in  std_logic_vector(3 downto 0);
        mem_addr, mem_n_addr: in  std_logic_vector(DATA_WIDTH-1 downto 0);
        mem_sdata:            in  std_logic_vector(DATA_WIDTH-1 downto 0);
        mem_ldata:            out std_logic_vector(DATA_WIDTH-1 downto 0);
        illegal_op:           out std_logic);
end entity dm;
