`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.03.2021 11:54:08
// Design Name: 
// Module Name: Stall_Unit
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


module Stall_Unit#(
        
        parameter   N_BITS_RS = 5,          // Bits de rs
        parameter   N_BITS_RT = 5           // Bits de rt
    )
    (
        //Inputs
        input wire                          SU_start,
        input wire                          ID_EX_MemRead,
        input wire [N_BITS_RS - 1 : 0]      IF_ID_rs,
        input wire [N_BITS_RT - 1 : 0]      IF_ID_rt,
        input wire [N_BITS_RT - 1 : 0]      ID_EX_rt,
        
        //Outputs
        output reg              enable_pc,
        output reg              control_enable,
        output reg              IF_ID_write    
    );
    
    always@(*) begin
        if(SU_start) 
        begin 
            enable_pc <= 1;
            control_enable <= 1;
            IF_ID_write <= 1;     
        end
        
        else
        begin
            enable_pc <= 0;
            control_enable <= 0;
            IF_ID_write <= 0;
        end
        //Condicion de dependencia de los registros 
        if(ID_EX_MemRead && ((ID_EX_rt == IF_ID_rs) || (ID_EX_rt == IF_ID_rt)))
        begin
            enable_pc <= 0;
            control_enable <= 0;
            IF_ID_write <= 0;
        end
    end
endmodule
