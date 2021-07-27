`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.07.2021 21:45:42
// Design Name: 
// Module Name: test_bench_UNID_CORTO
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
`define ASYNC_WAIT      #10         //Period for asyc wait steps in timescale unit

module test_bench_UNID_CORTO();
    
    //Parameters
    parameter RT_WIDTH = 5;
    parameter RS_WIDTH = 5;
    parameter RD_WIDTH = 5;
    
    //inputs
    reg [RT_WIDTH - 1 :0] ID_EX_rt;
    reg [RS_WIDTH - 1 :0] ID_EX_rs;
    reg [RD_WIDTH - 1 :0] MEM_WB_rd;
    reg [RD_WIDTH - 1 :0] EX_MEM_rd;
    reg MEM_WB_RegWrite, EX_MEM_RegWrite;
    
    //outputs
    wire [1:0] operand1_corto;
    wire [1:0] operand2_corto;
    
    initial
    begin                   //No data hazard
        ID_EX_rt = 10;
        ID_EX_rs = 20;
        MEM_WB_rd = 30;
        EX_MEM_rd = 40;
        MEM_WB_RegWrite = 0;
        EX_MEM_RegWrite = 1;
        
        `ASYNC_WAIT        //1a. EX/MEM.RegisterRd = ID/EX.RegisterRs
        ID_EX_rt = 10;  
        ID_EX_rs = 20;
        MEM_WB_rd = 30;
        EX_MEM_rd = 20;
        
        `ASYNC_WAIT        //1b. EX/MEM.RegisterRd = ID/EX.RegisterRt
        ID_EX_rt = 10;
        ID_EX_rs = 20;
        MEM_WB_rd = 30;
        EX_MEM_rd = 10;
        
        `ASYNC_WAIT        //2a. MEM/WB.RegisterRd = ID/EX.RegisterRs
        ID_EX_rt = 10;
        ID_EX_rs = 20;
        MEM_WB_rd = 20;
        EX_MEM_rd = 40;
        MEM_WB_RegWrite = 1;
        EX_MEM_RegWrite = 0;
        
        `ASYNC_WAIT        //2b. MEM/WB.RegisterRd = ID/EX.RegisterRt
        ID_EX_rt = 10;
        ID_EX_rs = 20;
        MEM_WB_rd = 10;
        EX_MEM_rd = 40;
        
        `ASYNC_WAIT
        $finish;
    end

Unidad_Cortocircuito Unidad_Cortocircuito (
    .EX_MEM_RegWrite(EX_MEM_RegWrite),
    .MEM_WB_RegWrite(MEM_WB_RegWrite),
    .ID_EX_rs(ID_EX_rs),
    .ID_EX_rt(ID_EX_rt),
    .MEM_WB_WriteAddr(MEM_WB_rd),
    .EX_MEM_WriteAddr(EX_MEM_rd),
    
    //outputs
    .operando1_corto(operand1_corto),
    .operando2_corto(operand2_corto)
);

endmodule
