-- lab4_control_v3.vhd

use work.bv_arithmetic.all;
use work.dlx_types.all;

-- This entity chops up a 32-bit word into the relevant component parts.
-- If a particular output is not used for a particular instruction type
-- that field is set to zero. The input from the decoder is the instruction
-- register. It operates in a purely combinational-logic mode. The controller
-- makes use of its outputs when appropriate, ignores them otherwise.
-- For R-type ALU instruction format in Figure 2.27, 
-- reg0p1 is labelled "rs" in Figure 2.27, regOp2 is labelled "rt", and
-- regDest is labelled "rd".
-- For I-type ALU instruction format in Figure 2.27
-- regOp1 is "rs" and regDest is "rt"

entity mips_decoder is
  
  port (
    instruction : in dlx_word;
    regOp1,regOp2,regDest: out register_index;
    alu_func: out func_code; 
    immediate: out half_word;
    opcode: out opcode_type   
  ); 
end mips_decoder;

architecture behaviour of mips_decoder is

begin  -- behaviour

  process(instruction) is
  
  begin       
    opcode <= instruction (31 downto 26) after 5 ns;
    
    if (instruction (31 downto 26) = "000000") then  
      regOp1 <= instruction (25 downto 21) after 5 ns;
      regOp2 <= instruction (20 downto 16) after 5 ns;
      regDest <= instruction (15 downto 11) after 5 ns;
      alu_func <= instruction (5 downto 0) after 5 ns;
      immediate <= (others => '0') after 5 ns; 
      
    elsif(instruction(31 downto 26) = "100011") then 
      regOp1 <= instruction (25 downto 21) after 5 ns; 
      regOp2 <= (others => '0') after 5 ns;
      regDest <= instruction (20 downto 16) after 5 ns; 
      alu_func <= (others => '0') after 5 ns; 
      immediate <= instruction(15 downto 0) after 5 ns;
      
    elsif(instruction(31 downto 26) = "101011") then 
      regOp1 <= instruction (25 downto 21) after 5 ns; 
      regOp2 <= instruction(20 downto 16) after 5 ns; 
      regDest <= (others =>'0') after 5 ns; 
      alu_func <= (others => '0'); 
      immediate <= instruction(15 downto 0) after 5 ns;
       
    else 
      regOp1 <= instruction (25 downto 21) after 5 ns; 
      regOp2 <= (others => '0') after 5 ns; 
      regDest <= instruction(20 downto 16) after 5 ns; 
      alu_func <= (others => '0'); 
      immediate <= instruction(15 downto 0) after 5 ns;
    end if;
                    
  end process;                                 
end behaviour;

use work.bv_arithmetic.all;
use work.dlx_types.all;

-- This entity controls the DLX processor. It is driven by the external
-- clock signal, and takes inputs from the decoder also. It drives the
-- input of every latch on the chip, and the control input to every
-- mux, as well as sending function codes
-- to the ALU and processing ALU error codes

entity mips_controller is
 
  port (
    opcode: in  opcode_type;
    alu_func: in func_code;
    clock: in bit; 
    aluA_mux: out bit;
    aluB_mux: out bit;
    alu_oper: out alu_operation_code;
    alu_signed: out bit; 
    write_mux: out bit;
    ir_clock: out bit;
    IM_clock: out bit; 
    pc_clock: out bit;
    npc_clock: out bit;
    imm_clock: out bit;
    alu_out_clock: out bit; 
    lmd_clock: out bit; 
    regA_clock,regB_clock: out bit;
    DM_clock: out bit;
    DM_readnotwrite: out bit;
    reg_clock: out bit;
    reg_readnotwrite: out bit;
    regA_index_mux: out bit; 
    zero_out: in bit;
    cond_out: out bit 
    );
    
end mips_controller;

architecture behaviour of mips_controller is

