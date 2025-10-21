library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity btc is
  generic(K_BIT: positive := 12; PC_WIDTH: positive := 32);
  port( clk, res_n, stall:  in  std_logic;
        wena, taken:        in  std_logic;
        rpc, wpc:           in  std_logic_vector(PC_WIDTH-1 downto 0);
        wtarget:            in  std_logic_vector(PC_WIDTH-1 downto 0);
        rtarget:            out std_logic_vector(PC_WIDTH-1 downto 0);
        hit:                out std_logic);
end entity btc;
