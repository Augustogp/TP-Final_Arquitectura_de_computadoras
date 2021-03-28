`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.03.2021 15:14:33
// Design Name: 
// Module Name: Mux_2a1
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


module Mux_2a1#(
        
        parameter   N_BITS = 32   
    )
    (
        input   wire    in_mux_control,
        input   wire    [N_BITS - 1 : 0]    in_mux_1,
        input   wire    [N_BITS - 1 : 0]    in_mux_2,
        output  wire    [N_BITS - 1 : 0]    out_mux
    
    );
    
    //Registros
    reg [N_BITS - 1 : 0] reg_out_mux;
    
    always @ (*) begin
        case (in_mux_control)
            1'b0 : reg_out_mux <= in_mux_1;
            1'b1 : reg_out_mux <= in_mux_2;    
        endcase
    end
    
    assign out_mux = reg_out_mux;

endmodule
