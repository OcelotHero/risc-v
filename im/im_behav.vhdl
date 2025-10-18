architecture behav of im is
begin
  instr <= mem_0(to_integer(unsigned(pc(PC_DEPTH+1 downto 2))));
end architecture behav;
