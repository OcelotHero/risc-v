architecture behav of fm is
  signal bank_empty: bank_size_array(0 to N_RS_BANK-1);
begin

  process(clk, res_n)
  begin
    if res_n = '0' then
      bank_empty <= BANK_SIZE;
    elsif rising_edge(clk) then
      for i in 0 to N_RS_BANK-1 loop
        bank_empty(i) <= bank_empty(i) + free(i) - claim(i);
      end loop;
    end if;
  end process;
  empty <= bank_empty;
end architecture behav;
