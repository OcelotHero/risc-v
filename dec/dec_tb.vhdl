library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dec_tb is
end entity dec_tb;

architecture behav of dec_tb is
  constant DATA_WIDTH: positive := 32;
  constant ADDR_WIDTH: positive := 5;
  signal ir_dc:                         std_logic_vector(31 downto 0);
  signal rd_addr_me, rd_addr_ex:        std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal mem_mode_ex:                   std_logic_vector(3 downto 0);
  signal fwd_rs1_dc_u, fwd_rs2_dc_u:    std_logic_vector(1 downto 0);
  signal fwd_selsd_dc_u:                std_logic;
  signal rs1_addr_dc_u, rs2_addr_dc_u:  std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal rd_addr_dc_u:                  std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal imm_dc_u:                      std_logic_vector(DATA_WIDTH-1 downto 0);
  signal alu_mode_dc_u:                 std_logic_vector(3 downto 0);
  signal mem_mode_dc_u:                 std_logic_vector(3 downto 0);
  signal dtba_valid_ex_u:               std_logic;
  signal imm_to_alu_dc_u, sel_bta_dc_u: std_logic;
  signal sbta_valid_dc_u, stall_dc_u:   std_logic; 
  signal illegal_dc_u:                  std_logic;
begin
  
  dut:
    entity work.dec(behav)
      generic map(DATA_WIDTH => DATA_WIDTH, ADDR_WIDTH => ADDR_WIDTH)
      port map( ir => ir_dc, 
                rd_addr_me => rd_addr_me, rd_addr_ex => rd_addr_ex,
                mem_mode_ex => mem_mode_ex, dtba_valid => dtba_valid_ex_u,
                fwd_rs1 => fwd_rs1_dc_u, fwd_rs2 => fwd_rs2_dc_u, fwd_selsd => fwd_selsd_dc_u,
                rs1_addr => rs1_addr_dc_u, rs2_addr => rs2_addr_dc_u, rd_addr => rd_addr_dc_u,
                imm => imm_dc_u,
                alu_mode => alu_mode_dc_u, mem_mode => mem_mode_dc_u,
                imm_to_alu => imm_to_alu_dc_u, sel_bta => sel_bta_dc_u,
                sbta_valid => sbta_valid_dc_u, stall => stall_dc_u,
                illegal => illegal_dc_u);

  test:
    process is
  begin

    rd_addr_me <= (others => '0'); rd_addr_ex <= (others => '0');
    mem_mode_ex <= (others => '0'); dtba_valid_ex_u <= '0';

    -- R-type ADD
    ir_dc <= "0000000" & "00010" & "00011" & "000" & "00001" & "0110011"; -- ADD x1, x2, x3
    wait for 10 ns;
    assert alu_mode_dc_u = "0000" report "R-type ADD: alu_mode incorrect" severity error;
    assert rs1_addr_dc_u = "00011" report "R-type ADD: rs1_addr incorrect" severity error;
    assert rs2_addr_dc_u = "00010" report "R-type ADD: rs2_addr incorrect" severity error;
    assert rd_addr_dc_u = "00001" report "R-type ADD: rd_addr incorrect" severity error;
    assert unsigned(imm_dc_u) = 0 report "R-type ADD: imm incorrect" severity error;
    assert mem_mode_dc_u = "1111" report "R-type ADD: mem_mode incorrect" severity error;
    assert imm_to_alu_dc_u = '0' report "R-type ADD: imm_to_alu incorrect" severity error;
    assert sel_bta_dc_u = '0' report "R-type ADD: sel_bta incorrect" severity error;
    assert illegal_dc_u = '0' report "R-type ADD: illegal incorrect" severity error;

    ir_dc <= "0000000" & "00110" & "01010" & "000" & "00011" & "0110011"; -- ADD x3, x10, x6
    wait for 10 ns;
    assert alu_mode_dc_u = "0000" report "R-type ADD: alu_mode incorrect" severity error;
    assert rs1_addr_dc_u = "01010" report "R-type ADD: rs1_addr incorrect" severity error;
    assert rs2_addr_dc_u = "00110" report "R-type ADD: rs2_addr incorrect" severity error;
    assert rd_addr_dc_u = "00011" report "R-type ADD: rd_addr incorrect" severity error;
    assert unsigned(imm_dc_u) = 0 report "R-type ADD: imm incorrect" severity error;
    assert mem_mode_dc_u = "1111" report "R-type ADD: mem_mode incorrect" severity error;
    assert imm_to_alu_dc_u = '0' report "R-type ADD: imm_to_alu incorrect" severity error;
    assert sel_bta_dc_u = '0' report "R-type ADD: sel_bta incorrect" severity error;
    assert illegal_dc_u = '0' report "R-type ADD: illegal incorrect" severity error;

    wait;
  end process;
end architecture behav;
