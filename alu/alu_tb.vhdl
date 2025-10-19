library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_tb is
end entity alu_tb;

architecture behav of alu_tb is
  constant DATA_WIDTH: positive := 32;
  signal rs1, rs2:  std_logic_vector(DATA_WIDTH-1 downto 0);
  signal alu_mode:  std_logic_vector(3 downto 0)  := (others => '0');
  signal rd:        std_logic_vector(DATA_WIDTH-1 downto 0);
  signal logical:   std_logic;
begin

  dut:
    entity work.alu
    generic map (DATA_WIDTH => DATA_WIDTH)
    port map (rs1 => rs1, rs2 => rs2, alu_mode => alu_mode, rd => rd, logical => logical);

  test: process
  begin
    rs1 <= x"F000_0011";
    rs2 <= x"0000_0005";

    alu_mode <= "0000"; -- ADD
    wait for 10 ns;
    assert logical = '-' report "comp error" severity error;
    assert rd = x"F000_0016" report "ADD failed" severity error;
    alu_mode <= "1000"; -- SUB
    wait for 10 ns;
    assert logical = '-' report "comp error" severity error;
    assert rd = x"F000_000C" report "SUB failed" severity error;
    rs2 <= x"FFFF_FFFF";
    wait for 10 ns;
    assert logical = '-' report "comp error" severity error;
    assert rd = x"F000_0012" report "SUB failed" severity error;
    rs2 <= x"0000_0005";
    alu_mode <= "0111"; -- AND
    wait for 10 ns;
    assert logical = '-' report "comp error" severity error;
    assert rd = x"0000_0001" report "AND failed" severity error;
    alu_mode <= "0110"; -- OR
    wait for 10 ns;
    assert logical = '-' report "comp error" severity error;
    assert rd = x"F000_0015" report "OR failed" severity error;
    alu_mode <= "0100"; -- XOR
    wait for 10 ns;
    assert logical = '-' report "comp error" severity error;
    assert rd = x"F000_0014" report "XOR failed" severity error;
    alu_mode <= "0001"; -- SLL
    wait for 10 ns;
    assert logical = '-' report "comp error" severity error;
    assert rd = x"0000_0220" report "SLL failed" severity error;
    alu_mode <= "0101"; -- SRL
    wait for 10 ns;
    assert logical = '-' report "comp error" severity error;
    assert rd = x"0780_0000" report "SRL failed" severity error;
    alu_mode <= "1101"; -- SRA
    wait for 10 ns;
    assert logical = '-' report "comp error" severity error;
    assert rd = x"FF80_0000" report "SRA failed" severity error;

    alu_mode <= "0010"; -- SLT
    wait for 10 ns;
    assert logical = '-' report "comp error" severity error;
    assert rd = std_logic_vector(to_unsigned(1, DATA_WIDTH)) report "SLT failed" severity error;
    rs1 <= rs2;
    rs2 <= rs1;
    wait for 10 ns;
    assert logical = '-' report "comp error" severity error;
    assert rd = std_logic_vector(to_unsigned(0, DATA_WIDTH)) report "SLT failed" severity error;

    alu_mode <= "0011"; -- SLTU
    wait for 10 ns;
    assert logical = '-' report "comp error" severity error;
    assert rd = std_logic_vector(to_unsigned(1, DATA_WIDTH)) report "SLTU failed" severity error;
    rs1 <= rs2;
    rs2 <= rs1;
    wait for 10 ns;
    assert logical = '-' report "comp error" severity error;
    assert rd = std_logic_vector(to_unsigned(0, DATA_WIDTH)) report "SLTU failed" severity error;

    alu_mode <= "1001"; -- BEQ
    wait for 10 ns;
    assert logical = '0' report "BEQ error" severity error;
    assert rd = x"----_----" report "undefined failed" severity error;
    rs1 <= x"0000_0005";
    wait for 10 ns;
    assert logical = '1' report "BEQ error" severity error;
    assert rd = x"----_----" report "undefined failed" severity error;
    alu_mode <= "1010"; -- BLT
    wait for 10 ns;
    assert logical = '0' report "BLT error" severity error;
    assert rd = x"----_----" report "undefined failed" severity error;
    rs1 <= x"F000_0011";
    wait for 10 ns;
    assert logical = '1' report "BLT error" severity error;
    assert rd = x"----_----" report "undefined failed" severity error;
    alu_mode <= "1011"; -- BLTU
    wait for 10 ns;
    assert logical = '0' report "BLTU error" severity error;
    assert rd = x"----_----" report "undefined failed" severity error;
    rs1 <= x"0000_0005";
    wait for 10 ns;
    assert logical = '0' report "BLTU error" severity error;
    assert rd = x"----_----" report "undefined failed" severity error;
    alu_mode <= "1100"; -- BNE
    wait for 10 ns;
    assert logical = '0' report "BNE error" severity error;
    assert rd = x"----_----" report "undefined failed" severity error;
    rs1 <= x"F000_0011";
    wait for 10 ns;
    assert logical = '1' report "BNE error" severity error;
    assert rd = x"----_----" report "undefined failed" severity error;
    alu_mode <= "1110"; -- BGE
    wait for 10 ns;
    assert logical = '0' report "BGE error" severity error;
    assert rd = x"----_----" report "undefined failed" severity error;
    rs1 <= x"0000_0005";
    wait for 10 ns;
    assert logical = '1' report "BGE error" severity error;
    assert rd = x"----_----" report "undefined failed" severity error;
    alu_mode <= "1111"; -- BGEU
    wait for 10 ns;
    assert logical = '1' report "BGEU error" severity error;
    assert rd = x"----_----" report "undefined failed" severity error;
    rs1 <= x"F000_0011";
    wait for 10 ns;
    assert logical = '1' report "BGEU error" severity error;
    assert rd = x"----_----" report "undefined failed" severity error;

    wait;
  end process;
end architecture behav;
