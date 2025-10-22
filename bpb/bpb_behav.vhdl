architecture behav of bpb is
  type pred_array is array (0 to 2**K_BIT-1) of std_logic_vector(PRED_WIDTH-1 downto 0);
  signal bpb_mem:   pred_array := (others => (others => '0'));
  signal raddr_reg: std_logic_vector(K_BIT-1 downto 0) := (others => '0');
begin

  prediction: process(raddr_reg, bpb_mem)
  begin
    pred <= bpb_mem(to_integer(unsigned(raddr_reg)))(PRED_WIDTH-1);
  end process;

  update: process(clk)
  begin
    if rising_edge(clk) then
      for i in 0 to PRED_WIDTH-1 loop
        if wena = '1' and bpb_mem(to_integer(unsigned(waddr)))(i) /= taken then
          bpb_mem(to_integer(unsigned(waddr)))(i) <= taken;
          exit;
        end if;
      end loop;
      if stall = '0' then
        raddr_reg <= raddr;
      end if;
    end if;
  end process;
end architecture behav;
