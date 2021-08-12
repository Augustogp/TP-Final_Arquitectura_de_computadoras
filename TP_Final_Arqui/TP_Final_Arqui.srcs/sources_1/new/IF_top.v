`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.03.2021 15:38:29
// Design Name: 
// Module Name: IF_top
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


module IF_top#(
        
        parameter   N_BITS_PC = 32,         // Bits del PC
        parameter   N_BITS_INST = 32,       // Bits de instruccion
        parameter   N_BITS_REG = 32,        // Bits de registros
        parameter   N_BITS_INST_INDEX = 26, // Bits de indice de instruccion
        parameter   CANT_SUMADOR = 1        // Cantidad a sumar  en sumador 
        
    )
    (
        // Inputs
        input   wire                        top1_clock,
        input   wire                        top1_reset,
        input   wire [N_BITS_PC - 1 : 0]    top1_write_addr,     // Direccion de escritura de instruccion
        input   wire [N_BITS_INST - 1 : 0]  top1_write_data,     // Instruccion a escribir en memoria de instrucciones
        input   wire [N_BITS_PC - 1 : 0]    top1_pc_offset,      // PC <= PC + 1 + Offset 
        input   wire [N_BITS_REG - 1 : 0]   top1_pc_register,    // PC <= rs (read_data1_out)
        input   wire [1 : 0]                top1_mux_selector,   // Selector del multiplexor
        input   wire                        top1_write_e,        // Enable para escritura debug
        input   wire                        top1_read_e,         // Enable para lecutra debug
        input   wire                        top1_pc_enable,      // PC enable
        input   wire                        top1_mem_enable,     // Memoria enable
        input   wire                        top1_IF_ID_write,    // Control de escritura en esta etapa
        input   wire                        top1_IF_ID_reset,    // Control de reset en esta etapa
        
        //Outputs
        output reg [N_BITS_PC - 1 :0]       top1_sumador_out,    // Salida del sumador, seria la siguiente direccion de instruccion
        output reg [N_BITS_INST - 1 :0]     top1_memoria_out     // Actual instruccion que sale de la memoria de instrucciones   
    );
    
    // Cables para la salida
    wire [N_BITS_PC - 1 :0]     wire_sumador_out;   // Salida del sumador
    wire [N_BITS_INST - 1 :0]   wire_memoria_out;   // Es la instruccion que sale de la memoria de instrucciones    
    
    // Cables internos
    wire [N_BITS_PC - 1 :0]     wire_mux_pc;        // Salida de multiplexor que es la entrada de PC
    wire [N_BITS_PC - 1 :0]     wire_pc_mem;        // Salida de PC que es la entrada de la memoria y del sumador 
    wire [N_BITS_PC - 1 :0]     wire_index_inst;    // Indice de la instruccion, va a entrar en mux
    
    // TOP IF
    always@(posedge top1_clock) begin
        if(top1_reset || top1_IF_ID_reset)
        begin
            top1_sumador_out <= 0;
            top1_memoria_out <= 'haaaaaaaa; // Se le asigna una instruccion cualquiera
        end
        else if(top1_IF_ID_write) // Si esta habilitada desde el control para escritura
        begin 
            top1_sumador_out <= wire_sumador_out;  
            top1_memoria_out <= wire_memoria_out;
        end
        else
        begin
            top1_sumador_out <= top1_sumador_out;  
            top1_memoria_out <= top1_memoria_out;        
        end
    end
    
    // Instancias de modulos
    
    Mux_4a1 Mux_4a1_IF(
        .in_mux_control(top1_mux_selector),
        .in_mux_1(wire_sumador_out),
        .in_mux_2(top1_pc_offset),
        .in_mux_3(wire_index_inst),
        .in_mux_4(top1_pc_register),
        .out_mux(wire_mux_pc)
    );
    
    PC PC(
        .pc_enable(top1_pc_enable),
        .pc_clock(top1_clock),
        .pc_reset(top1_reset),
        .instruction(wire_memoria_out[25:0]), // Ver para que esta
        .in_mux_pc(wire_mux_pc),
        .out_pc_mem(wire_pc_mem)
    );
    
    Sumador Sumador_IF(
        .in_sum_1(wire_pc_mem),
        .in_sum_2(CANT_SUMADOR),
        .out_sum_mux(wire_sumador_out)
    );
    
    Mem_instruction Mem_instruction(
        .mem_clock(top1_clock),
        .mem_reset(top1_reset),
        .mem_write_e(top1_write_e),
        .mem_read_e(top1_read_e),
        .mem_enable(top1_mem_enable),
        .mem_write_addr(top1_write_addr),
        .mem_write_data(top1_write_data),
        .in_pc_mem(wire_pc_mem),
        .out_mem(wire_memoria_out)
    
    );
    
    assign wire_index_inst = top1_memoria_out [N_BITS_INST_INDEX - 1 : 0]; 
    
    
endmodule
