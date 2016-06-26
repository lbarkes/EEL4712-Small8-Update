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
	write_reg_sel : in std_logic_vector(1 downto 0);
	write_data_sel : in std_logic_vector(1 downto 0);
	mem_sel : in std_logic;
	ALU_opcode : in std_logic_vector(5 downto 0); 
	WRregin : in std_logic_vector(4 downto 0);
	Aen, Ben, PCen, IRen, MemRegen, ALUen, writeEnable, LOen, HIen, PCOUT_sel : in std_logic
	ADDRESS : out std_logic_vector(31 downto 0);
  );

end datapath;

architecture STR of datapath is

signal  WRreg_out : std_logic_vector(4 downto 0);
signal  IR_out, PC_out, A_MUX_out, B_MUX_out, alu_reg_out, PC_MUX_out, sign_extend_out           : std_logic_vector(31 downto 0);
signal  alu_out, A_out, B_out, regfileout1, regfileout2, MemoryRegOut, WRdata_out, HI_out, LO_out            : std_logic_vector(31 downto 0);
signal  b_mux_in, PC_mux_in : std_logic_vector(31 downto 0);
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
	
  U_HI : entity work.reg32
  port map (
      clk      	=> clk,
      rst      	=> rst,
	  en		=> HIen,
      input    	=> alu_out,
      output   	=> HI_out
    );
	
  U_LO : entity work.reg32
  port map (
      clk      	=> clk,
      rst      	=> rst,
	  en		=> LOen,
      input    	=> alu_out,
      output   	=> LO_out
    );
	
  U_A : entity work.reg32
  port map (
      clk      	=> clk,
      rst      	=> rst,
	  en		=> Aen,
      input    	=> regfileout1,
      output   	=> A_out
    );

  U_B : entity work.reg32
  port map (
      clk      	=> clk,
      rst      	=> rst,
	  en		=> Ben,
      input    	=> regfileout2,
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
  port map (
	  in1    	=> PC_out,
      in2    	=> A_out,
      sel    	=> a_sel,
      output 	=> A_MUX_out
  );
  
  b_mux_in <= sign_extend_out(29 downto 0) & "00";
  
  U_B_MUX : entity work.mux4x2
  port map (
	  in1    	=> b_out,
      in2    	=> "00000000000000000000000000000100", --0004
	  in3    	=> sign_extend_out,
      in4    	=> b_mux_in,
      sel    	=> b_sel,
      output 	=> B_MUX_out
  );
  
  PC_mux_in <= "0000" & IR_out(25 downto 0) & "00";
  
  U_PC_MUX : entity work.mux4x2
  port map (
	  in1    	=> "00000000000000000000000000000000",		--EPC
      in2    	=> alu_reg_out,
	  in3    	=> PC_mux_in,
      in4    	=> "00000000000000000000000000000000",
      sel    	=> pc_sel,
      output 	=> PC_MUX_out
  );
  
  U_WRdata_MUX : entity work.mux4x2
  port map (
	  in1    	=> alu_reg_out,
      in2    	=> MemoryRegOut,
	  in3		=> HI_out,
	  in4		=> LO_out,
      sel    	=> write_data_sel,
      output 	=> WRdata_out
  );
  
  U_WRreg_MUX : entity work.mux2x1_5bit
  port map (
	  in1    	=> IR_out(20 downto 16),
      in2    	=> IR_out(15 downto 11),
	  in3       => WRregin,
      sel    	=> write_reg_sel,
      output 	=> WRreg_out
  );
  
  U_regfile : entity work.register_file
  port map (
    outA        => regfileout1,
    outB        => regfileout2,
    input       => WRdata_out,
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
	  shift 	=> IR_out(10 downto 6),
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
	
  U_PCOUT_MUX : entity work.mux2x1
  port map (
	  in1    	=> PC_out,
      in2    	=> alu_reg_out,
      sel    	=> PCOUT_sel,
      output 	=> ADDRESS
  );
	
end STR;