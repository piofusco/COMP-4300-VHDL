-- dlx_datapath.vhd

package dlx_types is
  subtype dlx_word is bit_vector(31 downto 0); 
  subtype half_word is bit_vector(15 downto 0); 
  subtype byte is bit_vector(7 downto 0); 

  subtype alu_operation_code is bit_vector(3 downto 0); 
  subtype error_code is bit_vector(3 downto 0); 
  subtype register_index is bit_vector(4 downto 0);

  subtype opcode_type is bit_vector(5 downto 0);
  subtype offset26 is bit_vector(25 downto 0);
  subtype func_code is bit_vector(5 downto 0);
end package dlx_types; 

-----------------------------------------
-----------------------------------------
-----------------------------------------
use work.dlx_types.all; 
use work.bv_arithmetic.all;  

entity alu is 
     port(operand1, operand2: in dlx_word; operation: in alu_operation_code; 
          signed_in: in bit; result: out dlx_word; error_out: out error_code); 
end entity alu; 
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.dlx_types.all;
use work.bv_arithmetic.all;

architecture behaviour of alu is
	signal overFlow: boolean;
begin
	process(operand1, operand2, operation, signed_in)
		variable oper1: dlx_word;
		variable oper2: dlx_word;
		variable result_x: dlx_word;
		variable newOverFlow: boolean;
	begin
		oper1 := operand1;
		oper2 := operand2;

		-- Addition
		if(operation = "0000") then
			if(signed_in = '0') then
				bv_addu(oper1, oper2, result_x, newOverFlow);
			else
				bv_add(oper1, oper2, result_x, newOverFlow);
			end if;
		-- Subtraction
		elsif(operation = "0001") then
			if(signed_in = '0') then
				bv_subu(oper1, oper2, result_x, newOverFlow);
			else
				bv_sub(oper1, oper2, result_x, newOverFlow);
			end if;
		-- AND
		elsif(operation = "0010") then
			result_x := oper1 and oper2;
			newOverFlow := false;
		-- OR
		elsif(operation = "0011") then
			result_x := oper1 or oper2;
			newOverFlow := false;
		-- XOR
		elsif(operation = "0100") then
			result_x := oper1 xor oper2;
			newOverFlow := false;
		-- "<"
		elsif(operation = "1011") then
			if( bv_lt(oper1,oper2) = true ) then
				result_x := X"00000001";
			else
				result_x := X"00000000";
			end if;
		-- Multiplication
		elsif(operation = "1110") then
			if(signed_in = '0') then
				bv_multu(oper1, oper2, result_x, newOverFlow);
			else
				bv_mult(oper1, oper2, result_x, newOverFlow);
			end if;
		-- Default case
		else
			result_x := (others => '0');
			newOverFlow := false;
		end if;

		result <= result_x after 5 ns;

		--assign to the error code
		if( newOverFlow = true ) then
			error_out <= "0001" after 5 ns;
		else
			error_out <= "0000" after 5 ns;
		end if;

	end process;
end architecture behaviour;
-----------------------------------------
-----------------------------------------






-----------------------------------------
-----------------------------------------
use work.dlx_types.all; 

entity mips_zero is
  port (
    input  : in  dlx_word;
    output : out bit);
end mips_zero;
architecture behaviour of mips_zero is
begin
	combinational: process(input)
	begin
		if(input = "00000000000000000000000000000000") then
			output <= '1' after 5 ns;
		else
			output <= '0' after 5 ns;
		end if;
	end process combinational;
end architecture behaviour;
-----------------------------------------
-----------------------------------------









-----------------------------------------
-----------------------------------------
use work.dlx_types.all; 

entity mips_register is
     port(in_val: in dlx_word; clock: in bit; out_val: out dlx_word);
end entity mips_register;
library work;
use work.dlx_types.all;
use work.bv_arithmetic.all;

architecture behaviour of mips_register is
begin
	sequential: process(in_val,clock)
	begin
		if( clock = '1' ) then
			out_val <= in_val after 5 ns;
		end if;
	end process;
end architecture behaviour;
-----------------------------------------
-----------------------------------------








-----------------------------------------
-----------------------------------------
use work.dlx_types.all; 

entity mips_bit_register is
     port(in_val: in bit; clock: in bit; out_val: out bit);
end entity mips_bit_register;
library work;
use work.dlx_types.all;
use work.bv_arithmetic.all;

architecture behaviour of mips_bit_register is
begin
	sequential: process(in_val,clock)
	begin
		if( clock = '1' ) then
			out_val <= in_val after 5 ns;
		end if;
	end process;
end architecture behaviour;
-----------------------------------------
-----------------------------------------










-----------------------------------------
-----------------------------------------
use work.dlx_types.all; 

entity mux is
     port (input_1,input_0 : in dlx_word; which: in bit; output: out dlx_word);
end entity mux;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.dlx_types.all;
use work.bv_arithmetic.all;

architecture behaviour of mux is
begin
	combinational: process(input_1, input_0, which)
	begin
		if(which = '0' ) then
			output <= input_0 after 5 ns;
		else
			output <= input_1 after 5 ns;
		end if;
	end process;
