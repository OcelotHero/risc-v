architecture behav of btc is
  type entry is record
    valid:  std_logic;
    tag:    std_logic_vector(PC_WIDTH-K_BIT-3 downto 0);
    target: std_logic_vector(PC_WIDTH-3 downto 0);
  end record;
  type cache_array is array (0 to 2**K_BIT-1) of entry;
  signal btc_mem: cache_array := (others => ('0', (others => '0'), (others => '0')));
  signal rpc_reg: std_logic_vector(PC_WIDTH-1 downto 0) := (others => '0');
begin

  fetch: process(rpc_reg, btc_mem)
    variable idx : natural range 0 to 2**K_BIT-1;
  begin
    idx := to_integer(unsigned(rpc_reg(K_BIT+1 downto 2)));
    rtarget <= btc_mem(idx).target & "00";
    hit <= '1' when btc_mem(idx).valid = '1' and
                btc_mem(idx).tag = rpc_reg(PC_WIDTH-1 downto K_BIT+2) else '0';
  end process;

  update: process(clk)
    variable idx: natural range 0 to 2**K_BIT-1;
  begin
    if res_n = '0' then
      btc_mem <= (others => ('0', (others => '0'), (others => '0')));
    elsif rising_edge(clk) then
      if wena = '1' then
        idx := to_integer(unsigned(wpc(K_BIT+1 downto 2)));
        btc_mem(idx).valid  <= taken;
        if taken = '1' then
          btc_mem(idx).tag    <= wpc(PC_WIDTH-1 downto K_BIT+2);
          btc_mem(idx).target <= wtarget(PC_WIDTH-1 downto 2);
        end if;
      end if;
      if stall = '0' then
        rpc_reg <= rpc;
      end if;
    end if;
  end process;
end architecture behav;
