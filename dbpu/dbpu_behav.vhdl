architecture behav of dbpu is
begin
  sel_link  <= mode(0);
  valid     <= mode(1) and (comp or mode(0));
  bta       <= sbta when (mode(1) and comp) else dbta;
end architecture behav;