begin  -- behaviour
  comb: process(opcode,alu_func) is
  begin
      if opcode = "000000" then
        if alu_func = "100000" then -- ADD
          aluA_mux <= '0' after 5 ns; 
          aluB_mux <= '1' after 5 ns; 
          alu_oper <= "0000" after 5 ns; 
          alu_signed <= '1' after 5 ns; 
          write_mux <= '0' after 5 ns; 
          cond_out <= '1' after 5 ns;
          
        elsif alu_func = "100001" then -- ADDU
          aluA_mux <= '0' after 5 ns; 
          aluB_mux <= '1' after 5 ns; 
          alu_oper <= "0000" after 5 ns;
          alu_signed <= '0' after 5 ns;   
          write_mux <= '0' after 5 ns; 
          cond_out <= '1' after 5 ns;
          
        elsif alu_func = "100010" then -- SUB
          aluA_mux <= '0' after 5 ns; 
          aluB_mux <= '1' after 5 ns; 
          alu_oper <= "0001" after 5 ns;
          alu_signed <= '1' after 5 ns; 
          write_mux <= '0' after 5 ns; 
          cond_out <= '1' after 5 ns;
                      
        elsif alu_func = "100011" then -- SUBU
          aluA_mux <= '0' after 5 ns; 
          aluB_mux <= '1' after 5 ns; 
          alu_oper <= "0001" after 5 ns;
          alu_signed <= '0' after 5 ns; 
          write_mux <= '0' after 5 ns; 
          cond_out <= '1' after 5 ns;
          
        elsif alu_func = "001110" then -- MUL
          aluA_mux <= '0' after 5 ns; 
          aluB_mux <= '1' after 5 ns; 
          alu_oper <= "1110" after 5 ns;
          alu_signed <= '1' after 5 ns; 
          write_mux <= '0' after 5 ns;
          cond_out <= '1' after 5 ns;
          
        elsif alu_func = "010110" then -- MULU
          aluA_mux <= '0' after 5 ns; 
          aluB_mux <= '1' after 5 ns;           
          alu_oper <= "1110" after 5 ns;
          alu_signed <= '0' after 5 ns; 
          write_mux <= '0' after 5 ns; 
          cond_out <= '1' after 5 ns;
          
        elsif alu_func = "100100" then -- AND
          aluA_mux <= '0' after 5 ns; 
          aluB_mux <= '1' after 5 ns;         
          alu_oper <= "0010" after 5 ns;
          alu_signed <= '1' after 5 ns; 
          write_mux <= '0' after 5 ns; 
          cond_out <= '1' after 5 ns;
          
        elsif alu_func = "100101" then -- OR
          aluA_mux <= '0' after 5 ns;
          aluB_mux <= '1' after 5 ns;          
          alu_oper <= "0011" after 5 ns;
          alu_signed <= '1' after 5 ns;          
          write_mux <= '0' after 5 ns; 
          cond_out <= '1' after 5 ns;
          
        elsif alu_func = "101010" then -- SLT
          aluA_mux <= '0' after 5 ns; 
          aluB_mux <= '1' after 5 ns; 
          alu_oper <= "" after 5 ns;
          alu_signed <= '0' after 5 ns;           
          write_mux <= '0' after 5 ns; 
          cond_out <= '1' after 5 ns;
          
        elsif alu_func = "101011" then -- SLTU
          aluA_mux <= '0' after 5 ns; 
          aluB_mux <= '1' after 5 ns; 
          alu_oper <= "" after 5 ns;
          alu_signed <= '1' after 5 ns;           
          write_mux <= '0' after 5 ns; 
          cond_out <= '1' after 5 ns;
        else 
        end if;
      elsif opcode = "001000" then -- ADDI
        aluA_mux <= '0' after 5 ns; 
        aluB_mux <= '0' after 5 ns;          
        alu_oper <= "0000" after 5 ns;
        alu_signed <= '1' after 5 ns;   
        write_mux <= '0' after 5 ns; 
        cond_out <= '1' after 5 ns;
      
      elsif opcode = "001001" then -- ADDUI
        aluA_mux <= '0' after 5 ns; 
        aluB_mux <= '0' after 5 ns; 
        alu_oper <= "0000" after 5 ns;
        alu_signed <= '0' after 5 ns; 
        write_mux <= '0' after 5 ns; 
        cond_out <= '1' after 5 ns;
        
      elsif opcode = "001010" then -- SUBI
        aluA_mux <= '0' after 5 ns; 
        aluB_mux <= '0' after 5 ns;
        alu_oper <= "0001" after 5 ns;
        alu_signed <= '1' after 5 ns;
        write_mux <= '0' after 5 ns; 
        cond_out <= '1' after 5 ns;
        
      elsif opcode = "001100" then -- ANDI
        aluA_mux <= '0' after 5 ns; 
        aluB_mux <= '0' after 5 ns; 
        alu_oper <= "0010" after 5 ns;
        alu_signed <= '0' after 5 ns; 
        write_mux <= '0' after 5 ns; 
        cond_out <= '1' after 5 ns;
        
      elsif opcode = "100011" then -- LW
        aluA_mux <= '0' after 5 ns; 
        aluB_mux <= '1' after 5 ns; 
        alu_oper <= "0000" after 5 ns; 
        alu_signed <= '0' after 5 ns;
        write_mux <= '1' after 5 ns;
        cond_out <= '1' after 5 ns;
        
      elsif opcode = "101011" then -- SW
        aluA_mux <= '0' after 5 ns; 
        aluB_mux <= '1' after 5 ns; 
        alu_oper <= "0000" after 5 ns; 
        alu_signed <= '0' after 5 ns; 
        write_mux <= '1' after 5 ns; 
        cond_out <= '1' after 5 ns;
      else
      end if;
      
  end process comb;
  behav: process(clock) is
     -- state of the machine 
     type state_type is range 1 to 5;                                
     variable state: state_type := 1;
                               
  begin                                
     if clock'event and clock = '1' then
       case state is 
         when 1 =>

            IM_clock <= '1' after 5 ns;
            ir_clock <= '1' after 5 ns;
            npc_clock <= '1' after 5 ns;

            regA_clock <= '0' after 5 ns;
            regB_clock <= '0' after 5 ns;
            imm_clock <= '0' after 5 ns;   

            alu_out_clock <= '0' after 5 ns;

            pc_clock <= '0' after 5 ns;
            lmd_clock <= '0' after 5 ns;
            DM_clock <= '0' after 5 ns;

            reg_clock <= '0' after 5 ns;


 
            reg_readnotwrite <= '1' after 5 ns; 
            regA_index_mux <= '0' after 5 ns; 
            DM_readnotwrite <= '1' after 5 ns; 

            state := 2;      
         when 2 =>

            IM_clock <= '0' after 5 ns;
            ir_clock <= '0' after 5 ns;
            npc_clock <= '0' after 5 ns;

            regA_clock <= '1' after 5 ns;
            regB_clock <= '1' after 5 ns;
            imm_clock <= '1' after 5 ns;   

            alu_out_clock <= '0' after 5 ns;

            pc_clock <= '0' after 5 ns;
            lmd_clock <= '0' after 5 ns;
            DM_clock <= '0' after 5 ns;

            reg_clock <= '0' after 5 ns;

            
 
            reg_readnotwrite <= '1' after 5 ns; 
            regA_index_mux <= '0' after 5 ns; 
            DM_readnotwrite <= '1' after 5 ns; 
            state := 3; 
         when 3 =>

            IM_clock <= '0' after 5 ns;
            ir_clock <= '0' after 5 ns;
            npc_clock <= '0' after 5 ns;

            regA_clock <= '0' after 5 ns;
            regB_clock <= '0' after 5 ns;
            imm_clock <= '0' after 5 ns;   

            alu_out_clock <= '1' after 5 ns;

            pc_clock <= '0' after 5 ns;
            lmd_clock <= '0' after 5 ns;
            DM_clock <= '0' after 5 ns;

            reg_clock <= '0' after 5 ns;

            reg_readnotwrite <= '1' after 5 ns; 
            regA_index_mux <= '0' after 5 ns; 
            
            if( opcode = "101011" ) then --SW
              DM_readnotwrite <= '0' after 5 ns; 
            else
              DM_readnotwrite <= '1' after 5 ns; 
            end if;

            state := 4; 
         when 4 =>

            IM_clock <= '0' after 5 ns;
            ir_clock <= '0' after 5 ns;
            npc_clock <= '0' after 5 ns;

            regA_clock <= '0' after 5 ns;
            regB_clock <= '0' after 5 ns;
            imm_clock <= '0' after 5 ns;   

            alu_out_clock <= '0' after 5 ns;
   
            pc_clock <= '1' after 5 ns;
            lmd_clock <= '1' after 5 ns;
            DM_clock <= '1' after 5 ns;

            reg_clock <= '0' after 5 ns;

            if( opcode = "000000" or opcode = "001000" or opcode = "001001" or opcode = "001010" or opcode = "001100" or opcode = "100011") then
              regA_index_mux <= '1' after 5 ns; 
              reg_readnotwrite <= '0' after 5 ns; 
              DM_readnotwrite <= '1' after 5 ns; 
            elsif( opcode = "101011" ) then --SW
              regA_index_mux <= '0' after 5 ns; 
              reg_readnotwrite <= '1' after 5 ns; 
              DM_readnotwrite <= '0' after 5 ns; 
            else
              regA_index_mux <= '0' after 5 ns; 
              reg_readnotwrite <= '1' after 5 ns; 
              DM_readnotwrite <= '1' after 5 ns; 
            end if;

            state := 5; 
         when 5 =>
 
            IM_clock <= '0' after 5 ns;
            ir_clock <= '0' after 5 ns;
            npc_clock <= '0' after 5 ns;

            regA_clock <= '0' after 5 ns;
            regB_clock <= '0' after 5 ns;
            imm_clock <= '0' after 5 ns;   

            alu_out_clock <= '0' after 5 ns;

            pc_clock <= '0' after 5 ns;
            lmd_clock <= '0' after 5 ns;
            DM_clock <= '0' after 5 ns;

            reg_clock <= '1' after 5 ns;

            if( opcode = "000000" or opcode = "001000" or opcode = "001001" or opcode = "001010" or opcode = "001100" or opcode = "100011") then
              regA_index_mux <= '1' after 5 ns; 
              reg_readnotwrite <= '0' after 5 ns;
            else
              regA_index_mux <= '0' after 5 ns;
              reg_readnotwrite <= '1' after 5 ns; 
            end if;
            DM_readnotwrite <= '1' after 5 ns; 
            state := 1; 
         when others => null;
       end case;
     else
       if clock'event and clock = '0' then 

       end if;
       
     end if;
  end process behav;                                 

end behaviour;






