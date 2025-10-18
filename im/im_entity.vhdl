library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package im_pkg is
    constant PC_DEPTH:    positive := 10;
    constant INSTR_WIDTH: positive := 32;
    constant ENTRYPOINT:  unsigned := to_unsigned(0, PC_DEPTH+2);

    type mem_0_t is array(0 to 2**PC_DEPTH-1) of std_logic_vector(INSTR_WIDTH-1 downto 0);
    constant mem_0 : mem_0_t := (
        X"93024006", X"13030000", X"B3035300", X"9382F2FF",
        X"B3835300", others => X"13000000"
    );
end im_pkg;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.im_pkg.all;

entity im is
  port( pc:     in  std_logic_vector(PC_DEPTH+1 downto 0);
        instr:  out std_logic_vector(INSTR_WIDTH-1 downto 0));
end entity im;
