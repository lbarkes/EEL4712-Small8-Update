library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity alu is
   generic (
	WIDTH : positive := 32
   );
port (
input1 : in std_logic_vector(WIDTH-1 downto 0);
input2 : in std_logic_vector(WIDTH-1 downto 0);
sel : in std_logic_vector(5 downto 0);
output : out std_logic_vector(WIDTH-1 downto 0)
shift : in std_logic_vector(4 downto 0);
Z : out std_logic;
S : out std_logic;
);
end alu;


architecture logic of alu is

signal zerocheck  : std_logic_vector(width-1 downto 0);

begin
   process(input1,input2,sel)
	variable temp : unsigned(width-1 downto 0);
	variable temp3 : unsigned (width downto 0);
	variable multtemp : unsigned(width*2-1 downto 0);
   begin
	case sel is
		-- alu sel 
		when "000000" => --add unsigned
			temp3 := unsigned(unsigned('0' & input1)+unsigned('0' & input2));
			temp := temp3(width-1 downto 0);
		when "000001" => --subtract unsigned
			temp := unsigned(input1)-unsigned(input2);
		when "000010" => --multi
		    multtemp := unsigned(input1)*unsigned(input2);
			temp := multtemp(width-1 downto 0);
		when "001011" => --multi SIGNED
		    multtemp := signed(input1)*signed(input2);
			temp := multtemp(width-1 downto 0);
		when "000011" => --and
			temp := unsigned(input1 and input2);
		when "000100" => --or
			temp := unsigned(input1 or input2);
		when "000101" => --xor
			temp := unsigned(input1 xor input2);
		when "000110" => --left shift logical
			temp :=  unsigned(std_logic_vector(SHIFT_LEFT(unsigned(input2), natural(shift))));
		when "000111" => --shift right logical
			temp :=  unsigned(std_logic_vector(SHIFT_RIGHT(unsigned(input2), natural(shift))));
		when "001000" => --shift right arithmetic
			temp := unsigned(input1); --dont know how to do SHift right arithmetic
		when "001001" => --SLT
			if(signed(input1) < signed(input2)) then
				temp := unsigned("00000000000000000000000000000001"); --1
			else
				temp := unsigned("00000000000000000000000000000000"); --0
			end if;
		when "001010" => --SLTU
			if(input1) < input2) then
				temp := unsigned("00000000000000000000000000000001"); --1
			else
				temp := unsigned("00000000000000000000000000000000"); --0
			end if;
		when others => 
			temp := unsigned(input1);
	end case;
	output <= std_logic_vector(temp);
   end process;
end logic;