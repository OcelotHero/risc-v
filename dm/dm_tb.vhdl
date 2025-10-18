library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dm_tb is
end entity dm_tb;

architecture behav of dm_tb is
  constant ADDR_WIDTH: integer := 8;
  constant DATA_WIDTH: integer := 32;

  signal mem_addr_ex, mem_addr_me:    std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
  signal mem_sdata_me, mem_ldata_me:  std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
  signal mem_mode_me:                 std_logic_vector(3 downto 0)            := (others => '0');
  signal illegal_op_me_u, clk, res_n: std_logic;
begin

  osc:
    entity work.clk_res_gen
    generic map (T => 10 ns)
    port map (clk => clk, res_n => res_n);

  dut:
    entity work.dm
    generic map (ADDR_WIDTH => ADDR_WIDTH, DATA_WIDTH => DATA_WIDTH)
    port map (
      clk => clk, addr => mem_addr_ex, n_addr => mem_addr_me,
      sdata => mem_sdata_me, ldata => mem_ldata_me,
      mode => mem_mode_me, illegal_mode => illegal_op_me_u);

  test: process
  begin

    mem_addr_ex <= (others => '0'); mem_addr_me <= (others => '0');
    mem_sdata_me <= (others => '0'); mem_mode_me <= (others => '0');
    wait until rising_edge(clk);

    mem_addr_me <= x"00000000";
    mem_sdata_me <= x"DEADBEEF";
    mem_mode_me <= "1010";  -- SW
    wait until rising_edge(clk);

    mem_addr_ex <= x"00000001";
    mem_addr_me <= x"00000000";
    mem_sdata_me <= (others => '0');
    mem_mode_me <= "0100";  -- LBU
    wait until rising_edge(clk);

    mem_addr_ex <= x"00000006";
    mem_addr_me <= x"00000001";
    mem_mode_me <= "0000";  -- LB
    wait until rising_edge(clk);

    mem_addr_ex <= x"00000004";
    mem_addr_me <= x"00000006";
    mem_sdata_me <= x"CAFEBABE";
    mem_mode_me <= "1001";  -- SW
    wait until rising_edge(clk);

    mem_addr_ex <= x"00000004";
    mem_addr_me <= x"00000004";
    mem_mode_me <= "0001";  -- LH
    wait until rising_edge(clk);

    mem_addr_ex <= x"00000005";
    mem_addr_me <= x"00000004";
    mem_mode_me <= "1000";  -- SB
    wait until rising_edge(clk);

    mem_addr_ex <= x"00000004";
    mem_addr_me <= x"00000005";
    mem_mode_me <= "1000";  -- SB
    wait until rising_edge(clk);

    mem_addr_ex <= x"00000004";
    mem_addr_me <= x"00000004";
    mem_mode_me <= "0010";  -- LW
    wait until rising_edge(clk);

    wait;
  end process;
end architecture behav;
