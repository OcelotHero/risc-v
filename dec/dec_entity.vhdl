library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dec is
  generic(DATA_WIDTH: positive := 32; ADDR_WIDTH: positive := 5);
  port( ir:                     in  std_logic_vector(31 downto 0);
        rd_addr_me, rd_addr_ex: in  std_logic_vector(ADDR_WIDTH-1 downto 0);
        mem_mode_ex:            in  std_logic_vector(3 downto 0);
        fwd_rs1, fwd_rs2:       out std_logic_vector(1 downto 0);
        fwd_selsd:              out std_logic;
        rs1_addr, rs2_addr:     out std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
        rd_addr:                out std_logic_vector(ADDR_WIDTH-1 downto 0);
        imm:                    out std_logic_vector(DATA_WIDTH-1 downto 0);
        alu_mode:               out std_logic_vector(3 downto 0);
        -- dbpu_mode:              out std_logic_vector(1 downto 0);
        mem_mode:               out std_logic_vector(3 downto 0);
        dbta_valid:             in std_logic;
        imm_to_alu, sel_bta:    out std_logic;
        sbta_valid, stall:      out std_logic;
        illegal:                out std_logic);
end entity dec;
