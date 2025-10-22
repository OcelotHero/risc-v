architecture struct of cpu is
  function add_pc(v: std_logic_vector; offset: positive range 2 to 4) return std_logic_vector is
    constant WIDTH : integer := v'length;
  begin
    return std_logic_vector(to_unsigned(to_integer(unsigned(v))+offset, WIDTH));
  end function add_pc;

  function add_pc(v: std_logic_vector; w: std_logic_vector) return std_logic_vector is
    constant WIDTH : integer := v'length;
  begin
    return std_logic_vector(unsigned(v) + unsigned(w));
  end function add_pc;

  signal pc_if, pc_sel_u, pc_dc, pc_ex:     std_logic_vector(INSTR_WIDTH-1 downto 0);
  signal ir_if_u, ir_sel_if_u, ir_dc:       std_logic_vector(INSTR_WIDTH-1 downto 0);
  signal dbta_ex_u:                         std_logic_vector(INSTR_WIDTH-1 downto 0);
  signal pc_target_if:                      std_logic_vector(INSTR_WIDTH-1 downto 0);
  signal wpc_sel_if_u, wtargetpc_sel_if_u:  std_logic_vector(INSTR_WIDTH-1 downto 0);
  signal rs1_addr_dc_u, rs2_addr_dc_u:      std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal rd_addr_dc_u, rd_addr_ex:          std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal rd_addr_me, rd_addr_wb:            std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal rs1_dc_u, rs1_ex, rs1_sel_ex_u:    std_logic_vector(DATA_WIDTH-1 downto 0);
  signal rs2_dc_u, rs2_ex, rs2_sel_ex_u:    std_logic_vector(DATA_WIDTH-1 downto 0);
  signal rs2_imm_sel_ex_u, alu_out_ex_u:    std_logic_vector(DATA_WIDTH-1 downto 0);
  signal imm_bta_sel_dc_u, imm_bta_ex:      std_logic_vector(DATA_WIDTH-1 downto 0);
  signal imm_dc_u, bta_dc_u:                std_logic_vector(DATA_WIDTH-1 downto 0);
  signal alu_pc_sel_ex_u, alu_out_me:       std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
  signal sdata_me, sdata_sel_me_u:          std_logic_vector(DATA_WIDTH-1 downto 0);
  signal ldata_me, ldata_sel_me_u:          std_logic_vector(DATA_WIDTH-1 downto 0);
  signal mem_out_wb:                        std_logic_vector(DATA_WIDTH-1 downto 0);
  signal alu_mode_dc_u, alu_mode_ex:        std_logic_vector(3 downto 0);
  signal mem_mode_dc_u, mem_mode_ex:        std_logic_vector(3 downto 0);
  signal mem_mode_me:                       std_logic_vector(3 downto 0);
  signal dbpu_mode_dc_u, dbpu_mode_ex:      std_logic_vector(1 downto 0);
  signal fwd_rs1_dc_u, fwd_rs2_dc_u:        std_logic_vector(1 downto 0);
  signal fwd_rs1_ex, fwd_rs2_ex:            std_logic_vector(1 downto 0);
  signal fwd_selsd_dc_u:                    std_logic;
  signal fwd_selsd_ex, fwd_selsd_me:        std_logic;
  signal hit_if, hit_dc, hit_ex:            std_logic := '0';
  signal alu_comp_out_ex_u, sel_pc_ex_u:    std_logic := '0';
  signal pred_dc_u, pred_ex:                std_logic := '0';
  signal imm_to_alu_dc_u, imm_to_alu_ex:    std_logic;
  signal sbta_valid_dc_u, dbta_valid_ex_u:  std_logic;
  signal stall_dc_u, sel_bta_dc_u:          std_logic;
  signal illegal_dc_u, err_align_me_u:      std_logic;

