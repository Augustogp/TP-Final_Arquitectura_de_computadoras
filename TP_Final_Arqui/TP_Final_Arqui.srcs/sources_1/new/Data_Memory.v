`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.03.2021 21:06:43
// Design Name: 
// Module Name: Data_Memory
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


module Data_Memory#(

        //Parameters
        parameter   N_BITS_DATA   =   32,
        parameter   N_BITS_ADDR   =   5,
        parameter   MEM_DEPTH     =   32
    )
    (
        //Inputs
        input   wire    i_clock, i_reset, i_wr_enable, i_rd_enable, i_enable,
        input   wire    [N_BITS_ADDR : 0]    i_addr_rd, i_addr_wr,
        input   wire    [N_BITS_DATA : 0]    i_data_wr,
        
        //Outputs        
        output  reg    [N_BITS_DATA - 1 : 0]    o_read_data 
    );
    
    reg     [MEM_DEPTH - 1 : 0]   registers   [N_BITS_DATA - 1 : 0];
    
    always@(negedge i_clock)
    begin
        if(i_reset)
        begin
            reset_all();
        end
        else if(i_enable)
        begin
            if(i_wr_enable)
            begin
                registers[i_addr_wr] <= i_data_wr;
            end
            if(i_rd_enable)
            begin
                o_read_data <= registers[i_addr_rd];
            end
        end
        else
            o_read_data = o_read_data;
        
    end
    
task reset_all;
    begin:reset
      integer reg_index;
        for (reg_index = 0; reg_index < MEM_DEPTH; reg_index = reg_index + 1)
          registers[reg_index] = {N_BITS_DATA{1'b0}};
        o_read_data  <=  {N_BITS_DATA{1'b0}};
    end
endtask
    
endmodule
