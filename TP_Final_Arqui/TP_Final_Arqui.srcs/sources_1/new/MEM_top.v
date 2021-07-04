`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.03.2021 13:04:29
// Design Name: 
// Module Name: MEM_top
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


module MEM_top#(
        
        parameter   N_BITS_REG_ADDR = 32,       // Bits de los registros del la memoria de datos
        parameter   N_BITS_WIDTH_DATA = 32, // Bits de ancho de la memoria
        parameter   N_BITS_MEMORY_ADDR = 32,       // Bits de direcciones de la memoria
        parameter   N_BITS_PC_ADDER = 32, // Bits program counter
        parameter   N_BITS_RD_WIDTH = 5        // Bits de direccion a escribir 
    )
    (
        // Inputs
        input   wire    top4_clock, top4_reset,
        input   wire    [N_BITS_MEMORY_ADDR - 1 : 0]    top4_addr,
        input   wire    [N_BITS_WIDTH_DATA - 1 : 0]     top4_write_data,
        input   wire    [N_BITS_REG_ADDR - 1 : 0]       top4_write_addr,
        input   wire    [N_BITS_PC_ADDER - 1 : 0]       top4_pc_adder,
        input   wire    [N_BITS_RD_WIDTH - 1 : 0]       top4_rd,
        //Inputs control
        input   wire    top4_mem_wr, top4_mem_rd, top4_reg_wr,
        input   wire    [1:0]   top4_mem_to_reg,
        input   wire    top4_mem_enable,
        
        //Outputs
        output  reg     [N_BITS_WIDTH_DATA - 1 : 0]     top4_read_data_out, top4_alu_result_out,
        output  reg     [N_BITS_REG_ADDR - 1 : 0]       top4_write_addr_out,
        //Outputs control
        output  reg     [N_BITS_PC_ADDER - 1 : 0]       top4_pc_adder_out,
        output  reg     [1 : 0]                         top4_mem_to_reg_out,
        output  reg                                     top4_reg_write_out,
        output  reg     [N_BITS_RD_WIDTH - 1 : 0]       top4_rd_out
    );
    
    //Cable para la salida
    wire    [N_BITS_WIDTH_DATA - 1 : 0]     read_data_o; // salida de la memoria, entrada de WB
    
    //Registros internos
    reg                                    wr_en;  //enabler de escritura de memoria                            
    reg    [N_BITS_WIDTH_DATA - 1 : 0]     data_write; //datos a escribir en memoria
    
    always@(posedge top4_clock)
    begin
        if(top4_reset)
        begin
            top4_read_data_out      <=  0;
            top4_alu_result_out     <=  0;
            top4_mem_to_reg_out     <=  0;
            top4_write_addr_out     <=  0;
            top4_reg_write_out      <=  0;
            data_write              <=  0;
        end
        
        else if(top4_mem_enable)
        begin
            top4_read_data_out      <=  read_data_o;
            top4_pc_adder_out       <=  top4_pc_adder;
            top4_alu_result_out     <=  top4_addr;
            top4_write_addr_out     <=  top4_write_addr;
            top4_mem_to_reg_out     <=  top4_mem_to_reg;
            top4_reg_write_out      <=  top4_reg_wr;
            data_write              <=  top4_write_data;
            top4_rd_out             <=  top4_rd;
        end
        
        else
        begin
            top4_read_data_out      <=  top4_read_data_out;
            top4_pc_adder_out       <=  top4_pc_adder_out;
            top4_alu_result_out     <=  top4_alu_result_out;
            top4_write_addr_out     <=  top4_write_addr_out;
            top4_mem_to_reg_out     <=  top4_mem_to_reg_out;
            top4_reg_write_out      <=  top4_reg_write_out;
            data_write              <=  data_write;
            top4_rd_out             <=  top4_rd_out;
        end
    end
    
    Data_Memory Data_Memory(
        i_clock(top4_clock), 
        i_reset(top4_reset), 
        i_wr_enable(top4_reg_write_out), 
        i_rd_enable(top4_mem_rd), 
        i_enable(top4_mem_enable),
        i_addr_rd(top4_addr), 
        i_addr_wr(top4_alu_result_out),
        i_data_wr(data_write),
        o_read_data(read_data_o) 
    );
    
endmodule