begin

  pc_mux:
    pc_sel_u <= pc_target_if      when hit_if = '1' else
                imm_bta_sel_dc_u  when ((sbta_valid_dc_u and not hit_dc) or pred_dc_u) = '1' else
                dbta_ex_u         when dbta_valid_ex_u else
                add_pc(pc_if, 4);

  reg_if:
    entity work.reg
    generic map (DATA_WIDTH => INSTR_WIDTH, N_REG => 1)
    port map (
      clk => clk, res_n => res_n, stall => stall_dc_u,
      d(0) => pc_sel_u, q(0) => pc_if);

  im_if:
    entity work.im
    port map (pc => pc_if(PC_DEPTH+1 downto 0), instr => ir_if_u);

  ir_mux_if:
    ir_sel_if_u <= x"00000013" when ((sbta_valid_dc_u and not hit_dc) or dbta_valid_ex_u) else ir_if_u;

  btc_if:
    entity work.btc
    generic map (K_BIT => K_BIT, PC_WIDTH => INSTR_WIDTH)
    port map (
      clk => clk, res_n => res_n, stall => stall_dc_u,
      rpc => pc_sel_u, rtarget => pc_target_if, hit => hit_if,
      wpc => wpc_sel_if_u, wtarget => wtargetpc_sel_if_u,
      wena => dbta_valid_ex_u or sbta_valid_dc_u, taken => alu_comp_out_ex_u or sbta_valid_dc_u);

  wpc_mux_if:
    wpc_sel_if_u <= pc_dc when sbta_valid_dc_u else pc_ex;

  wtargetpc_mux_if:
    wtargetpc_sel_if_u <= imm_bta_sel_dc_u when sbta_valid_dc_u else dbta_ex_u;

  reg_dc:
    entity work.reg
    generic map (DATA_WIDTH => INSTR_WIDTH, N_REG => 3)
    port map (
      clk => clk, res_n => res_n, stall => stall_dc_u,
      d(0) => ir_sel_if_u, d(1) => pc_if, d(2) => (31 => hit_if, others => '0'),
      q(0) => ir_dc, q(1) => pc_dc, q(2)(31) => hit_dc);

  dec_dc:
    entity work.dec(behav2)
    generic map (DATA_WIDTH => DATA_WIDTH, ADDR_WIDTH => ADDR_WIDTH)
    port map (
      ir => ir_dc, illegal => illegal_dc_u, stall => stall_dc_u,
      rs1_addr => rs1_addr_dc_u, rs2_addr => rs2_addr_dc_u,
      rd_addr => rd_addr_dc_u, rd_addr_me => rd_addr_me, rd_addr_ex => rd_addr_ex,
      mem_mode => mem_mode_dc_u, mem_mode_ex => mem_mode_ex,
      fwd_rs1 => fwd_rs1_dc_u, fwd_rs2 => fwd_rs2_dc_u, fwd_selsd => fwd_selsd_dc_u,
      alu_mode => alu_mode_dc_u, dbpu_mode => dbpu_mode_dc_u, imm => imm_dc_u,
      imm_to_alu => imm_to_alu_dc_u, sel_bta => sel_bta_dc_u,
      sbta_valid => sbta_valid_dc_u, cancel => dbta_valid_ex_u);

  rf_dc:
    entity work.rf
    generic map (DATA_WIDTH => DATA_WIDTH, ADDR_WIDTH => ADDR_WIDTH)
    port map (
      clk => clk, res_n => res_n,
      rs1_addr => rs1_addr_dc_u, rs2_addr => rs2_addr_dc_u, rd_addr => rd_addr_wb,
      rs1 => rs1_dc_u, rs2 => rs2_dc_u, rd => mem_out_wb);

  imm_bta_mux_dc:
    imm_bta_sel_dc_u <= imm_dc_u when sel_bta_dc_u = '0' else add_pc(imm_dc_u, pc_dc);

  bpb_dc:
    entity work.bpb
    generic map (K_BIT => K_BIT, PRED_WIDTH => PRED_WIDTH)
    port map (
      clk => clk, pred => open,
      raddr => pc_if(K_BIT+1 downto 2), waddr => pc_ex(K_BIT+1 downto 2),
      wena => and (dbpu_mode_ex xnor "10"), taken => alu_comp_out_ex_u);

  reg_ex:
    entity work.reg
    generic map (DATA_WIDTH => INSTR_WIDTH, N_REG => 5)
    port map (
      clk => clk, res_n => res_n,
      d(0) => rs1_dc_u, d(1) => rs2_dc_u, d(2) => imm_bta_sel_dc_u, d(3) => pc_dc,
      d(4) => (31 downto 27 => rd_addr_dc_u, 26 downto 23 => alu_mode_dc_u,
               22 downto 19 => mem_mode_dc_u, 18 downto 17 => dbpu_mode_dc_u,
               16 downto 15 => fwd_rs1_dc_u, 14 downto 13 => fwd_rs2_dc_u,
               12 => fwd_selsd_dc_u, 11 => imm_to_alu_dc_u, 10 => pred_dc_u,
               9 => hit_dc, others => '0'),
      q(0) => rs1_ex, q(1) => rs2_ex, q(2) => imm_bta_ex, q(3) => pc_ex,
      q(4)(31 downto 27) => rd_addr_ex, q(4)(26 downto 23) => alu_mode_ex,
      q(4)(22 downto 19) => mem_mode_ex, q(4)(18 downto 17) => dbpu_mode_ex,
      q(4)(16 downto 15) => fwd_rs1_ex, q(4)(14 downto 13) => fwd_rs2_ex,
      q(4)(12) => fwd_selsd_ex, q(4)(11) => imm_to_alu_ex, q(4)(10) => pred_ex,
      q(4)(9) => hit_ex);

  rs1_mux_ex:
    rs1_sel_ex_u <= alu_out_me when fwd_rs1_ex = "01" else
                    mem_out_wb when fwd_rs1_ex = "10" else
                    rs1_ex;

  rs2_mux_ex:
    rs2_sel_ex_u <= alu_out_me when fwd_rs2_ex = "01" else
                    mem_out_wb when fwd_rs2_ex = "10" else
                    rs2_ex;

  rs2_imm_mux_ex:
    rs2_imm_sel_ex_u <= imm_bta_ex when imm_to_alu_ex = '1' else rs2_sel_ex_u;

  alu_ex:
    entity work.alu
    generic map (DATA_WIDTH => DATA_WIDTH)
    port map (
      alu_mode => alu_mode_ex, rs1 => rs1_sel_ex_u, rs2 => rs2_imm_sel_ex_u,
      rd => alu_out_ex_u, comp => alu_comp_out_ex_u);

  alu_pc_sel_mux_ex:
    alu_pc_sel_ex_u <= alu_out_ex_u when sel_pc_ex_u = '0' else add_pc(pc_ex, 4);

  dbpu_ex:
    entity work.dbpu
    port map (
      mode => dbpu_mode_ex, sbta => imm_bta_ex, dbta => alu_out_ex_u,
      pc_n => add_pc(pc_ex, 4), pc_target => pc_dc,
      hit => hit_ex, comp => alu_comp_out_ex_u,
      valid => dbta_valid_ex_u, sel_link => sel_pc_ex_u, bta => dbta_ex_u);

  reg_me:
    entity work.reg
    generic map (DATA_WIDTH => INSTR_WIDTH, N_REG => 3)
    port map (
      clk => clk, res_n => res_n,
      d(0) => alu_pc_sel_ex_u, d(1) => rs2_sel_ex_u,
      d(2) => (31 downto 27 => rd_addr_ex, 26 downto 23 => mem_mode_ex,
               22 => fwd_selsd_ex, others => '0'),
      q(0) => alu_out_me, q(1) => sdata_me,
      q(2)(31 downto 27) => rd_addr_me, q(2)(26 downto 23) => mem_mode_me,
      q(2)(22) => fwd_selsd_me);

  sdata_mux_me:
    sdata_sel_me_u <= mem_out_wb when fwd_selsd_me = '1' else sdata_me;

  dm_me:
    entity work.dm
    generic map (DATA_WIDTH => DATA_WIDTH, ADDR_WIDTH => DM_ADDR_WIDTH)
    port map (
      clk => clk, mode => mem_mode_me, err_align => err_align_me_u,
      addr => alu_pc_sel_ex_u, n_addr => alu_out_me,
      sdata => sdata_sel_me_u, ldata => ldata_me);

  ldata_mux_me:
    ldata_sel_me_u <= alu_out_me when mem_mode_me(3) = '1' else ldata_me;

  reg_wb:
    entity work.reg
    generic map (DATA_WIDTH => INSTR_WIDTH, N_REG => 2)
    port map (
      clk => clk, res_n => res_n,
      d(0) => ldata_sel_me_u, d(1) => (31 downto 27 => rd_addr_me, others => '0'),
      q(0) => mem_out_wb, q(1)(31 downto 27) => rd_addr_wb);
end architecture struct;
