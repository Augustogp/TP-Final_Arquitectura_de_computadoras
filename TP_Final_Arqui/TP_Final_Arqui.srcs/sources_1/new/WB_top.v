`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.03.2021 11:15:24
// Design Name: 
// Module Name: WB_top
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


module WB_top#(
        
        parameter   N_BITS_REG = 32,        // Bits de registros
        parameter   N_BITS_MUX_CON = 2
    )
    (
        //Inputs
        input wire [N_BITS_REG - 1 : 0]     top5_read_data,     // Dato leído en memoria de datos (store)
        input wire [N_BITS_REG - 1 : 0]     top5_alu_result,    // Resultado de la Alu (instrucciones aritméticas/lógicas)
        input wire [N_BITS_REG - 1 : 0]     top5_return_addr,   // Segunda dirección siguiente de la instrucción JALR
       
        // Inputs de control
        input wire [N_BITS_MUX_CON - 1:0]   top5_Mem_to_Reg,        // Control de mux de WB 
        
        // Outputs
        output reg [N_BITS_REG - 1 : 0]     top5_write_data_out     // Escritura en memoria     
    );
    
    // Instancias de modulos
    
    Mux_4a1 Mux_WB(
        .in_mux_control(top5_Mem_to_Reg),
        .in_mux_1(top5_read_data),
        .in_mux_2(top5_alu_result),
        .in_mux_3(top5_return_addr),
        .in_mux_4({N_BITS_REG{1'b0}}),      // No se usa esta entrada
        .out_mux(top5_write_data_out)
    );
     
endmodule
