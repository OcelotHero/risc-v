architecture struct of dm is
  signal raddr, waddr:  std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal rdata, wdata:  std_logic_vector(DATA_WIDTH-1 downto 0);
  signal be:            std_logic_vector((DATA_WIDTH/8)-1 downto 0);
begin

  ctrl:
    entity work.ctrl
    generic map (ADDR_WIDTH => ADDR_WIDTH, DATA_WIDTH => DATA_WIDTH)
    port map (
      addr => addr, n_addr => n_addr,
      sdata => sdata, ldata => ldata,
      raddr => raddr, waddr => waddr, rdata => rdata, wdata => wdata,
      mode => mode, be => be, illegal_mode => illegal_mode);

  bram:
    entity work.gen_ram_be
    generic map (ADDR_WIDTH => ADDR_WIDTH, NUM_BYTES => DATA_WIDTH/8, BYTE_WIDTH => 8)
    port map (
      clk => clk, be => be,
      raddr => raddr, waddr => waddr, rdata => rdata, wdata => wdata);
end architecture struct;
