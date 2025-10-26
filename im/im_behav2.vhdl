architecture behav2 of im is
  -- convert little-endian to canonical byte order
  function reverse_bytes(v : std_logic_vector) return std_logic_vector is
    constant BYTES: integer := v'length / 8;
    variable res:   std_logic_vector(v'range);
  begin
    for i in 0 to BYTES - 1 loop
      res(8*(i+1)-1 downto 8*i) := v((8*(BYTES-i))-1 downto 8*(BYTES-1-i));
    end loop;
    return res;
  end function reverse_bytes;

  signal instr_lw, instr_hw: std_logic_vector(INSTR_WIDTH-1 downto 0);
begin

  stall <= '0';
  instr_lw <= reverse_bytes(mem_0(to_integer(unsigned(pc(PC_DEPTH+1 downto 2)))));
  instr_hw <= reverse_bytes(mem_0(to_integer(unsigned(pc(PC_DEPTH+1 downto 2))) + 1));
  is_c <= instr_lw(1) nand instr_lw(0) when pc(1) = '0' else instr_lw(17) nand instr_lw(16);
  instr <= instr_lw when pc(1) = '0' else instr_hw(15 downto 0) & instr_lw(31 downto 16);
end architecture behav2;
