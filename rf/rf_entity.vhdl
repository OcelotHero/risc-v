library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rf is
  generic(DATA_WIDTH: positive := 32; ADDR_WIDTH: positive := 5);
  port( clk, res_n: in  std_logic;
        rd_addr:    in  std_logic_vector(ADDR_WIDTH-1 downto 0);
        rs1_addr:   in  std_logic_vector(ADDR_WIDTH-1 downto 0);
        rs2_addr:   in  std_logic_vector(ADDR_WIDTH-1 downto 0);
        rd:         in  std_logic_vector(DATA_WIDTH-1 downto 0);
        rs1, rs2:   out std_logic_vector(DATA_WIDTH-1 downto 0));
end entity rf;
