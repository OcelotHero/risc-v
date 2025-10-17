architecture behav of ctrl is
begin
  
  raddr <= mem_addr(ADDR_WIDTH+1 downto 2);

  codec: process(mem_mode, mem_n_addr, mem_sdata, rdata)
    variable width, factor: natural;
  begin
    mem_ldata <= (others => '0'); illegal_op <= '0';
    waddr <= (others => '0'); wdata <= (others => '0'); be <= (others => '0');

    if mem_mode(3) = '1' then  -- Write
      if ((unsigned(mem_mode(2 downto 0)) > 2 and mem_mode(2 downto 0) /= "111")
          or (mem_mode(0) and mem_n_addr(0)) = '1' or (mem_mode(1) = '1' and mem_n_addr(1 downto 0) /= "00")) then
        illegal_op <= '1';
      else
        waddr <= mem_n_addr(ADDR_WIDTH+1 downto 2);
        wdata <= mem_sdata;
        be <= "1111" when mem_mode(1) = '1' else                                                  -- SW
              "0011" when mem_mode(0) = '1' and mem_n_addr(1) = '0' else                          -- SH
              "1100" when mem_mode(0) = '1' and mem_n_addr(1) = '1' else
              std_logic_vector(to_unsigned(2**to_integer(unsigned(mem_n_addr(1 downto 0))), 4));  -- SB
      end if;
    else  -- Read
      if ((unsigned(mem_mode(1 downto 0)) > 2 or mem_mode = "0110")
          or (mem_mode(0) and mem_n_addr(0)) = '1' or (mem_mode(1) = '1' and mem_n_addr(1 downto 0) /= "00")) then
        illegal_op <= '1';
      else
        width := 16 when mem_mode(0) = '1' else 8;
        factor := to_integer(unsigned(mem_n_addr(1 downto 0)))/2 when mem_mode(0) = '1' else        -- LH
                  to_integer(unsigned(mem_n_addr(1 downto 0)));                                     -- LB  
        mem_ldata <= rdata when mem_mode(1) = '1' else                                              -- LW
                     (mem_ldata'high downto width => rdata(width*(factor+1)-1) and not mem_mode(2)) 
                        & rdata(width*(factor+1)-1 downto width*factor);
      end if;
    end if;
  end process codec;
end architecture behav;
