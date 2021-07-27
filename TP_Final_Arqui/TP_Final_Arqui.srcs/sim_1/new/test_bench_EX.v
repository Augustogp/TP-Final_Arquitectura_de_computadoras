`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.07.2021 19:27:16
// Design Name: 
// Module Name: test_bench_EX
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
`define INST_FUNCTION offset[6 - 1 : 0]
`define RTYPE_ALUCODE   'b0000//for RTYPE instructions ,map to ARITH operation ,specified in function segment of instruction
`define ORI_ALUCODE     'b0011//for ORI instruction ,map to OR operation
`define ADD_FUNCTIONCODE   'b100000

module test_bench_EX();
    
    //Test Parameters
    parameter PC_WIDTH = 32;
    parameter REGISTERS_WIDTH = 32;
    parameter REGISTERS_DEPTH = 32;
    parameter REGISTERS_ADDR_WIDTH = $clog2(REGISTERS_DEPTH);
    parameter RD_WIDTH = 5;
    parameter RT_WIDTH = 5;
    parameter ALUOP_WIDTH = 4;
    parameter CLK_PERIOD = 4;
    
    //Inputs
    reg clk,reset;
    reg [PC_WIDTH - 1 :0] pc_adder_in;
    reg [REGISTERS_WIDTH - 1 :0] offset;
    reg [REGISTERS_WIDTH - 1 :0] Read_data1,Read_data2_in;
    reg [RD_WIDTH - 1 : 0]rd;
    reg [RT_WIDTH - 1 : 0]rt;
    reg [REGISTERS_WIDTH - 1 :0] MEM_WB_Alu_result;
    reg [1:0] operand1_hazard,operand2_hazard;
    
    //Control signal inputs
    reg [1:0] RegDst;
    reg [1:0] AluSrc;
    reg [ALUOP_WIDTH - 1 : 0] Aluop;
    
    //Outputs
    wire [PC_WIDTH - 1 :0] pc_adder;
    wire [REGISTERS_WIDTH - 1 :0] Read_data2;
    wire [REGISTERS_ADDR_WIDTH - 1 :0] Write_addr;
    wire [REGISTERS_WIDTH - 1 :0] EX_MEM_Alu_result;
    //control signal outputs
    wire Branch,MemRead,MemWrite,Zero;
    wire [1:0] MemtoReg;
    
    always #CLK_PERIOD clk = !clk;
	
	initial begin
        
        clk =          1'b0;
        reset =        1'b1;
        
        @(negedge clk) #1;   
        reset =        1'b0;
        @(negedge clk) #1;  
        pc_adder_in = 15;
        Read_data1 = 1;
        Read_data2_in = 2;
        MEM_WB_Alu_result = 5;
        operand1_hazard = 'b00;
        operand2_hazard = 'b00;
        offset = 0;
        rd = 5;
        rt = 6;                 // 1 ADD 2 = 3
        
        //control signals
        RegDst = 0;//write addr <- rt
        Aluop = `RTYPE_ALUCODE;//Rtype instruction ,add alu operation
        `INST_FUNCTION = `ADD_FUNCTIONCODE;
        AluSrc[0] = 1'b0;//operand 1 <- Read_data1
        AluSrc[1] = 1'b0;//operand 2 <- Read_data2
        @(negedge clk) #1;
    
        @(negedge clk) #1;      // 1 ORI 8 = 9 
        RegDst = 0;//write addr <- rt
        Aluop = `ORI_ALUCODE;//Itype instruction ,ori alu operation
        offset = 8;
        AluSrc[0] = 1'b0;//operand 1 <- Read_data1 (1)
        AluSrc[1] = 1'b1;//operand 2 <- offset (8) 
        @(negedge clk) #1;   // 1 ORI 10 = 11
        offset = 10;
        @(negedge clk) #1; // b ORI 5 = 15
        offset = 12;
        operand1_hazard = 'b01;//operand 1 <-EX/MEM Alu_result (b)
        operand2_hazard = 'b10;//operand 2 <-MEM/WB Alu_result (5)
        @(negedge clk) #1;
        reset = 1;          //reset module
        @(negedge clk) #1;
        reset = 0;
        $finish;
	end
	
	EX_top EX_top (
        
        //inputs
        .top3_clock(clk),
        .top3_reset(reset),
        .top3_pc_sumador_in(pc_adder_in),
        .top3_offset(offset),
        .top3_read_data1_in(Read_data1),
        .top3_read_data2_in(Read_data2_in),
        .top3_rt_in(rt),
        .top3_rd_in(rd),
        .top3_op1_corto(operand1_hazard),
        .top3_op2_corto(operand2_hazard),
        .top3_Mem_Wb_Write_data(MEM_WB_Alu_result),
        
        //control signals in
        .top3_mux3_control(RegDst),
        .top3_Alu_control_oper(Aluop),
        .top3_mux1_2_control(AluSrc),
        .MemRead_in('b0),//control signals not used in this stage
        .MemWrite_in('b0),
        .Branch_in('b0),
        .MemtoReg_in('b0),
        
        //Outputs
        .top3_pc_sumador1_out(pc_adder),
        .top3_write_addr_out(Write_addr),
        .top3_read_data2_out(Read_data2),
        .top3_alu_result_out(EX_MEM_Alu_result),
        
        //Control signals out
        .top3_Branch(Branch),
        .top3_MemRead(MemRead),
        .top3_MemWrite(MemWrite),
        .top3_zero_out(Zero),
        .top3_MemtoReg(MemtoReg)
    );
    
endmodule
