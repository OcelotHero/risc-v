architecture behav of dbpu is
  signal target_eq: std_logic;
begin
  target_eq <= '1' when dbta = pc_target else '0';

  sel_link  <= mode(0);
  -- valid     <= (mode = "11" and predict = '0') or (mode = "10" and comp = '1' and predict = '0')
  --              or (mode = "11" and predict = '1' and dbta /= pc_target)
  --              or (mode = "10" and predict = '1' and comp = '0');
  -- bta       <= dbta when mode = "11" and predict = '0' else
  --              sbta when mode = "10" and predict = '0' and comp = '1' else
  --              pc_n;
  valid     <= mode(1) and ((mode(0) and (predict nand target_eq)) or (comp xor predict));
  bta       <= dbta when mode = "11" else
               sbta when comp or mode(0) else
               pc_n;
end architecture behav;
