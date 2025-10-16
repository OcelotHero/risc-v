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
    entity work.dec(behav2)
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
    procedure assert_signals(
      instr: in string; alu_mode: in std_logic_vector(3 downto 0); mem_mode: in std_logic_vector(3 downto 0);
      rs1_addr: in natural; rs2_addr: in natural; rd_addr: in natural; imm: in std_logic_vector(DATA_WIDTH-1 downto 0);
      imm_to_alu: in std_logic; sel_bta: in std_logic; illegal: in std_logic) is
    begin
      assert alu_mode_dc_u = alu_mode report instr & ": alu_mode incorrect" severity error;
      assert unsigned(rs1_addr_dc_u) = rs1_addr report instr & ": rs1_addr incorrect" severity error;
      assert unsigned(rs2_addr_dc_u) = rs2_addr report instr & ": rs2_addr incorrect" severity error;
      assert unsigned(rd_addr_dc_u) = rd_addr report instr & ": rd_addr incorrect" severity error;
      assert imm_dc_u = imm report instr & ": imm incorrect" severity error;
      assert mem_mode_dc_u = mem_mode report instr & ": mem_mode incorrect" severity error;
      assert imm_to_alu_dc_u = imm_to_alu report instr & ": imm_to_alu incorrect" severity error;
      assert sel_bta_dc_u = sel_bta report instr & ": sel_bta incorrect" severity error;
      assert illegal_dc_u = illegal report instr & ": illegal incorrect" severity error;
    end procedure assert_signals;
    variable imm: std_logic_vector(DATA_WIDTH-1 downto 0);
  begin
    -- Initialize inputs
    rd_addr_me <= (others => '0'); rd_addr_ex <= (others => '0');
    mem_mode_ex <= (others => '0'); dtba_valid_ex_u <= '0';

    -- Valid instructions check
    ir_dc <= (others => '0');
    imm := (others => '0');
    for i in 0 to 2**7-1 loop
      ir_dc(6 downto 0) <= std_logic_vector(to_unsigned(i, 7));
      wait for 10 ps;
      if (i = 2#0110111# or i = 2#0010111# or i = 2#1101111# or i = 2#1100011# or i = 2#0110011#
          or i = 2#0000011# or i = 2#0010011# or i = 2#1100111# or i = 2#0100011#) then
        assert illegal_dc_u = '0' report "Opcode=" & to_string(to_unsigned(i, 7)) & ": illegal incorrectly set" severity error;
      else
        assert_signals("Opcode=" & to_string(to_unsigned(i, 7)), "0000", "1111", 0, 0, 0, imm, '0', '0', '1');
      end if;
    end loop;

    ---------------- U-type
    ir_dc(6 downto 0) <= "0110111"; -- LUI
    wait for 10 ps;
    assert_signals("U-type LUI", "0000", "1111", 0, 0, 0, imm, '1', '0', '0');

    imm := (others => '0');
    for i in 1 to 2**20-1 loop
      ir_dc(31 downto 12) <= std_logic_vector(to_unsigned(i, 20));
      imm(31 downto 12) := std_logic_vector(to_unsigned(i, 20));
      wait for 10 ps;
      assert_signals("U-type LUI", "0000", "1111", 0, 0, 0, imm, '1', '0', '0');
    end loop;

    ir_dc(31 downto 12) <= (others => '0');
    imm := (others => '0');
    for i in 1 to 31 loop
      ir_dc(11 downto 7) <= std_logic_vector(to_unsigned(i, 5));
      wait for 10 ps;
      assert_signals("U-type LUI", "0000", "1111", 0, 0, i, imm, '1', '0', '0');
    end loop;

    ir_dc <= (others => '0');
    ir_dc(6 downto 0) <= "0010111"; -- AUIPC
    wait for 10 ps;
    assert_signals("U-type AUIPC", "0000", "1111", 0, 0, 0, imm, '1', '1', '0');

    imm := (others => '0');
    for i in 1 to 2**20-1 loop
      ir_dc(31 downto 12) <= std_logic_vector(to_unsigned(i, 20));
      wait for 10 ps;
      imm(31 downto 12) := std_logic_vector(to_unsigned(i, 20));
      assert_signals("U-type AUIPC", "0000", "1111", 0, 0, 0, imm, '1', '1', '0');
    end loop;

    ir_dc(31 downto 12) <= (others => '0');
    imm := (others => '0');
    for i in 1 to 31 loop
      ir_dc(11 downto 7) <= std_logic_vector(to_unsigned(i, 5));
      wait for 10 ps;
      assert_signals("U-type AUIPC", "0000", "1111", 0, 0, i, imm, '1', '1', '0');
    end loop;

    ---------------- J-type
    ir_dc <= (others => '0');
    ir_dc(6 downto 0) <= "1101111"; -- JAL
    wait for 10 ps;
    assert_signals("J-type JAL", "0000", "1111", 0, 0, 0, imm, '0', '1', '0');

    for i in 1 to 2**20-1 loop
      ir_dc(31 downto 12) <= std_logic_vector(to_unsigned(i, 20));
      wait for 10 ps;
      imm := (others => ir_dc(31));
      imm(10 downto 1) := ir_dc(30 downto 21);
      imm(11) := ir_dc(20);
      imm(19 downto 12) := ir_dc(19 downto 12);
      imm(0) := '0';
      assert_signals("J-type JAL", "0000", "1111", 0, 0, 0, imm, '0', '1', '0');
    end loop;

    ir_dc(31 downto 12) <= (others => '0');
    imm := (others => '0');
    for i in 1 to 31 loop
      ir_dc(11 downto 7) <= std_logic_vector(to_unsigned(i, 5));
      wait for 10 ps;
      assert_signals("J-type JAL", "0000", "1111", 0, 0, i, imm, '0', '1', '0');
    end loop;

    ---------------- B-type
    ir_dc <= (others => '0');
    ir_dc(6 downto 0) <= "1100011";
    wait for 10 ps;
    assert_signals("B-type", "1001", "1111", 0, 0, 0, imm, '0', '1', '0');

    for i in 1 to 2**12-1 loop
      imm := std_logic_vector(to_unsigned(i, 32));
      ir_dc(31 downto 25) <= imm(11 downto 5);
      ir_dc(11 downto 7) <= imm(4 downto 0);
      wait for 10 ps;
      imm := (others => ir_dc(31));
      imm(11) := ir_dc(7);
      imm(10 downto 5) := ir_dc(30 downto 25);
      imm(4 downto 1) := ir_dc(11 downto 8);
      imm(0) := '0';
      assert_signals("B-type", "1001", "1111", 0, 0, 0, imm, '0', '1', '0');
    end loop;

    ir_dc(31 downto 25) <= (others => '0');
    ir_dc(11 downto 7) <= (others => '0');
    imm := (others => '0');
    for i in 1 to 7 loop
      ir_dc(14 downto 12) <= std_logic_vector(to_unsigned(i, 3));
      wait for 10 ps;
      if i = 2 or i = 3 then
        assert_signals("B-type", "0000", "1111", 0, 0, 0, imm, '0', '0', '1');
      else
        assert_signals("B-type", '1' & ir_dc(12) & ir_dc(14 downto 13), "1111", 0, 0, 0, imm, '0', '1', '0');
      end if;
    end loop;

    ir_dc(14 downto 12) <= (others => '0');
    for i in 1 to 31 loop
      ir_dc(19 downto 15) <= std_logic_vector(to_unsigned(i, 5));
      ir_dc(24 downto 20) <= std_logic_vector(to_unsigned(31-i, 5));
      wait for 10 ps;
      assert_signals("B-type", "1001", "1111", i, 31-i, 0, imm, '0', '1', '0');
    end loop;

    ---------------- S-type
    ir_dc <= (others => '0');
    ir_dc(6 downto 0) <= "0100011";
    wait for 10 ps;
    assert_signals("S-type", "0000", "1000", 0, 0, 0, imm, '1', '0', '0');

    for i in 1 to 7 loop
      ir_dc(14 downto 12) <= std_logic_vector(to_unsigned(i, 3));
      wait for 10 ps;
      if i = 1 or i = 2 then
        assert_signals("S-type", "0000", "1" & std_logic_vector(to_unsigned(i, 3)), 0, 0, 0, imm, '1', '0', '0');
      else
        assert_signals("S-type", "0000", "1111", 0, 0, 0, imm, '0', '0', '1');
      end if;
    end loop;

    ir_dc(14 downto 12) <= (others => '0');
    for i in 1 to 2**12-1 loop
      imm := std_logic_vector(to_unsigned(i, 32));
      ir_dc(31 downto 25) <= imm(11 downto 5);
      ir_dc(11 downto 7) <= imm(4 downto 0);
      wait for 10 ps;
      imm(imm'high downto 12) := (others => ir_dc(31));
      assert_signals("S-type", "0000", "1000", 0, 0, 0, imm, '1', '0', '0');
    end loop;

    ir_dc(31 downto 25) <= (others => '0');
    ir_dc(11 downto 7) <= (others => '0');
    imm := (others => '0');
    for i in 1 to 31 loop
      ir_dc(19 downto 15) <= std_logic_vector(to_unsigned(i, 5));
      ir_dc(24 downto 20) <= std_logic_vector(to_unsigned(31-i, 5));
      wait for 10 ps;
      assert_signals("S-type", "0000", "1000", i, 31-i, 0, imm, '1', '0', '0');
    end loop;

    ---------------- R-type
    ir_dc <= (others => '0');
    ir_dc(6 downto 0) <= "0110011";
    wait for 10 ps;
    assert_signals("R-type", "0000", "1111", 0, 0, 0, imm, '0', '0', '0');

    for i in 1 to 31 loop
      ir_dc(19 downto 15) <= std_logic_vector(to_unsigned(i, 5));
      ir_dc(24 downto 20) <= std_logic_vector(to_unsigned(31-i, 5));
      wait for 10 ps;
      assert_signals("R-type", "0000", "1111", i, 31-i, 0, imm, '0', '0', '0');
    end loop;

    ir_dc(19 downto 15) <= (others => '0');
    ir_dc(24 downto 20) <= (others => '0');
    for i in 1 to 31 loop
      ir_dc(11 downto 7) <= std_logic_vector(to_unsigned(i, 5));
      wait for 10 ps;
      assert_signals("R-type", "0000", "1111", 0, 0, i, imm, '0', '0', '0');
    end loop;

    ir_dc(11 downto 7) <= (others => '0');
    for i in 1 to 7 loop
      ir_dc(14 downto 12) <= std_logic_vector(to_unsigned(i, 3));
      wait for 10 ps;
      assert_signals("R-type", "0" & ir_dc(14 downto 12), "1111", 0, 0, 0, imm, '0', '0', '0');
    end loop;

    ir_dc(14 downto 12) <= (others => '0');
    ir_dc(30) <= '1';
    for i in 0 to 7 loop
      ir_dc(14 downto 12) <= std_logic_vector(to_unsigned(i, 3));
      wait for 10 ps;
      if i = 0 or i = 5 then
        assert_signals("R-type", "1" & ir_dc(14 downto 12), "1111", 0, 0, 0, imm, '0', '0', '0');
      else
        assert_signals("R-type", "0000", "1111", 0, 0, 0, imm, '0', '0', '1');
      end if;
    end loop;

    ---------------- I-type
    ir_dc <= (others => '0');
    ir_dc(6 downto 0) <= "0000011"; -- Load
    for i in 0 to 7 loop
      ir_dc(14 downto 12) <= std_logic_vector(to_unsigned(i, 3));
      wait for 10 ps;
      if i < 3 or i = 4 or i = 5 then
        assert_signals("I-type Load", "0000", "0" & std_logic_vector(to_unsigned(i, 3)), 0, 0, 0, imm, '1', '0', '0');
      else
        assert_signals("I-type Load", "0000", "1111", 0, 0, 0, imm, '0', '0', '1');
      end if;
    end loop;

    ir_dc(14 downto 12) <= (others => '0');
    for i in 1 to 2**12-1 loop
      imm := std_logic_vector(to_unsigned(i, 32));
      ir_dc(31 downto 20) <= imm(11 downto 0);
      wait for 10 ps;
      imm(imm'high downto 12) := (others => ir_dc(31));
      assert_signals("I-type Load", "0000", "0000", 0, 0, 0, imm, '1', '0', '0');
    end loop;

    ir_dc(31 downto 20) <= (others => '0');
    imm := (others => '0');
    for i in 1 to 31 loop
      ir_dc(19 downto 15) <= std_logic_vector(to_unsigned(i, 5));
      ir_dc(11 downto 7) <= std_logic_vector(to_unsigned(31-i, 5));
      wait for 10 ps;
      assert_signals("I-type Load", "0000", "0000", i, 0, 31-i, imm, '1', '0', '0');
    end loop;

    ir_dc <= (others => '0');
    ir_dc(6 downto 0) <= "0010011"; -- ALU immediate
    for i in 0 to 7 loop
      ir_dc(14 downto 12) <= std_logic_vector(to_unsigned(i, 3));
      wait for 10 ps;
      assert_signals("I-type ALU immediate", '0' & ir_dc(14 downto 12), "1111", 0, 0, 0, imm, '1', '0', '0');
    end loop;

    ir_dc(30) <= '1';
    for i in 0 to 7 loop
      ir_dc(14 downto 12) <= std_logic_vector(to_unsigned(i, 3));
      wait for 10 ps;
      if i = 1 then
        imm(10) := '0';
        assert_signals("I-type ALU immediate", "0000", "1111", 0, 0, 0, imm, '0', '0', '1');
      elsif i = 5 then
        imm(10) := '0';
        assert_signals("I-type ALU immediate", "1101", "1111", 0, 0, 0, imm, '1', '0', '0');
      else
        imm(10) := '1';
        assert_signals("I-type ALU immediate", "0" & ir_dc(14 downto 12), "1111", 0, 0, 0, imm, '1', '0', '0');
      end if;
    end loop;

    ir_dc(30) <= '0';
    ir_dc(14 downto 12) <= "101";
    for i in 1 to 2**6-1 loop
      ir_dc(26 downto 20) <= std_logic_vector(to_unsigned(i, 7));
      wait for 10 ps;
      if i < DATA_WIDTH then
        imm := std_logic_vector(to_unsigned(i, 32));
        assert_signals("I-type ALU immediate", "0101", "1111", 0, 0, 0, imm, '1', '0', '0');
      else
        imm := (others => '0');
        assert_signals("I-type ALU immediate", "0000", "1111", 0, 0, 0, imm, '0', '0', '1');
      end if;
    end loop;

    ir_dc(14 downto 12) <= (others => '0');
    for i in 1 to 2**12-1 loop
      imm := std_logic_vector(to_unsigned(i, 32));
      ir_dc(31 downto 20) <= imm(11 downto 0);
      wait for 10 ps;
      imm(imm'high downto 12) := (others => ir_dc(31));
      assert_signals("I-type ALU immediate", "0000", "1111", 0, 0, 0, imm, '1', '0', '0');
    end loop;

    ir_dc(31 downto 20) <= (others => '0');
    imm := (others => '0');
    for i in 1 to 31 loop
      ir_dc(19 downto 15) <= std_logic_vector(to_unsigned(i, 5));
      ir_dc(11 downto 7) <= std_logic_vector(to_unsigned(31-i, 5));
      wait for 10 ps;
      assert_signals("I-type ALU immediate", "0000", "1111", i, 0, 31-i, imm, '1', '0', '0');
    end loop;

    ir_dc <= (others => '0');
    ir_dc(6 downto 0) <= "1100111"; -- JALR
    for i in 0 to 7 loop
      ir_dc(14 downto 12) <= std_logic_vector(to_unsigned(i, 3));
      wait for 10 ps;
      if i = 0 then
        assert_signals("I-type JALR", "0000", "1111", 0, 0, 0, imm, '1', '0', '0');
      else
        assert_signals("I-type JALR", "0000", "1111", 0, 0, 0, imm, '0', '0', '1');
      end if;
    end loop;

    ir_dc(14 downto 12) <= (others => '0');
    for i in 1 to 2**12-1 loop
      imm := std_logic_vector(to_unsigned(i, 32));
      ir_dc(31 downto 20) <= imm(11 downto 0);
      wait for 10 ps;
      imm(imm'high downto 12) := (others => ir_dc(31));
      assert_signals("I-type JALR", "0000", "1111", 0, 0, 0, imm, '1', '0', '0');
    end loop;

    ir_dc(31 downto 20) <= (others => '0');
    imm := (others => '0');
    for i in 1 to 31 loop
      ir_dc(19 downto 15) <= std_logic_vector(to_unsigned(i, 5));
      ir_dc(11 downto 7) <= std_logic_vector(to_unsigned(31-i, 5));
      wait for 10 ps;
      assert_signals("I-type JALR", "0000", "1111", i, 0, 31-i, imm, '1', '0', '0');
    end loop;

    wait;
  end process;
end architecture behav;
