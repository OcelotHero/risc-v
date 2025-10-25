library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity exp is
  generic(XLEN : positive := 32);
  port( cir:      in  std_logic_vector(15 downto 0);
        ir:       out std_logic_vector(31 downto 0);
        illegal:  out std_logic);
end entity exp;
