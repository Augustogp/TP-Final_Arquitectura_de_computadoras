`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.05.2021 16:18:26
// Design Name: 
// Module Name: Unidad_Cortocircuito
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


module Unidad_Cortocircuito#(
        parameter   N_BITS_RS = 5,          // Bits de rs
        parameter   N_BITS_RT = 5,           // Bits de rt
        parameter   N_BITS_CORTO = 2
    )
    (
        //Inputs
        input wire                          EX_MEM_RegWrite,
        input wire                          MEM_WB_RegWrite,
        input wire [N_BITS_RS - 1 : 0]      ID_EX_rs,
        input wire [N_BITS_RT - 1 : 0]      ID_EX_rt,
        input wire [N_BITS_RT - 1 : 0]      EX_MEM_WriteAddr,
        input wire [N_BITS_RT - 1 : 0]      MEM_WB_WriteAddr,
        
        
        //Outputs
        output reg [N_BITS_CORTO - 1 : 0]      operando1_corto,
        output reg [N_BITS_CORTO - 1 : 0]      operando2_corto
    );
    
    //Condiciones del cortocircuito
    always@(*) begin
        if((EX_MEM_RegWrite == 0) && (MEM_WB_RegWrite == 0))
        begin
            operando1_corto = 'b0;
            operando2_corto = 'b0;
        end
    
        //Condiciones para operando 1:     
        //1. EX_MEM_WriteAddr = ID_EX_rs
        //2. MEM_WB_WriteAddr = ID_EX_rs
    
        if (EX_MEM_WriteAddr == ID_EX_rs && EX_MEM_RegWrite)
        begin
            operando1_corto = 'b1;
        end
        else if (MEM_WB_WriteAddr == ID_EX_rs && MEM_WB_RegWrite)
        begin
            operando1_corto = 'b10;   
        end
        else
        begin
            operando1_corto = 'b0;    
        end
        
        //Condiciones para operando 2:     
        //1. EX_MEM_WriteAddr = ID_EX_rt
        //2. MEM_WB_WriteAddr = ID_EX_rt
        
        if (EX_MEM_WriteAddr == ID_EX_rt && EX_MEM_RegWrite)
        begin
           operando2_corto = 'b1; 
        end
        else if (MEM_WB_WriteAddr == ID_EX_rt && MEM_WB_RegWrite) 
        begin
            operando2_corto = 'b10;       
        end  
        else
        begin
            operando2_corto = 'b0;    
        end  
    end
    
endmodule
