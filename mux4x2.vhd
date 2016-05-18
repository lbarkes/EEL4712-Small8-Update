library ieee;
use ieee.std_logic_1164.all;

entity mux4x2 is
  generic (
    width  => width);
  port (
    in1    : in  std_logic_vector(width-1 downto 0);
    in2    : in  std_logic_vector(width-1 downto 0);
	in3    : in  std_logic_vector(width-1 downto 0);
    in4    : in  std_logic_vector(width-1 downto 0);
    sel    : in  std_logic_vector(1 downto 0);
    output : out std_logic_vector(width-1 downto 0));
end mux4x2;

architecture BHV of mux4x2 is
begin
  if(sel = "00") then
	output <= in1;
  elsif(sel = "01") then
	output <= in2;
  elsif(sel = "10") then
	output <= in3;
  else
	output <= in4;
  end if;
end BHV;