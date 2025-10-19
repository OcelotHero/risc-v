library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package im_pkg is
  constant PC_DEPTH:    positive := 10;
  constant INSTR_WIDTH: positive := 32;
  constant ENTRYPOINT:  unsigned := to_unsigned(0, PC_DEPTH+2);

  type mem_0_t is array(0 to 2**PC_DEPTH-1) of std_logic_vector(INSTR_WIDTH-1 downto 0);
  constant mem_0 : mem_0_t := (
      x"9302a000", x"13030000", x"33035300", x"9382f2ff",
      x"e39c02fe", x"b3830200", others => x"13000000"
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
