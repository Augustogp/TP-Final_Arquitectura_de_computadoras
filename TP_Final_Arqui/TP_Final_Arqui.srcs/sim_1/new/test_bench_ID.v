`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.07.2021 21:10:45
// Design Name: 
// Module Name: test_bench_ID
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

/*
addi 0,1,5 ; reg[0] = reg[1] + 5 
sw 0,10(0) ; memory[reg[10] + 0] = reg[0] 
addi 0,0,5 ; reg[0] = reg[0] + 5
lw 2,10(0); reg[2] = memory[reg[10]+0]
sub 3,0,2 ; reg[3] = reg[0] - reg[2]
srl 4,3,2 ; reg[4] = reg[3] >> 2
beq 4,3,2 ; if(reg[3]==reg[4])jump pc+2
j 6 ; jump 6
slt 5,3,4 ; reg[5]=(reg[3]<reg[4])
jalr 6,2 ; reg[6] = return address  ; jump reg[2]
srav 7,3,0 ; reg[3] >> reg[0]
xori 8,6,7 ; reg[8] = reg[6] xori reg[7]
*/
`define OPCODE_SBIT 26
`define OPCODE_WIDTH 6              //Instruction opcode segment width
`define CLK_PERIOD      10

`define INST_OPCODE offset[`OPCODE_SBIT + `OPCODE_WIDTH -1 : `OPCODE_SBIT]

module test_bench_ID();
    
    //Parameters
    parameter PC_WIDTH = 32;
    parameter INST_WIDTH = 32;
    parameter RD_WIDTH = 5;
    parameter RT_WIDTH = 5;
    parameter RS_WIDTH = 5;
    parameter REGISTERS_WIDTH = 32;
    parameter INST_MEMORY_DEPTH = 64;
    
    //Inputs
    reg clk,reset;
    reg ID_write_in;
    reg [PC_WIDTH - 1 :0] pc_adder_in;
    reg [INST_WIDTH - 1 :0] instruction;
    reg [RD_WIDTH - 1 : 0] Write_addr;
    reg [REGISTERS_WIDTH - 1 :0] Write_data;
    
    //Control signal inputs
    reg RegWrite_in, Branch_in, Zero_in, control_enable;
    
    //Outputs
    wire [REGISTERS_WIDTH - 1 :0] Read_data1,Read_data2;
    wire [REGISTERS_WIDTH - 1 :0] offset;
    wire [RT_WIDTH - 1 :0] rt;
    wire [RD_WIDTH - 1 :0] rd;
    wire [RS_WIDTH - 1 :0] rs;
    wire [PC_WIDTH - 1 :0] pc_adder;
    
    //control signal outputs
    wire Branch, MemRead, MemWrite, RegWrite;
    wire [2:0] Aluop;
    wire [1:0] AluSrc,regDst,MemtoReg,pc_src;
    
    //Test Variables
    reg [INST_WIDTH-1:0] ram [INST_MEMORY_DEPTH-1:0]  ;
    integer i;

    always #`CLK_PERIOD clk = !clk;
	
	initial
	begin
        $readmemh("out.txt",ram);
        clk =          1'b0;
        reset =        1'b1;
        Write_addr = 'h10 ;
        Write_data = 'h20;
        pc_adder_in = 13;
        i = 0;
        control_enable = 1'b1;
        RegWrite_in = 1'b0;
        Branch_in = 1'b0;
        Zero_in = 1'b0;
        ID_write_in = 1'b0;
        @(negedge clk) #1;   
        reset = 1'b0;
        ID_write_in = 1'b1;
            while(ram[i] == ram[i])
            begin
                   instruction = ram[i];
                   @(negedge clk)#1;
                   i = i + 1 ;
              end
        @(negedge clk) #1; 
        $finish;
	end
    
    ID_top ID_top (
        
        //inputs
        .top2_clock(clk),
        .top2_reset(reset),
        .top2_pc_adder_in(pc_adder_in),
        .top2_instruction_in(instruction),
        .top2_wr_addr(Write_addr),
        .top2_wr_data(Write_data),
        .top2_ID_write_in(ID_write_in),
        //control inputs
        .top2_reg_wr_in(RegWrite_in),
        .top2_zero_in(Zero_in),
        .top2_control_enable(control_enable),
        .top2_branch_in(Branch_in),
        
        //outputs
        .top2_read_data1_out(Read_data1),
        .top2_read_data2_out(Read_data2),
        .top2_offset_out(offset),
        .top2_rt_out(rt),
        .top2_rd_out(rd),
        .top2_rs_out(rs),
        .top2_pc_adder_out(pc_adder),
        
        //control signal outputs
        .top2_reg_wr_out(RegWrite),
        .top2_branch_out(Branch),
        .top2_mem_rd_out(MemRead),
        .top2_mem_wr_out(MemWrite),
        .top2_reg_dst_out(regDst),
        .top2_alu_op_out(Aluop),
        .top2_alu_src_out(AluSrc),
        .top2_mem_to_reg_out(MemtoReg),
        .top2_pc_src_out(pc_src)
    );
    
    
endmodule
