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
output : out std_logic_vector(WIDTH-1 downto 0);
);
end alu;


architecture logic of alu is

signal zerocheck  : std_logic_vector(width-1 downto 0);

begin
   process(input1,input2,sel)
	variable temp : unsigned(width-1 downto 0);
	variable compare : unsigned(width-1 downto 0);
	variable temp3 : unsigned (width downto 0);
   begin
	C <= '0';
	case sel is
		-- alu sel 
		when "0000" => --add
			if(Carry = '1') then
				temp3 := unsigned(unsigned('0' & input1)+unsigned('0' & input2) + 1);
			else
				temp3 := unsigned(unsigned('0' & input1)+unsigned('0' & input2));
			end if;
			C <= temp3(width);
			temp := temp3(width-1 downto 0);
		when "0001" => --subtract
			if(Carry = '1') then
				temp := unsigned(input1)-unsigned(input2)+1;
			else
				temp := unsigned(input1)-unsigned(input2);
			end if;
		when "0010" => --compare
			if(Carry = '1') then
				temp := unsigned(input1)-unsigned(input2)+1;
			else
				temp := unsigned(input1)-unsigned(input2);
			end if;
		when "0011" => --and
			temp := unsigned(input1 and input2);
		when "0100" => --or
			temp := unsigned(input1 or input2);
		when "0101" => --xor
			temp := unsigned(input1 xor input2);
		when "0110" => --left shift logical
			temp := unsigned(input1(width-2 downto 0) & '0');
			C <= input1(width-1);
		when "0111" => --shift right logical
			temp := unsigned('0' & input1(width-1 downto 1));
			C <= input1(0);
		when "1000" => --rotate left through carry
			temp := unsigned(input1(width-2 downto 0) & Carry);
			C <= input1(width-1);
		when "1001" => --rotate right through carry
			temp := unsigned(Carry & input1(width-1 downto 1));
			C <= input1(0);
		when "1010" => --Increment A
			temp := unsigned(input1)+1;
		when "1011" => --decrement A
			temp := unsigned(input1)-1;
		when others => 
			temp := unsigned(input1);
	end case;
	if(sel = "0010") then
		output <= input1;
	else
		output <= std_logic_vector(temp);
	end if;
	zerocheck <= std_logic_vector(temp);
	S <= temp(width-1);
	if(temp = 0) then
		Z <= '1';
	else
		Z <= '0';
	end if;
   end process;
   V <= ((input1(width-1) and input2(width-1) and not zerocheck(width-1)) or (not input1(width-1) and not input2(width-1) and zerocheck(width-1)));
end logic;