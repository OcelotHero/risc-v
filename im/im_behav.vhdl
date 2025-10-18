architecture behav of im is
  function reverse_bytes(v : std_logic_vector) return std_logic_vector is
    constant BYTES: integer := v'length / 8;
    variable res:   std_logic_vector(v'range);
  begin
    for i in 0 to BYTES - 1 loop
      res(8*(i+1)-1 downto 8*i) := v((8*(BYTES-i))-1 downto 8*(BYTES-1-i));
    end loop;
    return res;
  end function reverse_bytes;

begin

  -- convert little-endian to canonical byte order
  instr <= reverse_bytes(mem_0(to_integer(unsigned(pc(PC_DEPTH+1 downto 2)))));
end architecture behav;
