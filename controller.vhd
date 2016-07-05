library ieee;
use ieee.std_logic_1164.all;

entity controller is
  generic (
    width :     positive := 32);
  port (
    clk   : in  std_logic;
    rst   : in  std_logic;
	data  : in  std_logic_vector(width-1 downto 0);
    S	  : in std_logic;
	Z 	  : in std_logic;

    -- control signals to/from datapath
	PCOUT_sel : out std_logic;
	wr, rd : out std_logic;
	a_sel : out std_logic;
	b_sel : out std_logic_vector(1 downto 0);
	pc_sel : out std_logic_vector(1 downto 0);
	write_reg_sel : out std_logic_vector(1 downto 0);
	write_data_sel : out std_logic_vector(1 downto 0);
	mem_sel : out std_logic;
	ALU_opcode : out std_logic_vector(5 downto 0); 
	WRregin : out std_logic_vector(4 downto 0);
	Aen, Ben, PCen, IRen, MemRegen, ALUen, writeEnable, LOen, HIen, MemoryWRen : out std_logic
    );
end controller;

architecture FSM_2P of controller is

  type STATE_TYPE is (INIT, FETCH, IR, ADDU1, ADDU2, SUBU1, SUBU2, AND1, AND2, OR1, OR2, XOR1, XOR2, ADDIU1, ADDIU2, ANDI1, ANDI2, ORI1, ORI2, XORI1, XORI2, SRL1, SRL2, SLL1, SLL2, SLT1, SLT2, SLTU1, SLTU2, SLTI1, SLTI2, SLTIU1, SLTIU2, MULT, MULTU1, JR1, JR2, JAL1, BEQ1, BEQ2, BEQ3, BNE1, BNE2, BNE3, BLEZ1, BLEZ2, BLEZ3, BGTZ1, BGTZ2, BGTZ3, BLTZ1, BLTZ2, BLTZ3, BGEZ1, BGEZ2, BGEZ3, LW1, LW2, LW3, LW4, SW1, SW2, SW3, SW4, mult1, PCINC, PCINC2);
  signal state, next_state : STATE_TYPE;

