architecture behav of rf is
  type ram_entry is record
    valid: std_logic;
    data: std_logic_vector(DATA_WIDTH-1 downto 0);
    tag:  std_logic_vector(ROB_ADDR_WIDTH-1 downto 0);
  end record ram_entry;
  type ram_array is array (0 to 2**REG_ADDR_WIDTH-1) of ram_entry;

  signal ram: ram_array := (others => ('0', (others => '0'), (others => '0')));
begin

  write_reset: process(clk) is
    constant index: natural range 0 to 2**REG_ADDR_WIDTH-1 := 0;
  begin
    if res_n = '0' then
      ram <= (others => ('0', (others => '0'), (others => '0')));
    elsif rising_edge(clk) then

      for i in 0 to N_COMMIT-1 loop
        if (or caddr(i)) /= '0' then
          index := to_integer(unsigned(caddr(i)));
          ram(index).valid  <= '1' when ram(index).tag = ctag(i) else '0';
          ram(index).data   <= cdata(i);
        end if;
      end loop;

      for i in 0 to N_ACCESS-1 loop
        if (or daddr(i)) /= '0' then
          index := to_integer(unsigned(daddr(i)));
          ram(index).valid  <= '0';
          ram(index).tag    <= dtag(i);
        end if;
      end loop;
    end if;
  end process write_reset;

  read: for i in 0 to 2*N_ACCESS-1 generate
    signal index: natural range 0 to 2**REG_ADDR_WIDTH-1 := to_integer(unsigned(saddr(i)));
  begin
    svalid(i) <= ram(index).valid;
    sdata(i) <= ram(index).data when ram(index).valid = '1' else resize(ram(index).tag, DATA_WIDTH);
  end generate read;
end architecture behav;
