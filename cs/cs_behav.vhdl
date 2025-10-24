architecture behav of cs is
  type cs_array is array (0 to 2**STACK_IDX_WIDTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
  signal mem:         cs_array := (others => (others => '0'));
  signal tail, head:  unsigned(STACK_IDX_WIDTH-1 downto 0) := (others => '0');
begin

  update: process(clk, res_n) is
  begin
    if res_n = '0' then
      tail <= (others => '0');
      head <= (others => '0');
      mem <= (others => (others => '0'));
    elsif rising_edge(clk) then
      if clr = '1' then
        head <= tail;
      elsif push = '1' then
        head <= head + 1;
        tail <= tail + 1 when tail = head + 1 else tail;
        mem(to_integer(head)) <= wdata;
      elsif pop = '1' and head /= tail then
        head <= head - 1;
      end if;
    end if;
  end process;

  output:
    rdata <= mem(to_integer(head - 1));
    full  <= '1' when tail = head + 1 else '0';
    empty <= '1' when tail = head else '0';
end architecture behav;
