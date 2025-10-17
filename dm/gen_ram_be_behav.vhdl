library ieee;
use ieee.numeric_std.all;

architecture behav of gen_ram_be is  
  type word_type is array (0 to NUM_BYTES - 1) of std_logic_vector(BYTE_WIDTH - 1 downto 0);
  type ram_type is array (0 to 2 ** ADDR_WIDTH - 1) of word_type;

  signal ram       : ram_type := (others => (others => (others => '0')));
  signal rdata_int : word_type;
  signal raddr_reg : std_logic_vector(ADDR_WIDTH - 1 downto 0);
begin 
  
	ram_read_p: process(ram, raddr_reg) is
	begin
	  for i in 0 to NUM_BYTES - 1 loop 
      rdata(BYTE_WIDTH * (i + 1) - 1 downto BYTE_WIDTH * i) <= ram(to_integer(unsigned(raddr_reg)))(i);  
	  end loop;
  end process;
    
  ram_write_p: process(clk) is
  begin
    if clk'event and clk = '1' then 
      for i in NUM_BYTES - 1 downto 0 loop
        if be(i) = '1' then
          ram(to_integer(unsigned(waddr)))(i) <= wdata(((i + 1) * BYTE_WIDTH - 1) downto i * BYTE_WIDTH);
        end if;
      end loop;
    raddr_reg <= raddr;
    end if;
  end process ram_write_p; 
end behav;
