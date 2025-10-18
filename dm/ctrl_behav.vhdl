architecture behav of ctrl is
begin

  raddr <= addr(ADDR_WIDTH+1 downto 2);

  codec: process(mode, n_addr, sdata, rdata)
    variable width, factor: natural;
  begin
    ldata <= (others => '0'); illegal_mode <= '0';
    waddr <= (others => '0'); wdata <= (others => '0'); be <= (others => '0');

    if mode(3) = '1' then  -- Write
      if ((unsigned(mode(2 downto 0)) > 2 and mode(2 downto 0) /= "111")
          or (mode(0) and n_addr(0)) = '1' or (mode(1) = '1' and n_addr(1 downto 0) /= "00")) then
        illegal_mode <= '1';
      else
        waddr <= n_addr(ADDR_WIDTH+1 downto 2);
        wdata <= std_logic_vector(shift_left(unsigned(sdata), 8*to_integer(unsigned(n_addr(1 downto 0)))));
        be <= "1111" when mode(1) = '1' else                                                  -- SW
              "0011" when mode(0) = '1' and n_addr(1) = '0' else                              -- SH
              "1100" when mode(0) = '1' and n_addr(1) = '1' else
              std_logic_vector(to_unsigned(2**to_integer(unsigned(n_addr(1 downto 0))), 4));  -- SB
      end if;
    else  -- Read
      if ((unsigned(mode(1 downto 0)) > 2 or mode = "0110")
          or (mode(0) and n_addr(0)) = '1' or (mode(1) = '1' and n_addr(1 downto 0) /= "00")) then
        illegal_mode <= '1';
      else
        width := 16 when mode(0) = '1' else 8;
        factor := to_integer(unsigned(n_addr(1 downto 0)))/2 when mode(0) = '1' else    -- LH
                  to_integer(unsigned(n_addr(1 downto 0)));                             -- LB
        ldata <= rdata when mode(1) = '1' else                                          -- LW
                 (ldata'high downto width => rdata(width*(factor+1)-1) and not mode(2))
                  & rdata(width*(factor+1)-1 downto width*factor);
      end if;
    end if;
  end process codec;
end architecture behav;
