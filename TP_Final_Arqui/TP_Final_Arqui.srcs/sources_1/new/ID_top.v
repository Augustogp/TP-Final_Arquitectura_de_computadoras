`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.07.2021 13:18:15
// Design Name: 
// Module Name: ID_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ID_top#(
        
        parameter   N_BITS_PC = 32,         // Bits del PC
        parameter   N_BITS_INST = 32,       // Bits de instruccion
        parameter   N_BITS_RD = 5,
        parameter   N_BITS_RT = 5,
        parameter   N_BITS_RS = 5,
        parameter   N_BITS_REG = 32,        // Bits de registros
        parameter   N_BITS_ALUOP = 4,
        parameter   N_BITS_OFFSET = 16,
        parameter   N_BITS_FUNCTION = 6,
        parameter   N_BITS_OPCODE = 6,
        parameter   RS_SBIT = 21,
        parameter   RT_SBIT = 16,
        parameter   RD_SBIT = 11,
        parameter   OFFSET_SBIT = 0,
        parameter   FUNCTION_SBIT = 0,
        parameter   OPCODE_SBIT = 26
        
    )
    (
        // Inputs
        input   wire                        top2_clock,
        input   wire                        top2_reset,
        input   wire [N_BITS_PC - 1 : 0]    top2_pc_adder_in,
        input   wire [N_BITS_INST - 1 : 0]  top2_instruction_in,
        input   wire [N_BITS_RD - 1 : 0]    top2_wr_addr,     // Direccion de escritura de instruccion
        input   wire [N_BITS_REG - 1 : 0]   top2_wr_data,     // Instruccion a escribir en memoria de instrucciones
        input   wire                        top2_reg_wr_in, top2_branch_in, top2_zero_in, top2_control_enable, top2_ID_write_in,
        
        //Outputs
        output reg [N_BITS_PC - 1 :0]       top2_pc_adder_out,   
        output reg [N_BITS_REG - 1 :0]      top2_read_data1_out, top2_read_data2_out,     // Actual instruccion que sale de la memoria de instrucciones   
        output reg [N_BITS_REG - 1 :0]      top2_offset_out,
        output reg [N_BITS_RT - 1 :0]       top2_rt_out,
        output reg [N_BITS_RD - 1 :0]       top2_rd_out,
        output reg [N_BITS_RS - 1 :0]       top2_rs_out,
        output reg                          top2_branch_out, top2_mem_rd_out, top2_mem_wr_out, top2_reg_wr_out,
        output reg [N_BITS_ALUOP - 1 :0]    top2_alu_op_out,
        output reg [1 :0]                   top2_alu_src_out, top2_reg_dst_out,
        output reg [1 :0]                   top2_mem_to_reg_out,
        output wire [1 :0]                   top2_pc_src_out,
        output                              top2_IF_ID_reset,
        output                              top2_EX_MEM_reset
    );
    
    //Modules outputs (ID/EX register inputs)
    wire [N_BITS_REG - 1 :0] top2_read_data1, top2_read_data2;
    wire [N_BITS_REG - 1 :0] top2_offset;
    //Control signals output
    wire [N_BITS_ALUOP -1:0] top2_alu_op;
    wire [1:0] top2_alu_src, top2_mem_to_reg,top2_reg_dst;
    wire top2_branch, top2_mem_rd, top2_mem_wr, top2_reg_wr;
    
    //ID and EX registers
    always@(posedge top2_clock)
    begin
        if(top2_reset)
        begin
            top2_read_data1_out     <= 0;
            top2_read_data2_out     <= 0;
            top2_offset_out         <= 0;
            
            top2_reg_wr_out         <= 0;       //ID
            top2_alu_src_out        <= 0;      //EX
            top2_alu_op_out         <= 0;
            top2_reg_dst_out        <= 0;
            top2_mem_rd_out         <= 0;
            top2_mem_wr_out         <= 0;
            top2_branch_out         <= 0;
            top2_mem_to_reg_out     <= 0;
        end
        else if(top2_ID_write_in)
        begin
            top2_read_data1_out     <= top2_read_data1;
            top2_read_data2_out     <= top2_read_data2;
            top2_offset_out         <= top2_offset;
            
            top2_rt_out             <= top2_instruction_in[RT_SBIT + N_BITS_RT - 1 : RT_SBIT];
            top2_rd_out             <= top2_instruction_in[RD_SBIT + N_BITS_RD - 1 : RD_SBIT];
            top2_rs_out             <= top2_instruction_in[RS_SBIT + N_BITS_RS - 1 : RS_SBIT];
            top2_pc_adder_out       <= top2_pc_adder_in;
            
            top2_reg_wr_out         <= top2_reg_wr;       //ID
            top2_alu_src_out        <= top2_alu_src;      //EX
            top2_alu_op_out         <= top2_alu_op;
            top2_reg_dst_out        <= top2_reg_dst;
            top2_mem_rd_out         <= top2_mem_rd;       //MEM
            top2_mem_wr_out         <= top2_mem_wr;
            top2_branch_out         <= top2_branch;
            top2_mem_to_reg_out     <= top2_mem_to_reg;   //WB
        end
        else
        begin
            top2_read_data1_out     <= top2_read_data1_out;
            top2_read_data2_out     <= top2_read_data2_out;
            top2_offset_out         <= top2_offset_out;
            
            top2_rt_out             <= top2_rt_out;
            top2_rd_out             <= top2_rd_out;
            top2_rs_out             <= top2_rs_out;
            top2_pc_adder_out       <= top2_pc_adder_out;
            
            top2_reg_wr_out         <= top2_reg_wr_out;       //ID
            top2_alu_src_out        <= top2_alu_src_out;      //EX
            top2_alu_op_out         <= top2_alu_op_out;
            top2_reg_dst_out        <= top2_reg_dst_out;
            top2_mem_rd_out         <= top2_mem_rd_out;       //MEM
            top2_mem_wr_out         <= top2_mem_wr_out;
            top2_branch_out         <= top2_branch_out;
            top2_mem_to_reg_out     <= top2_mem_to_reg_out;   //WB
        end
    end
    
    Banco_Registros Registers
    (
        //Inputs
        .i_clock(top2_clock), 
        .i_reset(top2_reset), 
        .i_control_wr(top2_reg_wr_in), 
        .i_enable(top2_ID_write_in),
        .i_ra(top2_instruction_in[RS_SBIT + N_BITS_RS - 1 : RS_SBIT]), 
        .i_rb(top2_instruction_in[RT_SBIT + N_BITS_RT - 1 : RT_SBIT]), 
        .i_reg_wr(top2_wr_addr),
        .i_data_wr(top2_wr_data),
        
        //Outputs        
        .o_read_data1(top2_read_data1), 
        .o_read_data2(top2_read_data2) 
    );
    
    Extension_Signo Sign_Extension
    (
        .i_sign_extension(top2_instruction_in[OFFSET_SBIT + N_BITS_OFFSET - 1 : OFFSET_SBIT]),
   
        .o_sign_extension(top2_offset)   
    );
    
    Control Control
    (
        //Input 
        .control_enable(top2_control_enable),
        .i_zero(top2_zero_in), 
        .i_branch(top2_branch_in),
        .i_opcode(top2_instruction_in[OPCODE_SBIT + N_BITS_OPCODE - 1 : OPCODE_SBIT]),
        .i_function(top2_instruction_in[FUNCTION_SBIT + N_BITS_FUNCTION - 1 : FUNCTION_SBIT]),
        
        //Output
        .o_reg_wr(top2_reg_wr),
        .o_reg_dst(top2_reg_dst),
        .o_branch(top2_branch),
        .o_mem_rd(top2_mem_rd), 
        .o_mem_wr(top2_mem_wr),
        .o_alu_src(top2_alu_src),
        .o_pc_src(top2_pc_src_out),
        .o_alu_op(top2_alu_op),
        .o_mem_to_reg(top2_mem_to_reg),
        .if_id_reset(top2_IF_ID_reset),
        .ex_mem_reset(top2_EX_MEM_reset)  
    );
    
    
endmodule
