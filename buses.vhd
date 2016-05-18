library ieee;
use ieee.std_logic_1164.all;

entity buses is
  generic (
    width  :     positive := 8);
  port (
    input1 : in  std_logic_vector(width-1 downto 0);
    input2 : in  std_logic_vector(width-1 downto 0);
    input3 : in  std_logic_vector(width-1 downto 0);
    input4 : in  std_logic_vector(width-1 downto 0);
	input5 : in  std_logic_vector(width-1 downto 0);
    input6 : in  std_logic_vector(width-1 downto 0);
    input7 : in  std_logic_vector(width-1 downto 0);
    input8 : in  std_logic_vector(width-1 downto 0);
	input9 : in  std_logic_vector(width-1 downto 0);
	input10 : in std_logic_vector(width-1 downto 0);
	input11 : in std_logic_vector(width-1 downto 0);
	input12 : in std_logic_vector(width-1 downto 0);
    wen    : in  std_logic_vector(3 downto 0);
    output : out std_logic_vector(width-1 downto 0));
end buses;

architecture STR of buses is

signal en1  : std_logic;
signal en2  : std_logic;
signal en3  : std_logic;
signal en4  : std_logic;
signal en5  : std_logic;
signal en6  : std_logic;
signal en7  : std_logic;
signal en8  : std_logic;
signal en9  : std_logic;
signal en10 : std_logic;
signal en11  : std_logic;
signal en12 : std_logic;

begin

en1 <= not wen(0) and not wen(1) and not wen(2) and not wen(3);
en2 <= wen(0) and not wen(1) and not wen(2) and not wen(3);
en3 <= not wen(0) and wen(1) and not wen(2) and not wen(3);
en4 <= wen(0) and wen(1) and not wen(2) and not wen(3);
en5 <= not wen(0) and not wen(1) and wen(2) and not wen(3);
en6 <= wen(0) and not wen(1) and wen(2) and not wen(3);
en7 <= not wen(0) and wen(1) and wen(2) and not wen(3);
en8 <= wen(0) and wen(1) and wen(2) and not wen(3);
en9 <= not wen(0) and not wen(1) and not wen(2) and wen(3);
en10 <= wen(0) and not wen(1) and not wen(2) and wen(3);
en11 <= not wen(0) and wen(1) and not wen(2) and wen(3);
en12 <= wen(0) and wen(1) and not wen(2) and wen(3);


  U_PCH : entity work.tristate
    generic map (
      width  => width)
    port map (
      input  => input1,
      en     => en1,
      output => output);
	  
  U_PCL : entity work.tristate
    generic map (
      width  => width)
    port map (
      input  => input2,
      en     => en2,
      output => output);

  U_SPH : entity work.tristate
    generic map (
      width  => width)
    port map (
      input  => input3,
      en     => en3,
      output => output);
	  
  U_SPL : entity work.tristate
    generic map (
      width  => width)
    port map (
      input  => input4,
      en     => en4,
      output => output);
	  
  U_XH : entity work.tristate
    generic map (
      width  => width)
    port map (
      input  => input5,
      en     => en5,
      output => output);
	  
  U_XL : entity work.tristate
    generic map (
      width  => width)
    port map (
      input  => input6,
      en     => en6,
      output => output);
  
  U_ARH : entity work.tristate
    generic map (
      width  => width)
    port map (
      input  => input11,
      en     => en11,
      output => output);

  U_ARL : entity work.tristate
    generic map (
      width  => width)
    port map (
      input  => input12,
      en     => en12,
      output => output);

  U_D : entity work.tristate
    generic map (
      width  => width)
    port map (
      input  => input7,
      en     => en7,
      output => output);

  U_A : entity work.tristate
    generic map (
      width  => width)
    port map (
      input  => input8,
      en     => en8,
      output => output);
	  
  U_ALU : entity work.tristate
    generic map (
      width  => width)
    port map (
      input  => input9,
      en     => en9,
      output => output);
	  
   U_External : entity work.tristate
    generic map (
      width  => width)
    port map (
      input  => input10,
      en     => en10,
      output => output);

end STR;


-- architecture BHV of bus_4source is
-- begin

--   with wen select
--     output <=
--     PCH          when "0000",
--     PCL       	when "0001",
--     SPH          when "0010",
--     SPL          when "0011",
--     XH          when "0100",
--     XL       	when "0101",
--     D          when "0110",
--     A          when "0111",
--		ALU			when "1000",
--     (others => '-') when others;

-- end BHV;