end architecture behaviour;
-----------------------------------------
-----------------------------------------









-----------------------------------------
-----------------------------------------
use work.dlx_types.all;

entity index_mux is
     port (input_1,input_0 : in register_index; which: in bit; output: out register_index);
end entity index_mux;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.dlx_types.all;
use work.bv_arithmetic.all;

architecture behaviour of index_mux is
begin
	combinational: process(input_1, input_0, which)
	begin
		if(which = '0' ) then
			output <= input_0 after 5 ns;
		else
			output <= input_1 after 5 ns;
		end if;
	end process;
end architecture behaviour;
-----------------------------------------
-----------------------------------------











-----------------------------------------
-----------------------------------------
use work.dlx_types.all;

entity sign_extend is
     port (input: in half_word; signed_in: in bit; output: out dlx_word);
end entity sign_extend;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.dlx_types.all;
use work.bv_arithmetic.all;

architecture behaviour of sign_extend is
	  signal x: half_word;
  begin
	  Combinational: process(input,signed_in) is
		begin
			if( signed_in = '0' ) then
				x <= (others => '0');	
			else
				x <= (others => input(input'left));
			end if;

			output <= x & input after 5 ns;
		end process;
end architecture behaviour;
-----------------------------------------
-----------------------------------------









-----------------------------------------
-----------------------------------------
use work.dlx_types.all; 
use work.bv_arithmetic.all; 

entity add4 is
    port (input: in dlx_word; output: out dlx_word);
end entity add4;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

library work;
use work.dlx_types.all;
use work.bv_arithmetic.all;

architecture behaviour of add4 is
begin
	combinational: process(input) is
		variable y: std_logic_vector(input'range);
		variable x: integer;
		variable z: std_logic_vector(input'range);
	begin
		for i in input'range loop
			if( input(i) = '1') then
				y(i) := '1';
			else
				y(i) := '0';
			end if;
		end loop;
		x:= (conv_integer(y) + 4);
		z:= std_logic_vector(to_unsigned(x,z'length));

		for i in z'range loop
			if( z(i) = '1') then
				output(i) <= '1' after 5 ns;
			else
				output(i) <= '0' after 5 ns;
			end if;
		end loop;
	end process;
end architecture behaviour;
-----------------------------------------
-----------------------------------------










-----------------------------------------
-----------------------------------------
use work.dlx_types.all;
use work.bv_arithmetic.all;  

entity regfile is
     port (read_notwrite,clock : in bit; 
           regA,regB: in register_index; 
	   data_in: in  dlx_word; 
	   dataA_out,dataB_out: out dlx_word
	   );
end entity regfile; 


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.dlx_types.all;
use work.bv_arithmetic.all;

architecture behaviour of regfile is
	type MEMORY is array(0 to (2**(register_index'length))) of dlx_word;
	signal MEM: MEMORY;
begin
	process(read_notwrite,clock,regA,regB)
		variable std_lv_a: std_logic_vector(regA'range);
		variable std_lv_b: std_logic_vector(regB'range);
		variable address_a: integer range 0 to (2**(register_index'length)-1);
		variable address_b: integer range 0 to (2**(register_index'length)-1);
	begin
		for i in regA'range loop
			if( regA(i) = '1') then
				std_lv_a(i) := '1';
			else
				std_lv_a(i) := '0';
			end if;
		end loop;


		for i in regB'range loop
			if( regB(i) = '1') then
				std_lv_b(i) := '1';
			else
				std_lv_b(i) := '0';
			end if;
		end loop;

		address_a := conv_integer(std_lv_a);
		address_b := conv_integer(std_lv_b);

		if( read_notwrite = '1' ) then
			dataA_out <= MEM(address_a) after 5 ns;
			dataB_out <= MEM(address_b) after 5 ns;
		elsif( clock = '1') then
			MEM(address_a) <= data_in after 5 ns;
		end if;
	end process;
end architecture behaviour;
-----------------------------------------
-----------------------------------------













-----------------------------------------
-----------------------------------------
use work.dlx_types.all;
use work.bv_arithmetic.all;

entity DM is
  
  port (
    address : in dlx_word;
    readnotwrite: in bit; 
    data_out : out dlx_word;
    data_in: in dlx_word; 
    clock: in bit); 
end DM;

architecture behaviour of DM is
type memtype is array (0 to 1024) of dlx_word;
signal data_memory : memtype;
signal init: bit :='0';
begin  -- behaviour

  DM_behav: process(address,clock) is
    --type memtype is array (0 to 1024) of dlx_word;
    --variable data_memory : memtype;
  begin
    if(init = '0' ) then
      -- fill this in by hand to put some values in there
      data_memory(1023) <= B"00000101010101010101010101010101";
      data_memory(0) <= B"00000000000000000000000000000001";
      data_memory(1) <= B"00000000000000000000000000000010";
      init <= '1';
    end if;
    if clock'event and clock = '1' then
      if readnotwrite = '1' then
        -- do a read
        data_out <= data_memory(bv_to_natural(address)/4);
      else
        -- do a write
        data_memory(bv_to_natural(address)/4) <= data_in; 
      end if;
    end if;


  end process DM_behav; 

end behaviour;
-----------------------------------------
-----------------------------------------













-----------------------------------------
-----------------------------------------
use work.dlx_types.all;
use work.bv_arithmetic.all;

entity IM is
  
  port (
    address : in dlx_word;
    instruction : out dlx_word;
    clock: in bit); 
end IM;

architecture behaviour of IM is

begin  -- behaviour

  IM_behav: process(address,clock) is
    type memtype is array (0 to 1024) of dlx_word;
    variable instr_memory : memtype;                   
  begin
    -- I basically turned this portion of code into a driver to test the instructions. See attached
	-- readme for further explanations.
	
	  -- LW
    -- first instr is 'LW R1,4092(R0)' 
    instr_memory(0) := B"10001100000000010000111111111100"; -- load whatever is in 1023 into R1
					--	 100011/00000/00001/0000111111111100
	  -- ADD
    -- next instr is 'ADD R1,R1,R2'
	  -- 1 + 1 = alu_result = 2
    instr_memory(1) := B"00000000001000010001000000100000"; -- add it to itself back into R2
                      -- 000000/00001/00001/00001/00000100000
    -- ADDU
    -- next instr is 'ADDU R1,R2,R1'
	  -- 1 + 1 = alu_result = 2
    instr_memory(2) := B"00000000001000010001000000100001"; -- add it to itself back into R2
                       --000000/00001/00001/00001/00000100001
    -- ADDI
    -- $t = $s + imm; advance_pc (4);
    -- addi $t, $s, imm
    -- 1 + 1 = alu_result = 2
    instr_memory(3) := B"00100000001000010000000000000001"; -- add it to itself back into R2
                      -- 001000/00001/00001/0000000000000001                   
    -- ADDUI
    -- $t = $s + imm; advance_pc (4);
    -- addui $t, $s, imm
    -- 1 + 1 = aluA_mux_out = 2
    instr_memory(4) := B"00101000001000010000000000000001"; -- add it to itself back into R2
                      -- 001010/00001/00001/0000000000000001              
    -- SUB 
    -- $d = $s - $t; advance_pc (4);
    -- sub $d, $s, $t
    -- 1 - 1 = alu_result = 0
    instr_memory(5) := B"00000000001000010001000000100010"; -- subtract
                      -- 000000/00001/00001/00001/00000100010       
    -- SUBI
    -- $t = $s + imm; advance_pc (4);
    -- addi $t, $s, imm
    -- 1 - 1 = aluA_result = 0
    instr_memory(6) := B"00000000001000010000000000000001"; -- add it to itself back into R2
                      -- 000000/00001/00001/0000000000000001                
    -- SUBU
    -- next instr is 'SUBU R1,R2,R1'
	  -- 1 - 1 = alu_result = 0
    instr_memory(7) := B"00000000001000010000100000100011"; -- 
                      -- 000000/00001/00001/00001/00000100011              
    -- MUL
    -- $LO = $s * $t; advance_pc (4);
    -- mulu $s, $t
	  -- 1 * 3 = alu_result = 3
    instr_memory(8) := B"00000000011000010000000000011000"; -- 
                      -- 000000/00011/00001/00000/0000 0000 0001 1000
    -- MULU
    -- $LO = $s * $t; advance_pc (4);
    -- mulu $s, $t
	  -- 1 * 3 = alu_result = 2
    instr_memory(9) := B"00000000011000010000100000011001"; -- 
                      -- 000000/00011/00001/00010/00000011001    
    -- AND
    -- $d = $s & $t; advance_pc (4);
    -- and $d, $s, $t
    instr_memory(10) := B"00000011111111110001000000100000"; 
                      --  000000/11111/11111/00010/00000100000
    -- ANDI
    -- $t = $s & imm; advance_pc (4);
    -- andi $t, $s, imm
    instr_memory(11) := B"00100011111000000000001010101010"; 
                      --  001000/11111/11111/11111111111111       
    -- OR
    -- next instr is 'OR R1,R2,R1'
    instr_memory(12) := B"00000011111000000001000000100101"; 
                      --  000000/11111/00000/00010/00000100101      
    -- SLT
    -- next instr is 'SLT R1,R2,R1'
    instr_memory(13) := B"00000000001000010001000000101010"; 
                      --  000000/00001/00001/00010/00000101010
    -- SLTU
    -- next instr is 'SLTU R1,R2,R1'
    instr_memory(14) := B"00000000001000010001000000101011"; 
                      --  000000/00001/00001/00010/00000101011              
    -- SW
    -- next instr is SW R2,8(R0)'
    instr_memory(15) := B"10101100000000100000000000001000";
    
    if clock'event and clock = '1' then
        -- do a read
        instruction <= instr_memory(bv_to_natural(address)/4);
    end if;
  end process IM_behav; 

end behaviour;
-----------------------------------------
-----------------------------------------