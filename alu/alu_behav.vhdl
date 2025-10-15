architecture behav of alu is
begin
  rd <= rs1 and rs2 when alu_mode = "0111" else -- AND
        rs1 or  rs2 when alu_mode = "0110" else -- OR
        rs1 xor rs2 when alu_mode = "0100" else -- XOR
        std_logic_vector(unsigned(rs1) + unsigned(rs2)) when alu_mode = "0000" else   -- ADD
        std_logic_vector(unsigned(rs1) - unsigned(rs2)) when alu_mode = "1000" else   -- SUB
        std_logic_vector( shift_left(unsigned(rs1), to_integer(unsigned(rs2)))) when alu_mode = "0001" else -- SLL
        std_logic_vector(shift_right(unsigned(rs1), to_integer(unsigned(rs2)))) when alu_mode = "0101" else -- SRL
        std_logic_vector(shift_right(  signed(rs1), to_integer(unsigned(rs2)))) when alu_mode = "1101" else -- SRA
        (0 => '1', others => '0') when alu_mode = "0010" and   signed(rs1) <   signed(rs2) else -- SLT
        (0 => '1', others => '0') when alu_mode = "0011" and unsigned(rs1) < unsigned(rs2) else -- SLTU
        (others => '0') when alu_mode = "0010" or alu_mode = "0011" else
        (others => '-');  -- undefined
  logical <=  '1' when alu_mode = "1001" and rs1  = rs2 else  -- BEQ
              '1' when alu_mode = "1100" and rs1 /= rs2 else  -- BNE
              '1' when alu_mode = "1010" and   signed(rs1) <    signed(rs2) else  -- BLT
              '1' when alu_mode = "1011" and unsigned(rs1) <  unsigned(rs2) else  -- BLTU
              '1' when alu_mode = "1110" and   signed(rs1) >=   signed(rs2) else  -- BGE
              '1' when alu_mode = "1111" and unsigned(rs1) >= unsigned(rs2) else  -- BGEU
              '0' when unsigned(alu_mode) > 8 and alu_mode /= "1101" else
              '-';  -- undefined
end architecture behav;
