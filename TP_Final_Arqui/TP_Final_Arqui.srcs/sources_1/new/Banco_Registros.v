`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.03.2021 11:39:42
// Design Name: 
// Module Name: Banco_Registros
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


module Banco_Registros#(

        //Parameters
        parameter   N_BITS_DATA   =   32,
        parameter   N_BITS_ADDR   =   5,
        parameter   REG_DEPTH     =   32
    )
    (
        //Inputs
        input   wire    i_clock, i_reset, i_control_wr, i_enable,
        input   wire    [N_BITS_ADDR - 1 : 0]    i_ra, i_rb, i_reg_wr,
        input   wire    [N_BITS_DATA - 1 : 0]    i_data_wr,
        
        //Outputs        
        output  reg    [N_BITS_DATA - 1 : 0]    o_read_data1, o_read_data2 
    );
    
    reg     [REG_DEPTH - 1 : 0]   registers   [N_BITS_DATA - 1 : 0];
    reg    [N_BITS_DATA - 1 : 0]    o_read_data1_next, o_read_data2_next;
    
    always@(negedge i_clock)
    begin
        if(i_reset)
        begin
            reset_all();
        end
        else
        begin
            o_read_data1 <= o_read_data1_next;
            o_read_data2 <= o_read_data2_next;
        end
        
    end
    
    always@(*)
    begin
        o_read_data1_next = o_read_data1;
        o_read_data2_next = o_read_data2;
        if(i_enable)
        begin
            if(i_control_wr) //Escribir datos en los registros
            begin
                registers[i_reg_wr] = i_data_wr;
            end
            if(i_reg_wr == i_ra) //Si la direccon de ra o rb es igual a la direccion de escritura, se coloca el contenido a la salida para evitar dependencias de WB
            begin
                o_read_data1_next = i_data_wr;
                o_read_data2_next = registers[i_rb];
            end
            else if(i_reg_wr == i_rb)
            begin
                o_read_data1_next = registers[i_ra];
                o_read_data2_next = i_data_wr;
            end
            else
            begin
                o_read_data1_next = registers[i_ra];
                o_read_data2_next = registers[i_rb];
            end
        end
     
    end
    
task reset_all;
    begin:reset
      integer reg_index;
        for (reg_index = 0; reg_index < REG_DEPTH; reg_index = reg_index + 1)
          registers[reg_index] = {N_BITS_DATA{1'b0}};
        o_read_data1  <=  {N_BITS_DATA{1'b0}};
        o_read_data2  <=  {N_BITS_DATA{1'b0}};
    end
endtask
    
endmodule
