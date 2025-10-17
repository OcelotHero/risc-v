library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rf_tb is
end entity rf_tb;

architecture behav of rf_tb is
  constant ADDR_WIDTH: positive := 5;
  constant DATA_WIDTH: positive := 32;

  signal clk:       std_logic;
  signal rd_addr:   std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal rs1_addr:  std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal rs2_addr:  std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal rd:        std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
  signal rs1, rs2:  std_logic_vector(DATA_WIDTH-1 downto 0);
begin

  osc:
    entity work.clk_res_gen
    port map(clk => clk);

  dut:
    entity work.rf
    generic map(ADDR_WIDTH => ADDR_WIDTH, DATA_WIDTH => DATA_WIDTH)
    port map( clk => clk, rs1 => rs1, rs2 => rs2, rd => rd, 
              rs1_addr => rs1_addr, rs2_addr => rs2_addr, rd_addr => rd_addr);

  test: process
  begin
    -- check async read of initial values
    for i in 0 to 2**ADDR_WIDTH-1 loop
      rs1_addr <= std_logic_vector(to_unsigned(i, ADDR_WIDTH));
      rs2_addr <= std_logic_vector(to_unsigned(i, ADDR_WIDTH));
      wait for 10 ns;
      assert (or rs1 = '0') report "Initial rs1 not zero" severity error;
      assert (or rs2 = '0') report "Initial rs2 not zero" severity error;
    end loop;

    -- write and read back
    for i in 0 to 5 loop
      rd_addr <= std_logic_vector(to_unsigned(i, ADDR_WIDTH));
      rd <= std_logic_vector(to_unsigned(i*16#1111#, DATA_WIDTH));
      report "Writing " & integer'image(i) & " <= " & integer'image(i*16#1111#);
      wait until rising_edge(clk);
      -- check write by reading back the same register
      rs1_addr <= std_logic_vector(to_unsigned(i, ADDR_WIDTH));
      rs2_addr <= std_logic_vector(to_unsigned(i, ADDR_WIDTH));
      wait for 10 ns;
      assert rs1 = std_logic_vector(to_unsigned(i*16#1111#, DATA_WIDTH)) 
        report "Write/readback failed for rs1" severity error;
      assert rs2 = std_logic_vector(to_unsigned(i*16#1111#, DATA_WIDTH)) 
        report "Write/readback failed for rs2" severity error;
    end loop;

    wait;
  end process;
end architecture behav;
