architecture behav of dmc is
  type word_arr is array (0 to 2**OFFS_WIDTH-1) of std_logic_vector(WORD_WIDTH-1 downto 0);
  type entry is record
    valid:  std_logic;
    tag:    std_logic_vector(ADDR_WIDTH-K_BIT-OFFS_WIDTH-1 downto 0);
    data:   word_arr;
  end record;
  type cache_array is array (0 to 2**K_BIT-1) of entry;

  signal cache: cache_array := (others => ('0', (others => '0'), (others => (others => '0'))));
  signal raddr_reg: std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
begin

  fetch: process(raddr_reg, cache)
    variable idx : natural range 0 to 2**K_BIT-1;
    variable offset: natural range 0 to 2**OFFS_WIDTH-1;
  begin
    idx := to_integer(unsigned(raddr_reg(K_BIT+OFFS_WIDTH-1 downto OFFS_WIDTH)));
    offset := 0 when OFFS_WIDTH = 0 else to_integer(unsigned(raddr_reg(OFFS_WIDTH-1 downto 0)));

    rdata <= cache(idx).data(offset);
    hit <= '1' when cache(idx).valid = '1' and
               cache(idx).tag = raddr_reg(ADDR_WIDTH-1 downto K_BIT+OFFS_WIDTH) else '0';
  end process;

  update: process(clk)
    variable idx: natural range 0 to 2**K_BIT-1;
    variable offset: natural range 0 to 2**OFFS_WIDTH-1;
  begin
    if res_n = '0' then
      cache <= (others => ('0', (others => '0'), (others => (others => '0'))));
    elsif rising_edge(clk) then
      idx := to_integer(unsigned(waddr(K_BIT+OFFS_WIDTH-1 downto OFFS_WIDTH)));
      offset := 0 when OFFS_WIDTH = 0 else to_integer(unsigned(waddr(OFFS_WIDTH-1 downto 0)));

      if wena = '1' then
        cache(idx).valid <= not kill;
        if kill = '0' then
          cache(idx).tag          <= waddr(ADDR_WIDTH-1 downto K_BIT+OFFS_WIDTH);
          cache(idx).data(offset) <= wdata;
        end if;
      end if;
      raddr_reg <= raddr;
    end if;
  end process;
end architecture behav;
