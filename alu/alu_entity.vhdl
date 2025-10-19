library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
  generic(DATA_WIDTH: positive := 32);
  port( rs1, rs2: in  std_logic_vector(DATA_WIDTH-1 downto 0);
        alu_mode: in  std_logic_vector(3 downto 0);
        rd:       out std_logic_vector(DATA_WIDTH-1 downto 0);
        comp:     out std_logic);
end entity alu;
