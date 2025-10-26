architecture struct of interp is
  signal ir_hu, cir:  std_logic_vector(15 downto 0);
  signal ir_exp, fir: std_logic_vector(31 downto 0);
begin

  cir_mux:
    cir <= ir_hu when pc(1) = '1' else ir(15 downto 0);

  fir_mux:
    fir <= ir(15 downto 0) & ir_hu when pc(1) = '1' else ir;

  ir_n_mux:
    ir_n <= ir_exp when is_c = '1' else fir;

  ir_type:
    is_c <= ir_hu(1) nand ir_hu(0) when pc(1) = '1' else ir(1) nand ir(0);

  buff:
    entity work.reg
    generic map (DATA_WIDTH => 16, N_REG => 1)
    port map (
      clk => clk, res_n => res_n, stall => stall,
      d(0) => ir(31 downto 16), q(0) => ir_hu);

  xp:
    entity work.exp
    generic map (XLEN => XLEN)
    port map (cir => cir, ir => ir_exp, illegal => illegal);
end architecture struct;
