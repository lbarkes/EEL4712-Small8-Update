library ieee;
use ieee.std_logic_1164.all;

entity mux2x1 is
  generic (
    width  => width);
  port (
    in1    : in  std_logic_vector(width-1 downto 0);
    in2    : in  std_logic_vector(width-1 downto 0);
    sel    : in  std_logic;
    output : out std_logic_vector(width-1 downto 0));
end mux2x1;

architecture BHV of mux2x1 is
begin
  if(sel = '0') then
	output <= in1;
  else
	output <= in2;
  end if;
end BHV;
