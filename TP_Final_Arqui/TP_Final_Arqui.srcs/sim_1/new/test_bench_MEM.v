`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.07.2021 22:15:23
// Design Name: 
// Module Name: test_bench_MEM
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
`define CLK_PERIOD      10
`define DATA_MEMORY_DEPTH 256

module test_bench_MEM();

    //Parameters
    parameter DATA_MEMORY_ADDR_WIDTH = 32;
    parameter REGISTERS_WIDTH = 32;
    parameter REGISTERS_DEPTH = 32;
    parameter REGISTERS_ADDR_WIDTH = $clog2(REGISTERS_DEPTH);
    
    //inputs
    reg clk,reset;
    reg [DATA_MEMORY_ADDR_WIDTH - 1 : 0] Addr;
    reg [REGISTERS_WIDTH -1 : 0] Write_Data;
    reg [REGISTERS_ADDR_WIDTH -1 :0] Write_addr_in;
    
    //Control signal inputs
    reg MemWrite,MemRead,RegWrite_in;
    reg [1:0] MemtoReg_in;
    
    //outputs
    wire [REGISTERS_WIDTH -1 : 0] Read_data,Alu_result;
    wire [REGISTERS_ADDR_WIDTH -1 :0] Write_addr;
    
    //control signals out
    wire[1:0] MemtoReg;
    wire RegWrite;
    
    //Testbench variables
    integer i;

    always #`CLK_PERIOD clk = !clk;
	
	initial
	begin
        clk = 0;
        reset = 1'b1;
        i = 1'b0 ;
        @(negedge clk) #1;
        reset = 1'b0;
        Write_addr_in = 9;
        MemWrite = 1'b1;
        MemRead = 1'b1;
        RegWrite_in = 1'b1;
        MemtoReg_in = 1'b1;
        @(negedge clk) #1;
        
        while(i<`DATA_MEMORY_DEPTH)
            begin   
                Addr = i;
                Write_Data = i+10;
                @(posedge clk) #1;//Write data_memory[i] = i + 1
                @(negedge clk) #1;//Read data_memory[i]
                i = i + 1;
            end
        @(negedge clk) #1;
        @(negedge clk) #1;
        $finish;
	end
	
	MEM_top mem_top (
        //inputs
        .top4_clock(clk),
        .top4_reset(reset),
        .top4_addr(Addr),
        .top4_write_data(Write_Data),
        .top4_write_addr(Write_addr_in),
        
        //control signals in
        .top4_mem_wr(MemWrite),
        .top4_mem_rd(MemRead),
        .top4_reg_wr(RegWrite_in),
        .top4_mem_to_reg(MemtoReg_in),
        
        //outputs
        .top4_read_data_out(Read_data),
        .top4_alu_result_out(Alu_result),
        .top4_write_addr_out(Write_addr),
        
        //control signals out
        .top4_mem_to_reg_out(MemtoReg),
        .top4_reg_write_out(RegWrite)
    );

endmodule
