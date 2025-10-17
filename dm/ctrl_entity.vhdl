library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ctrl is
  generic(ADDR_WIDTH: positive := 16; DATA_WIDTH: positive := 32);
  port( mem_addr, mem_n_addr: in  std_logic_vector(DATA_WIDTH-1 downto 0);
        mem_mode:             in  std_logic_vector(3 downto 0);
        mem_sdata:            in  std_logic_vector(DATA_WIDTH-1 downto 0);
        mem_ldata:            out std_logic_vector(DATA_WIDTH-1 downto 0);
        raddr, waddr:         out std_logic_vector(ADDR_WIDTH-1 downto 0);
        be:                   out std_logic_vector((DATA_WIDTH/8)-1 downto 0);
        wdata:                out std_logic_vector(DATA_WIDTH-1 downto 0);
        rdata:                in  std_logic_vector(DATA_WIDTH-1 downto 0);
        illegal_op:           out std_logic);
end entity ctrl;
