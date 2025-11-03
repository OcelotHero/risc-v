architecture behav of rob is
  type rob_state is (PENDING, MISSPRED, EXCEPTION, COMPLETE);
  type rob_entry is record
    store:  std_logic;
    jump:   std_logic;
    treg:   std_logic_vector(REG_ADDR_WIDTH-1 downto 0);
    data:   std_logic_vector(DATA_WIDTH-1 downto 0);
    state:  rob_state;
  end record rob_entry;
  type rob_mem_array is array (positive range <>) of rob_entry;

  signal rob_mem: rob_mem_array(0 to N_ROB_ENTRY-1);
  signal head, tail:  natural range 0 to N_ROB_ENTRY-1 := 0;
  signal claimed: natural range 0 to N_ACCESS-1 := 0;
begin

  assert N_REG <= 2**REG_ADDR_WIDTH
    report "ROB entity generic N_REG_ENTRY exceeds addressable range"
    severity failure;

  assert N_ROB_ENTRY <= 2**ROB_ADDR_WIDTH
    report "ROB entity generic N_ROB_ENTRY exceeds addressable range"
    severity failure;

  commit: process(rob_mem) is
    variable index: natural range 0 to N_ROB_ENTRY-1 := tail;
  begin
    for i in 0 to N_COMMIT-1 loop
      ctreg(i) <= (others => '0'); cdata(i) <= (others => '0'); ctag(i)  <= (others => '0');
      if rob_mem(index).state = COMPLETE then
        ctreg(i) <= rob_mem(index).treg;
        cdata(i) <= rob_mem(index).data;
        ctag(i)  <= std_logic_vector(to_unsigned(index, ROB_ADDR_WIDTH));
        index := (index + 1) mod N_ROB_ENTRY;
      elsif rob_mem(index).state /= PENDING then
        head <= index; claimed <= 0;
        -- Rollback logic on mispredicted jump/exception
        exit;
      end if;
    end loop;
    tail <= index;
  end process commit;

  write_reset: process(clk, res_n)
    variable index: natural range 0 to N_ROB_ENTRY-1 := 0;
    variable to_claim: natural range 0 to N_ACCESS-1 := claimed;
  begin
    if res_n = '0' then
      rob_mem <= (others => ('0', '0', (others => '0'), (others => '0'), (others => '0')));
      head <= 0; tail <= 0; claimed <= 0;
    elsif rising_edge(clk) then
      -- Writeback from CDB
      for i in 0 to N_WRITE-1 loop
        index := to_integer(unsigned(waddr(i)));
        -- Ignore spurious writebacks
        if rob_mem(index).state /= PENDING then next; end if;

        rob_mem(index).data  <= wdata(i);
        rob_mem(index).state <= MISSPRED when rob_mem(index).jump = '1' and rob_mem(index).data /= wdata(i) else
                                COMPLETE;
      end loop;

      -- Reserve entries
      index := head;
      for i in 0 to claim-1 loop
        if i > empty then exit; end if;
        rob_mem(index).store <= rtype(to_claim)(1);
        rob_mem(index).jump  <= rtype(to_claim)(0);
        rob_mem(index).treg  <= rtreg(to_claim);
        rob_mem(index).data  <= rdata(to_claim);
        rob_mem(index).state <= PENDING;
        index := (index + 1) mod N_ROB_ENTRY;
        to_claim := (to_claim + 1) mod N_ACCESS;
      end loop;
      head <= index;
      claimed <= to_claim;
    end if;
  end process write_reset;

  forward: for i in 0 to 2*N_READ-1 generate
    signal index: natural range 0 to 2**REG_ADDR_WIDTH-1 := to_integer(unsigned(faddr(i)));
  begin
    fvalid(i) <= '1' when rob_mem(index).state = COMPLETE else '0';
    fdata(i) <= rob_mem(index).data when rob_mem(index).state = COMPLETE else (others => '0');
  end generate forward;

  empty <= tail - head when head < tail else tail - head + N_ROB_ENTRY;
end architecture behav;
