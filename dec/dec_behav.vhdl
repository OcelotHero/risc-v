architecture behav of dec is
begin

  fwd_rs1(0) <= '1' when rd_addr_ex /= "00000" and rd_addr_ex = ir(19 downto 15) else '0';
  fwd_rs1(1) <= '1' when rd_addr_me /= "00000" and rd_addr_me = ir(19 downto 15) else '0';
  fwd_rs2(0) <= '1' when rd_addr_ex /= "00000" and rd_addr_ex = ir(24 downto 20) else '0';
  fwd_rs2(1) <= '1' when rd_addr_me /= "00000" and rd_addr_me = ir(24 downto 20) else '0';
  fwd_selsd <= '1' when ir(6 downto 0) = "0100011" and mem_mode_ex(2) = '0'
                and rd_addr_ex /= "00000" and rd_addr_ex = ir(24 downto 20) else '0';

  decode: process(ir, rd_addr_ex, mem_mode_ex)
  -- process(ir, rd_addr_ex, rd_addr_me, mem_mode_ex)
    variable opcode: std_logic_vector(6 downto 0);
    variable funct3: std_logic_vector(2 downto 0);
    variable funct7: std_logic_vector(6 downto 0);
  begin

    opcode := ir(6 downto 0); funct3 := ir(14 downto 12); funct7 := ir(31 downto 25);

    rs1_addr <= (others => '0'); rs2_addr <= (others => '0'); rd_addr <= (others => '0');
    imm <= (others => '0'); alu_mode <= (others => '0'); mem_mode <= (others => '1');
    imm_to_alu <= '0'; sel_bta <= '0'; sbta_valid <= '0'; stall <= '0'; illegal <= '0';

    if (mem_mode_ex(3) = '0' and rd_addr_ex /= "00000"                              -- RAL hazard
        and (rd_addr_ex = ir(19 downto 15) or rd_addr_ex = ir(24 downto 20))) then
      stall <= '1'; imm_to_alu <= '1';
    elsif opcode = "0010111" or opcode = "0110111" then
      -- U-type
      rd_addr  <= ir(11 downto 7); imm_to_alu <= '1'; sel_bta <= not opcode(5);
      imm <= ir(31 downto 12) & (11 downto 0 => '0');
    elsif opcode = "1101111" then
      -- J-type
      rd_addr  <= ir(11 downto 7); sel_bta <= '1';
      imm <= (imm'high downto 20 => ir(31)) & ir(19 downto 12) & ir(20) & ir(30 downto 21) & '0';
    elsif opcode = "1100011" and signed(funct3) < 2 then
      -- B-type
      rs1_addr <= ir(19 downto 15); rs2_addr <= ir(24 downto 20); sel_bta <= '1';
      imm <= (imm'high downto 12 => ir(31)) & ir(7) & ir(30 downto 25) & ir(11 downto 8) & '0';
      -- alu_mode <= "111" & funct3(0) when unsigned(funct3) < 2 else
      --             std_logic_vector(to_unsigned(unsigned(funct3)+5, 4));
      alu_mode <= "1001" when funct3 = "000" else "1" & std_logic_vector(rotate_right(unsigned(funct3), 1));
      -- fwd_rs1(0) <= '1' when rd_addr_ex /= "00000" and rd_addr_ex = ir(19 downto 15) else '0';
      -- fwd_rs1(1) <= '1' when rd_addr_me /= "00000" and rd_addr_me = ir(19 downto 15) else '0';
      -- fwd_rs2(0) <= '1' when rd_addr_ex /= "00000" and rd_addr_ex = ir(24 downto 20) else '0';
      -- fwd_rs2(1) <= '1' when rd_addr_me /= "00000" and rd_addr_me = ir(24 downto 20) else '0';
    elsif opcode = "0110011" and (funct7 = "0000000" or (funct7 = "0100000" and (funct3 = "000" or funct3 = "101"))) then
      -- R-type
      rs1_addr <= ir(19 downto 15); rs2_addr <= ir(24 downto 20); rd_addr <= ir(11 downto 7);
      alu_mode <= ir(30) & ir(14 downto 12);
      -- fwd_rs1(0) <= '1' when rd_addr_ex /= "00000" and rd_addr_ex = ir(19 downto 15) else '0';
      -- fwd_rs1(1) <= '1' when rd_addr_me /= "00000" and rd_addr_me = ir(19 downto 15) else '0';
      -- fwd_rs2(0) <= '1' when rd_addr_ex /= "00000" and rd_addr_ex = ir(24 downto 20) else '0';
      -- fwd_rs2(1) <= '1' when rd_addr_me /= "00000" and rd_addr_me = ir(24 downto 20) else '0';
    elsif (opcode = "0010011" and (funct3(1 downto 0) /= "01" or (unsigned(ir(26 downto 20)) < DATA_WIDTH
           and (funct7(6 downto 2) = "00000" or (funct3(2) = '1' and funct7(6 downto 2) = "01000")))))
      or (opcode = "0000011" and (unsigned(funct3(1 downto 0)) < 2 or funct3 = "010"))
      or (opcode = "1100111" and funct3 = "000") then
      -- I-type
      rs1_addr <= ir(19 downto 15); rd_addr <= ir(11 downto 7); imm_to_alu <= '1';
      imm <= (imm'high downto 7 => '0') & ir(26 downto 20) when opcode(4) = '1' and funct3(1 downto 0) = "01" else
             (imm'high downto 11 => ir(31)) & ir(30 downto 20);
      alu_mode <= (others => '0') when opcode(4) = '0' else
                  funct7(5) & funct3 when funct3(1 downto 0) = "01" else '0' & funct3;
      mem_mode <= '0' & funct3 when opcode = "0000011" else (others => '1');
      -- fwd_rs1(0) <= '1' when rd_addr_ex /= "00000" and rd_addr_ex = ir(19 downto 15) else '0';
      -- fwd_rs1(1) <= '1' when rd_addr_me /= "00000" and rd_addr_me = ir(19 downto 15) else '0';
    elsif opcode = "0100011" and unsigned(funct3) < 3 then
      -- S-type
      rs1_addr <= ir(19 downto 15); rs2_addr <= ir(24 downto 20); imm_to_alu <= '1';
      imm <= (imm'high downto 11 => ir(31)) & ir(30 downto 25) & ir(11 downto 7);
      mem_mode <= '1' & funct3;
      -- fwd_rs1(0) <= '1' when rd_addr_ex /= "00000" and rd_addr_ex = ir(19 downto 15) else '0';
      -- fwd_rs1(1) <= '1' when rd_addr_me /= "00000" and rd_addr_me = ir(19 downto 15) else '0';
      -- fwd_rs2(0) <= '1' when rd_addr_ex /= "00000" and rd_addr_ex = ir(24 downto 20) else '0';
      -- fwd_rs2(1) <= '1' when rd_addr_me /= "00000" and rd_addr_me = ir(24 downto 20) else '0';
      -- fwd_selsd <= '1' when mem_mode_ex(2) = '0' and rd_addr_ex /= "00000" and rd_addr_ex = ir(24 downto 20) else '0';
    else
      illegal <= '1';
    end if;
  end process decode;
end architecture behav;
