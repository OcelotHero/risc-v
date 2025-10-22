library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package im_pkg is
  constant PC_DEPTH:    positive := 10;
  constant INSTR_WIDTH: positive := 32;
  constant ENTRYPOINT:  unsigned := to_unsigned(0, PC_DEPTH+2);

  type mem_0_t is array(0 to 2**PC_DEPTH-1) of std_logic_vector(INSTR_WIDTH-1 downto 0);
  constant mem_0 : mem_0_t := (
      x"9302a000", x"13030000", x"33035300", x"9382f2ff", --- sum10
      x"e39c02fe", x"9302a300", x"b3836200",
      -- x"17450000", x"13050500", x"ef00c000", x"1305a000", --- array_sum
      -- x"6f00c002", x"93020000", x"03230500", x"1303f3ff",
      -- x"634a0300", x"83234500", x"b3827200", x"13054500",
      -- x"6ff0dffe", x"13850200", x"67800000", x"13000000",
      -- x"17450000", x"13050500", x"ef008001", x"17450000", --- array_sum2
      -- x"1305c500", x"ef00c000", x"1305a000", x"6f00c002",
      -- x"93020000", x"03230500", x"1303f3ff", x"634a0300",
      -- x"83234500", x"b3827200", x"13054500", x"6ff0dffe",
      -- x"13850200", x"67800000", x"13000000",
      others => x"13000000"
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
