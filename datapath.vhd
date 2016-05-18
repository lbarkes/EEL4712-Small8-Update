library ieee;
use ieee.std_logic_1164.all;

entity datapath is
  generic (
    width  :     positive := 32);
  port (
	clk : in std_logic;
	rst : in std_logic;
	input : in std_logic_vector(31 downto 0); --will be replaced by RAM
	a_sel : in std_logic;
	b_sel : in std_logic_vector(1 downto 0);
	pc_sel : in std_logic_vector(1 downto 0);
	write_reg_sel : in std_logic;
	write_data_sel : in std_logic;
	mem_sel : in std_logic;
	ALU_opcode : in std_logic_vector(5 downto 0); 
	Aen, Ben, PCen, IRen, MemRegen, ALUen, writeEnable : in std_logic;
  );

end datapath;

architecture STR of datapath is

signal  WRreg_out : std_logic_vector(4 downto 0);
signal  IR_out, PC_out, A_MUX_out, B_MUX_out, alu_reg_out, PC_MUX_out, sign_extend_out           : std_logic_vector(31 downto 0);
signal  alu_out, A_out, B_out, regfileout1, regfileout2, MemoryRegOut, WRdata_out            : std_logic_vector(31 downto 0);
signal  b_mux_in : std_logic_vector(31 downto 0);
begin

  U_PC : entity work.reg32
  port map (
      clk      	=> clk,
      rst      	=> rst,
	  en		=> PCen,
      input    	=> PC_MUX_out,
      output   	=> PC_out
    );

  U_IR : entity work.reg32
  port map (
      clk      	=> clk,
      rst      	=> rst,
	  en		=> IRen,
      input    	=> input,
      output   	=> IR_out
    );
	
  U_A : entity work.reg32
  port map (
      clk      	=> clk,
      rst      	=> rst,
	  en		=> Aen,
      input    	=> regfileout1
      output   	=> A_out
    );

  U_B : entity work.reg32
  port map (
      clk      	=> clk,
      rst      	=> rst,
	  en		=> Ben,
      input    	=> regfileout2
      output   	=> B_out
    );
	
  U_MemoryReg : entity work.reg32
  port map (
      clk      	=> clk,
      rst      	=> rst,
	  en		=> MemRegen,
      input    	=> input,
      output   	=> MemoryRegOut
    );
	
  U_A_MUX : entity work.mux2x1
  generic ( 
    width => 32)
  port map (
	  in1    	=> PC_out,
      in2    	=> A_out,
      sel    	=> a_sel,
      output 	=> A_MUX_out
  );
  
  b_mux_in <= sign_extend_out(29 downto 0) & "00";
  
  U_B_MUX : entity work.mux4x2
  generic ( 
    width => 32)
  port map (
	  in1    	=> b_out,
      in2    	=> 
	  in3    	=> sign_extend_out
      in4    	=> b_mux_in,
      sel    	=> b_sel,
      output 	=> B_MUX_out
  );
  
  U_PC_MUX : entity work.mux2x1
  generic ( 
    width => 32)
  port map (
	  in1    	=> 			--EPC
      in2    	=> alu_reg_out,
	  in3    	=> 
      in4    	=> "00000000000000000000000000000000";
      sel    	=> pc_sel,
      output 	=> PC_MUX_out
  );
  
  U_WRdata_MUX : entity work.mux2x1
  generic ( 
    width => 32)
  port map (
	  in1    	=> alu_reg_out,
      in2    	=> MemoryRegOut,
      sel    	=> write_data_sel,
      output 	=> WRdata_out
  );
  
  U_WRreg_MUX : entity work.mux2x1
  generic ( 
    width => 5)
  port map (
	  in1    	=> IR_out(20 downto 16),
      in2    	=> IR_out(15 downto 11),
      sel    	=> write_reg_sel,
      output 	=> WRreg_out
  );
  
  U_regfile : entity work.register_file
  port(
    outA        => regfileout1,
    outB        => regfileout2,
    input       => MemoryRegOut,
    writeEnable => writeEnable,
    regASel     => IR_out(25 downto 21),
    regBSel     => IR_out(20 downto 16),
    writeRegSel => WRreg_out,
    clk         => clk
  );
  
  U_ALU : entity work.alu
  port map (
      input1	=> A_MUX_out,
	  input2	=> B_MUX_out,
	  sel		=> ALU_opcode,
	  output	=> alu_out
  );
  
  U_ALUreg : entity work.reg32
  port map (
      clk      	=> clk,
      rst      	=> rst,
	  en		=> ALUen,
      input    	=> alu_out,
      output   	=> alu_reg_out
    );
	
  U_signextend : entity work.sign_extend
  port map (
      input    	=> IR_out(15 downto 0),
      output   	=> sign_extend_out
    );
	
end STR;