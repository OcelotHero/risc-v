library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package rob_pkg is
  type rob_io_array is array (positive range <>) of std_logic_vector;
end package rob_pkg;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.rob_pkg.all;

entity rob is
  generic(DATA_WIDTH: positive := 32;
          N_REG_ENTRY: positive := 32; N_ROB_ENTRY: positive := 24;
          N_WRITE: positive := 4; N_COMMIT: positive := 6; N_ACCESS: positive := 4;
          REG_ADDR_WIDTH: positive := integer(ceil(log2(real(N_REG_ENTRY))));
          ROB_ADDR_WIDTH: positive := integer(ceil(log2(real(N_ROB_ENTRY)))));
  port( clk, res_n: in  std_logic;
        -- CDB ports
        waddr:      in  rob_io_array(0 to N_WRITE-1)(ROB_ADDR_WIDTH-1 downto 0);
        wdata:      in  rob_io_array(0 to N_WRITE-1)(DATA_WIDTH-1 downto 0);
        -- Reserve ports
        rtreg:      in  rob_io_array(0 to N_ACCESS-1)(REG_ADDR_WIDTH-1 downto 0);
        rdata:      in  rob_io_array(0 to N_ACCESS-1)(DATA_WIDTH-1 downto 0);
        rtype:      in  rob_io_array(0 to N_ACCESS-1)(1 downto 0);
        claim:      in  natural;
        -- Forwarding ports
        faddr:      in  rob_io_array(0 to 2*N_ACCESS-1)(ROB_ADDR_WIDTH-1 downto 0);
        fvalid:     out rob_io_array(0 to 2*N_ACCESS-1)(0 downto 0);
        fdata:      out rob_io_array(0 to 2*N_ACCESS-1)(DATA_WIDTH-1 downto 0);
        -- Commit ports
        ctreg:      out rob_io_array(0 to N_COMMIT-1)(REG_ADDR_WIDTH-1 downto 0);
        cdata:      out rob_io_array(0 to N_COMMIT-1)(DATA_WIDTH-1 downto 0);
        ctag:       out rob_io_array(0 to N_COMMIT-1)(ROB_ADDR_WIDTH-1 downto 0);
        -- Status ports
        head:       out natural;
        tail:       out natural;
        empty:      out natural);
end entity rob;