begin  -- FSM_2P

  process(clk, rst)
  begin
    if (rst = '1') then
      state <= INIT;
    elsif (clk'event and clk = '1') then
      state <= next_state;
    end if;
  end process;

  process(state, next_state)
  begin

    -- default values
	LOen <= '0';
	HIen <= '0';
	a_sel <= '0';
	b_sel <= "00";
	pc_sel <= "00";
	write_reg_sel <= "00";
	write_data_sel <= "00";
	WRregin <= "00000";
	mem_sel <= '0';
	ALU_opcode <= "000000"; 
	Aen <= '0';
	Ben <= '0';
	PCen <= '0';
	IRen <= '0';
	MemRegen <= '0';
	ALUen <= '0';
	writeEnable <= '0';
	PCOUT_sel <= '0';
	MemoryWRen <= '0';

    
    case state is
      when INIT =>
		next_state <= FETCH;

      when FETCH =>
		rd <= '1';
		wr <= '0';
		next_state <= IR;
	  
	  when IR => 
		rd <= '1';
		case data(31 downto 26) is
			when "000000" => --special
			 
				case data(5 downto 0) is
					when "100001" => --ADDU
						Aen <= '1';
						Ben <= '1';
						next_state <= ADDU1;
					when "100011" => --SUBU
						Aen <= '1';
						Ben <= '1';
						next_state <= SUBU1;
					when "011000" => --MULT
						Aen <= '1';
						Ben <= '1';
						next_state <= MULT1;
					when "011001" => --MULTU
						Aen <= '1';
						Ben <= '1';
						next_state <= MULTU1;
					when "100100" => --AND
						Aen <= '1';
						Ben <= '1';
						next_state <= AND1;
					when "100101" => --OR
						Aen <= '1';
						Ben <= '1';
						next_state <= OR1;
					when "100110" => --XOR
						Aen <= '1';
						Ben <= '1';
						next_state <= XOR1;
					when "000010" => --SRL
						Ben <= '1';
						next_state <= SRL1;
					when "000000" => --SLL
						Ben <= '1';
						next_state <= SLL1;
					when "000011" => --SRA
						
					when "101010" => --SLT
						Aen <= '1';
						Ben <= '1';
						next_state <= SLT1;
					when "101011" => --SLTU
						Aen <= '1';
						Ben <= '1';
						next_state <= SLTU1;
					when "010000" => --MFHI
						write_data_sel <= "10"; --MUX SEL HI_REG
						write_reg_sel <= "01";   --MUX SEL IR15-11
						writeEnable <= '1';		--write enable
						next_state <= PCINC;
					when "010010" => --MFLO
						write_data_sel <= "11"; --MUX SEL LO_REG
						write_reg_sel <= "01";	--MUX SEL IR15-11
						writeEnable <= '1';		--write enable
						next_state <= PCINC;
					when "001000" => --JR
						Aen <= '1';
						next_state <= JR1;
					
					when others => 
						next_state <= INIT;
				
				end case;
				
			when "001001" => --addiu
				Aen <= '1';
				next_state <= ADDIU1;
			
			--when "00----" => --subiu UNKNOWN CODE
		  
		    when "001100" => --ANDI
				Aen <= '1';
				next_state <= ANDI1;
			when "001101" => --ORI
				Aen <= '1';
				next_state <= ORI1;
			when "001110" => --XORI
				Aen <= '1';
				next_state <= XORI1;
			when "001010" => --SLTI
				Aen <= '1';
				next_state <= SLTI1;
			when "001011" => --SLTIU
				Aen <= '1';
				next_state <= SLTIU1;
			when "100011" => --LW
			    Aen <= '1';
				next_state <= LW1;
			when "101011" => --SW
				Ben <= '1';
				Aen <= '1';
				next_state <= SW1;
			when "100000" => --LB
				Aen <= '1';
				next_state <= LW1;
			when "100100" => --LBU
				Aen <= '1';
				next_state <= LW1;
			when "101000" => --SB
				Ben <= '1';
				Aen <= '1';
				next_state <= SW1;
			when "100001" => --LH
				Aen <= '1';
				next_state <= LW1;
			when "100101" => --LHU
				Aen <= '1';
				next_state <= LW1;
			when "101001" => --SH
				Ben <= '1';
				Aen <= '1';
				next_state <= SW1;
			when "100111" => --LWU
				Aen <= '1';
				next_state <= LW1;
			when "000100" => --BEQ
				Aen <= '1';
				Ben <= '1';
				next_state <= BEQ1;
			when "000101" => --BNE
				Aen <= '1';
				Ben <= '1';
				next_state <= BNE1;
			when "000110" => --BLEZ
				Aen <= '1';
				Ben <= '1';
				next_state <= BLEZ1;
			when "000111" => --BGTZ
				Aen <= '1';
				Ben <= '1';
				next_state <= BGTZ1;
			when "000001" => 
				case data(20 downto 16) is
					when "00000" => --BLTZ
						Aen <= '1';
						Ben <= '1';
						next_state <= BLTZ1;
					when "00001" => --BGEZ
						Aen <= '1';
						Ben <= '1';
						next_state <= BGEZ1;
					when others => 
						next_state <= INIT;
				end case;
			
			when "000010" => --j
				pc_sel <= "10";
				PCen <= '1';
				next_state <= FETCH;
			when "000011" => --JAL
				pc_sel <= "10";
				PCen <= '1';
				a_sel <= '0';
				b_sel <= "01";
				ALUen <= '1';
				ALU_opcode <= "000000";
				next_state <= JAL1;
			when others => 
				next_state <= INIT;
		end case;

	  when ADDU1 =>	--update aluoutreg
		a_sel <= '1';
		b_sel <= "00";
		ALU_opcode <= "000000";
		ALUen <= '1';
		next_state <= ADDU2;
		
	  when ADDU2 => --save to regfile
	    write_data_sel <= "00";
		write_reg_sel <= "01";
		writeEnable <= '1';
		next_state <= PCINC;
		
	  when SUBU1 =>	--update aluoutreg
		a_sel <= '1';
		b_sel <= "00";
		ALU_opcode <= "000001";
		ALUen <= '1';
		next_state <= SUBU2;
		
	  when SUBU2 => --save to regfile
	    write_data_sel <= "00";
		write_reg_sel <= "01";
		writeEnable <= '1';
		next_state <= PCINC;
		
	  when AND1 =>	--update aluoutreg
		a_sel <= '1';
		b_sel <= "00";
		ALU_opcode <= "000011";
		ALUen <= '1';
		next_state <= AND2;
		
	  when AND2 => --save to regfile
	    write_data_sel <= "00";
		write_reg_sel <= "01";
		writeEnable <= '1';
		next_state <= PCINC;
		
	  when OR1 =>	--update aluoutreg
		a_sel <= '1';
		b_sel <= "00";
		ALU_opcode <= "000100";
		ALUen <= '1';
		next_state <= OR2;
		
	  when OR2 => --save to regfile
	    write_data_sel <= "00";
		write_reg_sel <= "01";
		writeEnable <= '1';
		next_state <= PCINC;
		
	  when XOR1 =>	--update aluoutreg
		a_sel <= '1';
		b_sel <= "00";
		ALU_opcode <= "000101";
		ALUen <= '1';
		next_state <= XOR2;
		
	  when XOR2 => --save to regfile
	    write_data_sel <= "00";
		write_reg_sel <= "01";
		writeEnable <= '1';
		next_state <= PCINC;
		
	  when ADDIU1 =>
		a_sel <= '1';
		b_sel <= "10";
		ALU_opcode <= "000000";
		ALUen <= '1';
		next_state <= ADDIU2;
	  
	  when ADDIU2 =>
		write_data_sel <= "00";
		write_reg_sel <= "00";
		writeEnable <= '1';
		next_state <= PCINC;
		
	  when ANDI1 =>
		a_sel <= '1';
		b_sel <= "10";
		ALU_opcode <= "000011";
		ALUen <= '1';
		next_state <= ANDI2;
	  
	  when ANDI2 =>
		write_data_sel <= "00";
		write_reg_sel <= "00";
		writeEnable <= '1';
		next_state <= PCINC;
		
	  when ORI1 =>
		a_sel <= '1';
		b_sel <= "10";
		ALU_opcode <= "000100";
		ALUen <= '1';
		next_state <= ORI2;
	  
	  when ORI2 =>
		write_data_sel <= "00";
		write_reg_sel <= "00";
		writeEnable <= '1';
		next_state <= PCINC;
		
	  when XORI1 =>
		a_sel <= '1';
		b_sel <= "10";
		ALU_opcode <= "000101";
		ALUen <= '1';
		next_state <= XORI2;
	  
	  when XORI2 =>
		write_data_sel <= "00";
		write_reg_sel <= "00";
		writeEnable <= '1';
		next_state <= PCINC;
		
	  when SRL1 =>
		b_sel <= "00";
		ALU_opcode <= "000111";
		ALUen <= '1';
		next_state <= SRL2;
	  
	  when SRL2 =>
		write_data_sel <= "00";
		write_reg_sel <= "01";
		writeEnable <= '1';
		next_state <= PCINC;
		
	  when SLL1 =>
		b_sel <= "00";
		ALU_opcode <= "000110";
		ALUen <= '1';
		next_state <= SLL2;
	  
	  when SLL2 =>
		write_data_sel <= "00";
		write_reg_sel <= "01";
		writeEnable <= '1';
		next_state <= PCINC;
	
	  when SLT1 =>	--update aluoutreg
		a_sel <= '1';
		b_sel <= "00";
		ALU_opcode <= "001001";
		ALUen <= '1';
		next_state <= SLT2;
		
	  when SLT2 => --save to regfile
	    write_data_sel <= "00";
		write_reg_sel <= "01";
		writeEnable <= '1';
		next_state <= PCINC;
		
	  when SLTU1 =>	--update aluoutreg
		a_sel <= '1';
		b_sel <= "00";
		ALU_opcode <= "001010";
		ALUen <= '1';
		next_state <= SLTU2;
		
	  when SLTU2 => --save to regfile
	    write_data_sel <= "00";
		write_reg_sel <= "01";
		writeEnable <= '1';
		next_state <= PCINC;
		
	  when SLTI1 =>	--update aluoutreg
		a_sel <= '1';
		b_sel <= "10";
		ALU_opcode <= "001001";
		ALUen <= '1';
		next_state <= SLTI2;
		
	  when SLTI2 => --save to regfile
	    write_data_sel <= "00";
		write_reg_sel <= "00";
		writeEnable <= '1';
		next_state <= PCINC;
		
	  when SLTIU1 =>	--update aluoutreg
		a_sel <= '1';
		b_sel <= "10";
		ALU_opcode <= "001010";
		ALUen <= '1';
		next_state <= SLTIU2;
		
	  when SLTIU2 => --save to regfile
	    write_data_sel <= "00";
		write_reg_sel <= "00";
		writeEnable <= '1';
		next_state <= PCINC;
	  
	  when MULT1 =>
		a_sel <= '1';
		b_sel <= "00";
		ALU_opcode <= "001011";
		LOen <= '1';
		next_state <= PCINC;
	
	  when MULTU1 =>
		a_sel <= '1';
		b_sel <= "00";
		ALU_opcode <= "000010";
		LOen <= '1';
		next_state <= PCINC;
		
	  when JR1 =>
		a_sel <= '1';
		b_sel <= "00";
		ALU_opcode <= "111111";
		ALUen <= '1';
		next_state <= JR2;
		
	  when JR2 =>
	    pc_sel <= "01";
		PCen <= '1';
		next_state <= FETCH;
		
	  when JAL1 =>
	    write_data_sel <= "10";
		WRregin <= "11111";
	    next_state <= FETCH;
		
	  when BEQ1 =>
		ALU_opcode <= "000001";
		a_sel <= '1';
		b_sel <= "00";
		next_state <= BEQ2;
	  
	  when BEQ2 =>
		if (Z = '1') then
			b_sel <= "11";
			a_sel <= '0';
			ALUen <= '1';
			ALU_opcode <= "000000";
			next_state <= BEQ3;
		else
			next_state <= PCINC;
		end if;
	  
	  when BEQ3 =>
	    pc_sel <= "01";
		PCen <= '1';
		next_state <= FETCH;
		
	  when BNE1 =>
		ALU_opcode <= "000001";
		a_sel <= '1';
		b_sel <= "00";
		next_state <= BEQ2;
	  
	  when BNE2 =>
		if (Z = '0') then
			b_sel <= "11";
			a_sel <= '0';
			ALUen <= '1';
			ALU_opcode <= "000000";
			next_state <= BEQ3;
		else
			next_state <= PCINC;
		end if;
	  
	  when BNE3 =>
	    pc_sel <= "01";
		PCen <= '1';
		next_state <= FETCH;
		
	  when BLEZ1 =>
		ALU_opcode <= "111111";
		a_sel <= '1';
		b_sel <= "00";
		next_state <= BEQ2;
	  
	  when BLEZ2 =>
		if ((Z = '1') and (S = '1')) then
			b_sel <= "11";
			a_sel <= '0';
			ALUen <= '1';
			ALU_opcode <= "000000";
			next_state <= BEQ3;
		else
			next_state <= PCINC;
		end if;
	  
	  when BLEZ3 =>
	    pc_sel <= "01";
		PCen <= '1';
		next_state <= FETCH;
		
	  when BGTZ1 =>
		ALU_opcode <= "111111";
		a_sel <= '1';
		b_sel <= "00";
		next_state <= BEQ2;
	  
	  when BGTZ2 =>
		if ((Z = '0') and (S = '0')) then
			b_sel <= "11";
			a_sel <= '0';
			ALUen <= '1';
			ALU_opcode <= "000000";
			next_state <= BEQ3;
		else
			next_state <= PCINC;
		end if;
	  
	  when BGTZ3 =>
	    pc_sel <= "01";
		PCen <= '1';
		next_state <= FETCH;
	
	  when BLTZ1 =>
		ALU_opcode <= "111111";
		a_sel <= '1';
		b_sel <= "00";
		next_state <= BEQ2;
	  
	  when BLTZ2 =>
		if ((Z = '0') and (S = '1')) then
			b_sel <= "11";
			a_sel <= '0';
			ALUen <= '1';
			ALU_opcode <= "000000";
			next_state <= BEQ3;
		else
			next_state <= PCINC;
		end if;
	  
	  when BLTZ3 =>
	    pc_sel <= "01";
		PCen <= '1';
		next_state <= FETCH;
	
	  when BGEZ1 =>
		ALU_opcode <= "111111";
		a_sel <= '1';
		b_sel <= "00";
		next_state <= BEQ2;
	  
	  when BGEZ2 =>
		if ((Z = '1') and (S = '0')) then
			b_sel <= "11";
			a_sel <= '0';
			ALUen <= '1';
			ALU_opcode <= "000000";
			next_state <= BEQ3;
		else
			next_state <= PCINC;
		end if;
	  
	  when BGEZ3 =>
	    pc_sel <= "01";
		PCen <= '1';
		next_state <= FETCH;
		
	  when LW1 =>
	    a_sel <= '1';
		b_sel <= "11";
		ALUen <= '1';
		ALU_opcode <= "000000";
		next_state <= LW2;
	  
	  when LW2 => 
	    PCOUT_sel <= '1';
		next_state <= LW3;
	  
	  when LW3 =>
	    MemRegen <= '1';
		next_state <= LW4;
	  
	  when LW4 => 
	    write_data_sel <= "01";
		write_reg_sel <= "00";
		writeEnable <= '1';
		next_state <= PCINC;
	
	  when SW1 =>
	    a_sel <= '1';
		b_sel <= "11";
		ALU_opcode <= "000000";
		ALUen <= '1';
		next_state <= SW2;
	  
	  when SW2 =>
	    PCOUT_sel <= '1';
		next_state <= SW3;
	
	  when SW3 =>
	    PCOUT_sel <= '1';
		MemoryWRen <= '1';
		next_state <= SW4;
	
	  when SW4 =>
	    next_state <= PCINC;
		
	  when PCINC => --need to add
		ALU_opcode <= "000000";
		a_sel <= '0';
		b_sel <= "01";
		ALUen <= '1';
		next_state <= PCINC2;
	
	  when PCINC2 => 
	    pc_sel <= "01";
		PCen <= '1';
		next_state <= FETCH;
	    
      when others => null;
    end case;
  end process;
end FSM_2P;