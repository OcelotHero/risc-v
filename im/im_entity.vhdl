library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package test is
    constant entrypoint : unsigned := 0;
    constant ADDR_WIDTH : positive := 10;

    type mem_0_t is array(0 to 2**ADDR_WIDTH-1) of std_logic_vector(31 downto 0);
    constant mem_0 : mem_0_t := (
        X"93024006", X"13030000", X"b3035300", X"9382f2ff",
        X"b3835300"
    );
end test;

use work.test.all;

entity im is
  port( pc_if:  in  std_logic_vector(ADDR_WIDTH+1 downto 0);
        instr:  out std_logic_vector(31 downto 0));
end entity im;
