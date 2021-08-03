`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.07.2021 17:57:42
// Design Name: 
// Module Name: test_bench_Stall_Unit
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
`define ASYNC_WAIT      10

module test_bench_Stall_Unit();
    
    //Test Parameters
    parameter RS_WIDTH = 5;
    parameter RT_WIDTH = 5;
    
    // Inputs
    reg ID_EX_MemRead;
    reg [RS_WIDTH - 1 :0] IF_ID_rs;
    reg [RT_WIDTH - 1 :0] IF_ID_rt;
    reg [RT_WIDTH - 1 :0] ID_EX_rt;//
    
    // Outputs
    wire pc_Write;
    wire control_enable;
    wire IF_ID_write;

	initial	
	begin
        ID_EX_MemRead = 1;

        #`ASYNC_WAIT
        IF_ID_rs = 10;
        IF_ID_rt = 20;
        ID_EX_rt = 10;
        #`ASYNC_WAIT 
        ID_EX_rt = 20;
        #`ASYNC_WAIT   
        ID_EX_MemRead = 0;
        #`ASYNC_WAIT   
        
         $finish;
	end
	
	Stall_Unit Stall_Unit(
        //inputs
        .ID_EX_MemRead (ID_EX_MemRead),
        .IF_ID_rs (IF_ID_rs),
        .IF_ID_rt (IF_ID_rt),
        .ID_EX_rt(ID_EX_rt),
        
        //outputs
        .enable_pc(pc_Write),
        .control_enable(control_enable),
        .IF_ID_write(IF_ID_write) 
    );


endmodule
