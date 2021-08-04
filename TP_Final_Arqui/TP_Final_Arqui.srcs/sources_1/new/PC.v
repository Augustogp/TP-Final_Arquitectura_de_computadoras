`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.09.2020 19:58:49
// Design Name: 
// Module Name: alu
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

module PC#(
        //Parameters
       parameter    N_BITS = 32,
       parameter    N_BITS_PC = 11,
       parameter    HALT_OPCODE = 'hffffffff,
       parameter    INST_MEMORY_BITS=16
    )    
    (
        //Inputs
        input   wire                                pc_enable,
        input   wire                                pc_clock,
        input   wire                                pc_reset,    
        input   wire    [INST_MEMORY_BITS -1 : 0]   instruction,
        input   wire    [N_BITS - 1 : 0]            in_mux_pc,
        //Outputs   
        output   wire    [N_BITS - 1 : 0]           out_pc_mem
    );
    
    reg     [N_BITS - 1 : 0]    pc;
    
    assign out_pc_mem = pc;
    
    always@(posedge pc_clock)
        if(pc_reset) 
        begin
            pc <= 0;
        end
        else if(pc_enable && (instruction != HALT_OPCODE))
        begin
            pc <= in_mux_pc;
        end
        else 
        begin
            pc <= pc;
        end
       
endmodule