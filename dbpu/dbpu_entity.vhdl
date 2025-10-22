library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dbpu is
  generic(DATA_WIDTH : positive := 32);
  port( sbta, dbta, pc_n: in  std_logic_vector(DATA_WIDTH-1 downto 0);
        pc_target:        in  std_logic_vector(DATA_WIDTH-1 downto 0);
        mode:             in  std_logic_vector(1 downto 0);
        comp, predict:    in  std_logic;
        valid, sel_link:  out std_logic;
        bta:              out std_logic_vector(DATA_WIDTH-1 downto 0));
end entity dbpu;
