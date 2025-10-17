architecture struct of dm is
  signal raddr, waddr:  std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal rdata, wdata:  std_logic_vector(DATA_WIDTH-1 downto 0);
  signal be:            std_logic_vector((DATA_WIDTH/8)-1 downto 0);
begin

  ctrl:
    entity work.ctrl
    generic map(ADDR_WIDTH => ADDR_WIDTH, DATA_WIDTH => DATA_WIDTH)
    port map( mem_addr => mem_addr, mem_n_addr => mem_n_addr,
              mem_sdata => mem_sdata, mem_ldata => mem_ldata,
              raddr => raddr, waddr => waddr, rdata => rdata, wdata => wdata,
              mem_mode => mem_mode, be => be, illegal_op => illegal_op);

  bram:
    entity work.gen_ram_be
    generic map(ADDR_WIDTH => ADDR_WIDTH, NUM_BYTES => DATA_WIDTH/8, BYTE_WIDTH => 8)
    port map( clk => clk, be => be,
              raddr => raddr, waddr => waddr, rdata => rdata, wdata => wdata);
end architecture struct;
