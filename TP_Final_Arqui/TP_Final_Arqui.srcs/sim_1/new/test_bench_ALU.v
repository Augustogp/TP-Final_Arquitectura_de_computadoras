`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.07.2021 18:38:12
// Design Name: 
// Module Name: test_bench_ALU
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
`define NUM_SUPP_OPERATIONS 11
`define ASYNC_WAIT      #10         //Period for asyc wait steps in timescale unit

module test_bench_ALU();
   
    //Test Parameters
    parameter reg_data_width = 32;
    parameter alu_ctrl_opcode_width = 4;
    
    //Test Inputs
	reg signed [reg_data_width-1 : 0] Alu_operando_1;
	reg signed [reg_data_width-1 : 0] Alu_operando_2;
	reg [alu_ctrl_opcode_width-1 : 0] Alu_control_opcode;
    
    //Test Outputs
	wire [reg_data_width - 1 : 0] Alu_result;
	wire Alu_zero;
	integer i ;
	
	initial begin
        Alu_operando_1 = {reg_data_width{1'b0}};
        Alu_operando_2 = {reg_data_width{1'b0}};
        Alu_operando_1 = 5;
        Alu_operando_2 = 3;
        `ASYNC_WAIT;
	
        for (i = 0 ; i < `NUM_SUPP_OPERATIONS  ; i = i+1)
        begin
            Alu_control_opcode = i ;
            `ASYNC_WAIT;
        end
	
	$finish;	
	
	end
	
	ALU ALU_tb(
        .Alu_operand_1(Alu_operando_1),
        .Alu_operand_2(Alu_operando_2),
        .Alu_control_opcode(Alu_control_opcode),
        .Zero_out(Alu_zero),
        .Alu_result_out(Alu_result)
    );
	
endmodule
