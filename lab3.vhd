
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.dlx_types.all;
use work.bv_arithmetic.all;

entity dlx_register is
	     port(in_val: in dlx_word;
			  clock: in bit;
			  out_val: out dlx_word); 
end entity dlx_register; 


architecture mips of dlx_register is
begin
	sequential: process(in_val,clock)
	begin
		if( clock = '1' ) then
			out_val <= in_val after 5 ns;
		end if;
	end process;
end architecture mips;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.dlx_types.all;
use work.bv_arithmetic.all;

entity mux is
	     port (input_1,input_0 : in dlx_word;
			   which: in bit;
			   output: out dlx_word);
end entity mux;

architecture mips of mux is
begin
	combinational: process(input_1,input_0,which)
	begin
		if(which = '0' ) then
			output <= input_0 after 5 ns;
		else
			output <= input_1 after 5 ns;
		end if;
	end process;
end architecture;


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.dlx_types.all;
use work.bv_arithmetic.all;

entity sign_extend is
	port (input: in half_word;
		  output: out dlx_word);
end entity sign_extend;

architecture mips of sign_extend is
signal x: half_word;
begin
	x <= (others => input(input'left)) after 5 ns;
	output <= x & input after 5 ns;
end architecture mips;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

library work;
use work.dlx_types.all;
use work.bv_arithmetic.all;

entity add4 is
	port (input: in dlx_word; output: out dlx_word);
end entity add4;

architecture mips of add4 is
begin
	combinational: process(input) is
		  variable x: std_logic_vector(input'range);
		  variable y: integer;
		  variable z: std_logic_vector(input'range);
		  begin
		    for i in input'range loop
		      if (input(i) = '1') then
		        x(i):='1';
		      else
		        x(i):='0';
		      end if;
		    end loop;
		    
		    y:= (conv_integer(x) + 4);
		    z:= std_logic_vector(to_unsigned(y,z'length));
		    
		    for i in output'range loop
		      if (z(i) = '1') then
		        output(i) <= '1' after 5 ns;
		      else
		        output(i) <= '0' after 5 ns;
		      end if;
		    end loop;
		    
	end process;
end architecture mips;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

library work;
use work.dlx_types.all;
use work.bv_arithmetic.all;

entity regfile is
	     port (read_notwrite,clock : in bit; 
		        regA,regB: in register_index; 
		        data_in: in dlx_word; 
		    	   dataA_out,dataB_out: out dlx_word);
end entity regfile; 

architecture mips of regfile is
	type MEMORY is array(0 to (2**(register_index'length))) of dlx_word;
	signal MEM: MEMORY;
begin
	process(read_notwrite,clock,regA,regB)
		variable address_a: integer range 0 to (2**(register_index'length)-1);
		variable address_b: integer range 0 to (2**(register_index'length)-1);
	  variable x: std_logic_vector (regA'range);
	  variable y: std_logic_vector (regB'range);
	begin
	  for i in x'range loop
		      if (regA(i) = '1') then
		        x(i):='1';
		      else
		        x(i):='0';
		      end if;
		end loop;
		
		for i in y'range loop
		      if (regB(i) = '1') then
		        y(i):='1';
		      else
		        y(i):='0';
		      end if;
		end loop;
	  
		address_a := conv_integer(x);
		address_b := conv_integer(y);

		if( read_notwrite = '1' ) then
			dataA_out <= MEM(address_a) after 5 ns;
			dataB_out <= MEM(address_b) after 5 ns;
		elsif (clock = '1') then
			MEM(address_a) <= data_in after 5 ns;
		end if;
	end process;
end architecture mips;


		







