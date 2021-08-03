`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.03.2021 19:28:28
// Design Name: 
// Module Name: Sumador
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


module Sumador#(
        
        parameter    N_BITS = 32
    )
    (
        input   wire    [N_BITS - 1 : 0]    in_sum_1,
        input   wire    [N_BITS - 1 : 0]    in_sum_2,
        
        //Output
        output   wire    [N_BITS - 1 : 0]    out_sum_mux
    );
    
    assign out_sum_mux = in_sum_1 + in_sum_2;
    
endmodule
