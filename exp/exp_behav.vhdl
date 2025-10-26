architecture behav of exp is
begin

  expander: process(cir) is
    variable opcode:  std_logic_vector(1 downto 0);
    variable funct3:  std_logic_vector(2 downto 0);
  begin

    opcode := cir(1 downto 0); funct3 := cir(15 downto 13);

    ir <= x"00000013"; illegal <= '1';

    if opcode = "00" and funct3 = "000" and cir(11 downto 5) /= "0000000" then
      -- CIW-type
      illegal <= '0';
      ir(19 downto 15) <= "00010"; ir(11 downto 7) <= "00" & cir(4 downto 2);
      ir(29 downto 22) <= cir(10 downto 7) & cir(12 downto 11) & cir(5) & cir(6);
    elsif opcode = "00" and funct3(1 downto 0) = "10" then
      -- CL/CS-type
      illegal <= '0'; ir(5 downto 4) <= cir(15) & '0'; ir(14 downto 12) <= "010";
      ir(19 downto 15) <= "00" & cir(9 downto 7); ir(26 downto 25) <= cir(5) & cir(12);
      ir(24 downto 20) <= "00" & cir(4 downto 2) when funct3(2) = '1' else cir(11 downto 10) & cir(6) & "00";
      ir(11 downto 7) <= "00" & cir(4 downto 2) when funct3(2) = '0' else cir(11 downto 10) & cir(6) & "00";
    elsif opcode = "10" and funct3(0) = '0' then
      if funct3(2 downto 1) = "10" and cir(11 downto 7) /= "00000" then
        -- CR-type
        illegal <= '0';
        if cir(6 downto 2) = "00000" then
          -- c.jr/c.jalr
          ir(6 downto 2) <= "11001";
          ir(19 downto 15) <= cir(11 downto 7); ir(7) <= cir(12);
        else
          -- c.mv/c.add
          ir(6 downto 2) <= "01100";
          ir(24 downto 20) <= cir(6 downto 2); ir(11 downto 7) <= cir(11 downto 7);
          ir(19 downto 15) <= cir(11 downto 7) when cir(12) = '1' else "00000";
        end if;
      elsif funct3(2 downto 1) = "11" then
        -- CSS-type
        illegal <= '0'; ir(5 downto 4) <= "10";
        ir(24 downto 20) <= cir(6 downto 2); ir(19 downto 15) <= "00010";
        ir(27 downto 25) <= cir(8 downto 7) & cir(12); ir(11 downto 7) <= cir(11 downto 9) & "00";
      elsif cir(11 downto 7) /= "00000" then
        -- CI-type
        if funct3(1) = '1' then
          -- c.lwsp
          illegal <= '0'; ir(4) <= '0'; ir(14 downto 12) <= "010";
          ir(19 downto 15) <= "00010"; ir(11 downto 7) <= cir(11 downto 7);
          ir(27 downto 22) <= cir(3 downto 2) & cir(12) & cir(6 downto 4);
        elsif funct3(1) = '0' and unsigned(cir(12) & cir(6 downto 2)) < XLEN then
          -- c.slli
          illegal <= '0'; ir(14 downto 12) <= "001";
          ir(19 downto 15) <= cir(11 downto 7); ir(11 downto 7) <= cir(11 downto 7);
          ir(25 downto 20) <= cir(12) & cir(6 downto 2);
        end if;
      end if;
    elsif opcode = "01" then
      if funct3(1 downto 0) = "01" then
        -- CJ-type
        illegal <= '0'; ir(6 downto 2) <= "11011";
        ir(11 downto 7) <= "0000" & not funct3(2);
        ir(30 downto 21) <= cir(8) & cir(10 downto 9) & cir(6) & cir(7) & cir(2) & cir(11) & cir(5 downto 3);
        ir(31) <= cir(12); ir(20 downto 12) <= (others => cir(12));
      elsif funct3(2 downto 1) = "11" then
        -- CB-type (c.beqz/c.bnez)
        illegal <= '0'; ir(6 downto 2) <= "11000"; ir(14 downto 12) <= "00" & funct3(0);
        ir(19 downto 15) <= "00" & cir(9 downto 7);
        ir(27 downto 25) <= cir(6 downto 5) & cir(2); ir(11 downto 8) <= cir(11 downto 10) & cir(4 downto 3);
        ir(31 downto 28) <= (others => cir(12)); ir(7) <= cir(12);
      elsif funct3(2) = '0' then
        -- CI-type
        if cir(14 downto 2) = "0000000000000" then
          -- c.nop
          illegal <= '0';
        elsif cir(11 downto 7) /= "00000" then
          if funct3(0) = '1' and (cir(12) & cir(6 downto 2)) /= "000000" then
            illegal <= '0';
            ir(11 downto 7) <= cir(11 downto 7);
            if cir(11 downto 7) = "00010" then
              -- c.addi16sp
              ir(19 downto 15) <= "00010";
              ir(31 downto 29) <= (others => cir(12)); ir(28 downto 24) <= cir(4 downto 3) & cir(5) & cir(2) & cir(6);
            else
              -- c.lui
              ir(6 downto 2) <= "01101";
              ir(31 downto 17) <= (others => cir(12)); ir(16 downto 12) <= cir(6 downto 2);
            end if;
          elsif (funct3(1) & cir(12) & cir(6 downto 2)) /= "0000000" then
            -- c.addi / c.li
            illegal <= '0';
            ir(19 downto 15) <= cir(11 downto 7) when funct3(1) = '0' else "00000"; ir(11 downto 7) <= cir(11 downto 7);
            ir(31 downto 25) <= (others => cir(12)); ir(24 downto 20) <= cir(6 downto 2);
          end if;
        end if;
      elsif cir(12 downto 10) = "011" then
        -- CA-type
        illegal <= '0'; ir(5) <= '1';
        ir(19 downto 15) <= "00" & cir(9 downto 7); ir(11 downto 7) <= "00" & cir(9 downto 7);
        ir(24 downto 20) <= "00" & cir(4 downto 2);
        ir(30) <= cir(6) nand cir(5); ir(14) <= cir(6) or cir(5); ir(13) <= cir(6); ir(12) <= cir(6) and cir(5);
      elsif cir(11) = '0' and unsigned(cir(12) & cir(6 downto 2)) < XLEN then
        -- CB-type (c.srli/c.srai)
        illegal <= '0'; ir(14 downto 12) <= "101"; ir(30) <= cir(10);
        ir(19 downto 15) <= "00" & cir(9 downto 7); ir(11 downto 7) <= "00" & cir(9 downto 7);
        ir(25 downto 20) <= cir(12) & cir(6 downto 2);
      elsif cir(11 downto 10) = "10" then
        -- CB-type (c.andi)
        illegal <= '0'; ir(14 downto 12) <= "111";
        ir(19 downto 15) <= "00" & cir(9 downto 7); ir(11 downto 7) <= "00" & cir(9 downto 7);
        ir(31 downto 25) <= (others => cir(12)); ir(24 downto 20) <= cir(6 downto 2);
      end if;
    end if;
  end process;
end architecture behav;
