library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bpb is
  generic(K_BIT: positive := 12; PRED_WIDTH: positive := 2);
  port( clk, stall:   in  std_logic;
        raddr, waddr: in  std_logic_vector(K_BIT-1 downto 0);
        wena, taken:  in  std_logic;
        pred:         out std_logic);
end entity bpb;
