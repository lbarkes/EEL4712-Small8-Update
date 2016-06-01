library ieee;
use ieee.std_logic_1164.all;

entity controller is
  generic (
    width :     positive := 32);
  port (
    clk   : in  std_logic;
    rst   : in  std_logic;
	data  : in  std_logic_vector(width-1 downto 0);


    -- control signals to/from datapath
	wr : out std_logic;
	a_sel : out std_logic;
	b_sel : out std_logic_vector(1 downto 0);
	pc_sel : out std_logic_vector(1 downto 0);
	write_reg_sel : out std_logic;
	write_data_sel : out std_logic_vector(1 downto 0);
	mem_sel : out std_logic;
	ALU_opcode : out std_logic_vector(5 downto 0); 
	Aen, Ben, PCen, IRen, MemRegen, ALUen, writeEnable, LOen, HIen : out std_logic
    );
end controller;

architecture FSM_2P of controller is

  type STATE_TYPE is (INIT, FETCH, IR, ADDU1, ADDU2, SUBU1, SUBU2, AND1, AND2, OR1, OR2, XOR1, XOR2, ADDIU1, ADDIU2, ANDI1, ANDI2, ORI1, ORI2, XORI1, XORI2, SRL1, SRL2, SLL1, SLL2, SLT1, SLT2, SLTU1, SLTU2, SLTI1, SLTI2, SLTIU1, SLTIU2, MULT, MULTU1, JR1, JR2);
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

  process(go, count_done, state)
  begin

    -- default values
	LOen <= '0';
	HIen <= '0';
	a_sel <= '0';
	b_sel <= "00";
	pc_sel <= "00";
	write_reg_sel <= '0';
	write_data_sel <= "00";
	mem_sel <= '0';
	ALU_opcode <= "000000"; 
	Aen <= '0';
	Ben <= '0';
	PCen <= '0';
	IRen <= '0';
	MemRegen <= '0';
	ALUen <= '0';
	writeEnable <= '0';
    
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
						write_reg_sel <= '1';   --MUX SEL IR15-11
						writeEnable <= '1';		--write enable
						next_state <= PCINC;
					when "010010" => --MFLO
						write_data_sel <= "11"; --MUX SEL LO_REG
						write_reg_sel <= '1';	--MUX SEL IR15-11
						writeEnable <= '1';		--write enable
						next_state <= PCINC;
					when "001000" => --JR
						Aen => '1';
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
			
			when "101011" => --SW
			
			when "100000" => --LB
			
			when "100100" => --LBU
			
			when "101000" => --SB
			
			when "100001" => --LH
			
			when "100101" => --LHU
			
			when "101001" => --SH
			
			when "100111" => --LWU
			
			when "000100" => --BEQ
			
			when "000101" => --BNE
			
			when "000110" => --BLEZ
			
			when "000111" => --BGTZ
			
			when "000001" => 
				case data(20 downto 16) is
					when "00000" => --BLTZ
					
					when "00001" => --BGEZ
					
					when others => 
						next_state <= INIT;
				end case;
			
			when "000010" => --j
			
			when "000011" => --JAL
			
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
		write_reg_sel <= '1';
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
		write_reg_sel <= '1';
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
		write_reg_sel <= '1';
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
		write_reg_sel <= '1';
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
		write_reg_sel <= '1';
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
		write_reg_sel <= '0';
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
		write_reg_sel <= '0';
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
		write_reg_sel <= '0';
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
		write_reg_sel <= '0';
		writeEnable <= '1';
		next_state <= PCINC;
		
	  when SRL1 =>
		b_sel <= "00";
		ALU_opcode <= "000111";
		ALUen <= '1';
		next_state <= SRL2;
	  
	  when SRL2 =>
		write_data_sel <= "00";
		write_reg_sel <= '1';
		writeEnable <= '1';
		next_state <= PCINC;
		
	  when SLL1 =>
		b_sel <= "00";
		ALU_opcode <= "000110";
		ALUen <= '1';
		next_state <= SLL2;
	  
	  when SLL2 =>
		write_data_sel <= "00";
		write_reg_sel <= '1';
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
		write_reg_sel <= '1';
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
		write_reg_sel <= '1';
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
		write_reg_sel <= '0';
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
		write_reg_sel <= '0';
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
		
		
	  when PCINC => --need to add
	    
      when others => null;
    end case;
  end process;
end FSM_2P;