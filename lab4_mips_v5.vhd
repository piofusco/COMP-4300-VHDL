-- lab4_mips_v5.vhd

use work.dlx_types.all;

entity mips is
  port (
    mips_clock: in bit);                 -- should have 200 ns square period
end mips;

architecture struct of mips is 
   signal pc_out,                       -- these are the busses and wires
       add4_out,                        -- that connect the parts of the
       im_out,                          -- chip. You should draw the data
       npc_out,                         -- path from the info in this file. 
       ir_out,                          -- It should be very similar to
       pc_in,                           -- Figure 3.1
       regA_in,
       regB_in,
       regA_out,
       regB_out,
       sext_out,
       Imm_out,
       aluA_mux_out,
       aluB_mux_out,
       alu_result,
       alu_out,
       DM_out,
       lmd_out,
       lmd_mux_out : dlx_word;
    
    signal
      regA_index, regB_index, Dest_index, regA_index_mux_out: register_index;
    signal immediate: half_word; 
    signal alu_func: func_code;
    signal alu_oper : alu_operation_code;
    signal alu_error: error_code; 
    signal opcode : opcode_type;
    signal zero_out,
       cond_out,
       aluA_mux,
       aluB_mux,
       write_mux,
       ir_clock,
       IM_clock,
       pc_clock,
       npc_clock,
       imm_clock,
       alu_out_clock,
       alu_signed,
       lmd_clock,
       regA_clock,
       regB_clock,
       regA_index_mux,
       DM_clock,
       DM_readnotwrite,
       reg_clock,
       reg_readnotwrite
       : bit;

   
begin  -- struct of mips
  mips_decode: entity work.mips_decoder(behaviour)  -- Instruction Decoder
    port map (
      instruction => ir_out,   
      regOp1 => regA_index,
      regOp2 => regB_index,
      regDest => Dest_index,
      alu_func => alu_func,
      immediate => immediate,
      opcode => opcode);

     
  mips_ctl: entity work.mips_controller(behaviour)  --  controller
    port map (
      opcode => opcode,
      alu_func => alu_func,
      clock => mips_clock,
      aluA_mux => aluA_mux,
      aluB_mux => aluB_mux,
      alu_oper => alu_oper,
      alu_signed => alu_signed, 
      write_mux => write_mux,
      ir_clock => ir_clock,
      IM_clock => IM_clock,
      pc_clock => pc_clock,
      npc_clock => npc_clock,
      imm_clock => imm_clock,
      alu_out_clock => alu_out_clock,
      lmd_clock => lmd_clock,
      regA_clock => regA_clock,
      regB_clock => regB_clock,
      regA_index_mux => regA_index_mux,
      DM_clock => DM_clock,
      DM_readnotwrite => DM_readnotwrite,
      reg_clock => reg_clock,
      reg_readnotwrite => reg_readnotwrite,
      zero_out => zero_out,
      cond_out =>cond_out
      ); 

  -- this mux is not in Fig. 3.1. The input to the regA port of the
  -- register file can come
  -- either from a source or a dest field in the IR, depending
  -- on whether the instruction is a load or something else 
  
  mips_regA_index_mux: entity work.index_mux(behaviour) 
      port map (
        input_0 => regA_index,
        input_1 => Dest_index,
        which  => regA_index_mux,
        output => regA_index_mux_out); 

  -- The Instruction Memory 
  
  mips_IM: entity work.IM(behaviour)
    port map (
      address     => pc_out,
      instruction => IM_out,
      clock       => IM_clock); 

  -- The Data Memory
  
  mips_DM: entity work.DM(behaviour)
    port map (
      address      => alu_out,
      readnotwrite => DM_readnotwrite,
      data_out     => DM_out,
      data_in      => regB_out,
      clock        => DM_clock); 

  -- The Instruction Register
  
  mips_ir: entity work.mips_register(behaviour)
    port map(
      in_val => IM_out,
      clock => ir_clock, 
      out_val => ir_out);

  -- The Program Counter (PC)
  
  mips_pc: entity work.mips_register(behaviour)
    port map(
      in_val => pc_in,
      clock => pc_clock, 
      out_val => pc_out);

  -- Next  Program Counter (NPC)
  
  mips_npc: entity work.mips_register(behaviour)
    port map(
      in_val => add4_out,
      clock => npc_clock, 
      out_val => npc_out);

  -- The unit that adds 4 to the PC value
  
  mips_add4: entity work.add4(behaviour)
    port map (
      input  => pc_out,
      output => add4_out); 

  -- Register File
  
  mips_regfile: entity work.regfile(behaviour)
     port map (
       read_notwrite => reg_readnotwrite,
       clock         => reg_clock,
       regA          => regA_index_mux_out,
       regB          => regB_index,
       data_in       => lmd_mux_out,
       dataA_out     => regA_in,
       dataB_out     => regB_in); 

  -- Sign Extender
  
  mips_sext: entity work.sign_extend(behaviour)
    port map( 
      input => immediate,
      signed_in => alu_signed,
      output => sext_out);


  -- Immediate Value Register (Imm) 
  mips_Imm: entity work.mips_register(behaviour)
    port map(
      in_val => sext_out,
      clock => Imm_clock, 
      out_val => Imm_out);


  -- The A register between regfile and ALU
  
  mips_regA: entity work.mips_register(behaviour)
    port map(
      in_val => regA_in,
      clock => regA_clock, 
      out_val => regA_out);


  -- The B register between regfile and ALU
 
  mips_regB: entity work.mips_register(behaviour)
    port map(
      in_val => regB_in,
      clock => regB_clock, 
      out_val => regB_out);


  -- Controls where A register data comes from
  
  mips_aluA_mux: entity work.mux(behaviour) 
    port map (
      input_1 => npc_out, 
      input_0 => regA_out,
      which   => aluA_mux,
      output  => aluA_mux_out); 

  -- Controls where B register data comes from
  
  mips_aluB_mux: entity work.mux(behaviour) 
    port map (
      input_1 => regB_out,
      input_0 => Imm_out,
      which   => aluB_mux,
      output  => aluB_mux_out); 


  -- The ALU
  
  mips_alu: entity work.alu(behaviour)
    port map (
      operand1 => aluA_mux_out,
      operand2 => aluB_mux_out,
      operation => alu_oper,
      signed_in => alu_signed, 
      result => alu_result,
      error_out => alu_error); 

  -- Computes whether a value is zero or not (used in conditional jumps)
  
  mips_zero: entity work.mips_zero(behaviour)
      port map (
        input  => regA_out,
        output => zero_out); 


  -- Register to hold output of ALU 

  mips_alu_out: entity work.mips_register(behaviour)
    port map(
      in_val => alu_result,
      clock => alu_out_clock, 
      out_val => alu_out);


  -- Register to hold data read from memory on a load instruction
  
  mips_lmd: entity work.mips_register(behaviour)
    port map (
        in_val  => dm_out,
        clock   => lmd_clock,
        out_val => lmd_out); 

  -- mux to route correct next address to PC
  
  mips_cond_mux: entity work.mux(behaviour) 
    port map (
      input_1 => npc_out,
      input_0 => alu_out,
      which   => cond_out,
      output  => pc_in); 

  -- mux to control write-back of a memory value after a load, or output
  -- from ALU after anything else
 
  mips_write_mux: entity work.mux(behaviour) 
    port map (
      input_1 => lmd_out, input_0 => alu_out, which => write_mux,
      output => lmd_mux_out
      );

end struct;

