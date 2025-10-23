architecture behav of btc is
  signal rdata:   std_logic_vector(INSTR_WIDTH+PC_WIDTH-3 downto 0) := (others => '0');
  signal rpc_reg: std_logic_vector(PC_WIDTH-1 downto 0) := (others => '0');
begin

  cache:
    entity work.dmc
    generic map (
      ADDR_WIDTH => PC_WIDTH-2, K_BIT => K_BIT, OFFS_WIDTH => 0, WORD_WIDTH => INSTR_WIDTH+PC_WIDTH-2)
    port map (
      clk => clk, res_n => res_n, wena => taken, kill => '0', hit => hit,
      raddr => rpc_reg(PC_WIDTH-1 downto 2), waddr => wpc(PC_WIDTH-1 downto 2),
      rdata => rdata, wdata => wtarget(PC_WIDTH-1 downto 2) & winstr);

  rtarget <= rdata(rdata'high downto INSTR_WIDTH) & "00";
  rinstr  <= rdata(INSTR_WIDTH-1 downto 0);
  rpc_reg <= rpc when stall = '0' else rpc_reg;
end architecture behav;
