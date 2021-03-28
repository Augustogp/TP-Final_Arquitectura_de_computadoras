`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.03.2021 19:56:28
// Design Name: 
// Module Name: Mux_4a1
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


module Mux_4a1#(
        
        parameter   N_BITS = 16,
        parameter   N_BITS_M = 2   
    )
    (
        input   wire    [N_BITS_M - 1 : 0]  in_mux_control,
        input   wire    [N_BITS - 1 : 0]    in_mux_1,
        input   wire    [N_BITS - 1 : 0]    in_mux_2,
        input   wire    [N_BITS - 1 : 0]    in_mux_3,
        input   wire    [N_BITS - 1 : 0]    in_mux_4,
        output  wire    [N_BITS - 1 : 0]    out_mux
    
    );
    
    //Registros
    reg [N_BITS - 1 : 0] reg_out_mux;
    
    always @ (*) begin
        case (in_mux_control)
            2'b00 : reg_out_mux <= in_mux_1;
            2'b01 : reg_out_mux <= in_mux_2;
            2'b10 : reg_out_mux <= in_mux_3;
            2'b11 : reg_out_mux <= in_mux_4;    
        endcase
    end
    
    assign out_mux = reg_out_mux;

endmodule
