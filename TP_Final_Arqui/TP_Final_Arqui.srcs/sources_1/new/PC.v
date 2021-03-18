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
       parameter    N_BITS = 16,
       parameter    N_BITS_PC = 11

    )    
    (
        //Inputs
        //input   wire    [N_BITS - 1 : 0]    in_addr,
        input   wire                        enable,
        input   wire                        i_clock,
        input   wire                        i_reset,    

        //Outputs
        output   wire    [N_BITS_PC - 1 : 0]    out_addr
    );
    
    reg     [N_BITS_PC - 1 : 0]    addr;
    
    assign out_addr = addr;
    
    always@(posedge i_clock)
        if(i_reset) begin
            addr <= 0;
        end
        else begin 
            if(enable) begin
                addr <= addr + 1'b1;
            end
            else begin
                addr <= addr;
            end
        end    
        
       
endmodule