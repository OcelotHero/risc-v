architecture behav of im is
begin
  instr <= mem_0(to_integer(unsigned(pc_if(ADDR_WIDTH+1 downto 2))));
end architecture behav;
