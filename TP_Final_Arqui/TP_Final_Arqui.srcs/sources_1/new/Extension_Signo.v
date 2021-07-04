`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.03.2021 20:23:32
// Design Name: 
// Module Name: Extension_Signo
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


module Extension_Signo#(

        //Parameters
        parameter   N_BITS_IN   =   16,
        parameter   N_BITS_OUT  =   32
    )
    (
        input   wire    [N_BITS_IN - 1 : 0]     i_sign_extension,
        
        output  wire    [N_BITS_OUT - 1 : 0]    o_sign_extension   
    );
    
    assign  o_sign_extension    =   i_sign_extension;
//    assign  o_sign_extension    =   i_sign_extension << (N_BITS_OUT-N_BITS_IN);

    
endmodule
