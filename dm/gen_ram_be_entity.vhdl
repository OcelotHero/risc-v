library ieee;
use ieee.std_logic_1164.all;
library work;

entity gen_ram_be is
  generic(ADDR_WIDTH: positive; NUM_BYTES : positive; BYTE_WIDTH: positive);
  port( clk: in std_logic;
        raddr: in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
        waddr: in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
        wdata: in  std_logic_vector((NUM_BYTES * BYTE_WIDTH) - 1 downto 0);
        be:    in  std_logic_vector(NUM_BYTES - 1 downto 0);
        rdata: out std_logic_vector((NUM_BYTES * BYTE_WIDTH) - 1 downto 0));
end gen_ram_be;
