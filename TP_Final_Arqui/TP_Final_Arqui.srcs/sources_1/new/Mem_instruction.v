`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.03.2021 20:28:10
// Design Name: 
// Module Name: Mem_instruction
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

// En esta memoria, primero se va a escribir en el negedge clock y luego leer o resetear

module Mem_instruction#(
        
        parameter   N_BITS_I = 32,  // Ancho de instruccion
        parameter   N_BITS_C = 32,  // Numero de entradas de la memoria
        parameter   N_BITS_D = 5    // Log base 2 de la cantidad de entradasa memoria para asi direccionar
        
    )
    (
        input   wire                      mem_clock,
        input   wire                      mem_reset,
        input   wire                      mem_write_e,
        input   wire                      mem_read_e,
        input   wire                      mem_enable,
        input   wire [N_BITS_D - 1 : 0]   mem_write_addr,   // Bus de direcciones para la escritura
        input   wire [N_BITS_I - 1 : 0]   mem_write_data,   // Input para la escritura
        input   wire [N_BITS_D - 1 : 0]   in_pc_mem,    // Bus de direcciones que se lee desde PC
        output  reg  [N_BITS_I - 1 : 0]   out_mem       // Output para lectura de instruccion  
    );
    
    reg [N_BITS_C - 1 : 0] memoria_data [N_BITS_D - 1 : 0] ;//Memoria
    
    
    always@(negedge mem_clock) begin
        
        if(mem_reset) begin 
            resetear();
        end
        else
            begin
                // Escritura
                if(mem_write_e && mem_enable) // Si esta habilitada la memoria en modo escritura
                begin
                    if((mem_write_addr == mem_write_addr) && (mem_write_data == mem_write_data)) //Hay que comprobar los inputs 
                        memoria_data[mem_write_addr] <= mem_write_data; // Se escribe en memmoria la instruccion  
                end
                else //Si no esta habilitada la escritura o no esta habilitada la memoria
                    out_mem <= out_mem;
                
                // Lectura
                if(mem_read_e && mem_enable) // Si esta habilitada la memoria en modo lectura
                begin
                    if((in_pc_mem == in_pc_mem) && (memoria_data[in_pc_mem] == memoria_data[in_pc_mem])) // Se comprueban los input                                      
                    begin
                        if(mem_write_e && (mem_write_addr == mem_write_addr) && (mem_write_data == mem_write_data)) // Si esta activa la escritura tambien
                            out_mem <= mem_write_data; // Se lee la direccion del debug que viene por escritura
                        else
                            out_mem <= memoria_data[in_pc_mem]; // Se lee la direccion a la que apunta el Program Counter
                    end           
                end
                
                else
                    out_mem <= out_mem;
            
            end
    end
    
    task resetear; // Se resetea la memoria
        begin : resetear
            integer fila;
            for(fila = 0 ; fila < N_BITS_C; fila = fila + 1) // Se va a recorrer cada espacio de memoria y se pone en 0
                memoria_data[fila] <= 0;
            out_mem <= 0; // A la salida se le asigna un 0
        end
    endtask
    
endmodule
