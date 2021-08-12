`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.06.2021 11:16:28
// Design Name: 
// Module Name: Unidad_Debug
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


module Unidad_Debug#(
        parameter   N_BITS_MEM = 32,            // Bits de rs
        parameter   N_BITS_INST = 32,           // Bits de instruccion
        parameter   N_BITS_RX = 8,              // Bits de RX
        parameter   N_BITS_STATE = 4            // Bits de estado
    )
    (
        //Inputs
        input wire [N_BITS_RX - 1 : 0]      i_RX_out,
        input wire                          i_RX_done,
        input wire                          i_UD_clock,
        input wire                          i_UD_reset,       
        
        //Outputs
        output reg [N_BITS_INST - 1 : 0]    o_write_data,   // La instruccion que entra en la memoria de instrucciones
        output reg [N_BITS_MEM - 1 : 0]     o_write_addr,   // Direccion de escritura de la memoria
        output reg                          o_mem_write_e,
        output reg                          o_mem_read_e,
        output reg                          o_mem_enable    // Habilitar memoria
    );
    
    // Local Param
    localparam ESPERA       = 5'b0001;           // Espera una instruccion
    localparam CARGANDO     = 5'b0010;         // Cargando una instruccion
    localparam LISTO        = 5'b0100;            // Instrucción cargada
    localparam STEP_MODO    = 5'b1000;             // Setea el modo de la señal de clock (paso a paso o continuo)
    localparam STEP_BY_STEP_CODE    = 'b10111011;
    localparam CONTINOUS_CODE       = 'b10111011;
    
    //Registros internos
    reg [N_BITS_INST - 1 : 0]   reg_inst_next;
    reg [N_BITS_MEM - 1 : 0]    reg_addr_next;
    reg [N_BITS_STATE - 1 : 0]  reg_estado, reg_estado_next;
    reg [N_BITS_INST - 1 : 0]   inst_buffer, inst_buffer_next ;
    reg [$clog2 (N_BITS_INST/N_BITS_RX) : 0]    cont_palabras, cont_palabras_next;
    reg [N_BITS_INST - 1 : 0]   inst_addr_cont, inst_addr_cont_next ;
    
    // Variables internas
    reg mem_enable_next, mem_enable_aux, mem_enable_aux_next;
    reg step_mode, step_mode_next;
    reg step_flag, step_flag_next;
    
    // Memoria
    always@(posedge i_UD_clock)
    begin
    if(i_UD_reset)
        begin
        reg_estado <= ESPERA;
        inst_buffer <= 0;
        cont_palabras <= 0;
        inst_addr_cont <= 0;
        o_write_data <= 0;
        o_write_addr <= 0;
        o_mem_write_e <= 0;
        o_mem_read_e <= 0;
        step_flag <= 0;
        o_mem_enable <= 0;
        mem_enable_aux <= 0;
        end
	else 
		begin 
		reg_estado      <= reg_estado_next;
        inst_buffer     <= inst_buffer_next;
        cont_palabras   <= cont_palabras_next;
        inst_addr_cont  <= inst_addr_cont_next;
        o_write_data    <= reg_inst_next;
        o_write_addr    <= reg_addr_next;
        step_flag       <= step_flag_next;
        step_mode       <= step_mode_next;
        o_mem_enable    <= mem_enable_next;
        mem_enable_aux  <= mem_enable_aux_next;
		end 
    end
    
    // Logica de siguiente estado
    always@(*)begin
        reg_estado_next = reg_estado;
        inst_buffer_next = inst_buffer;
        cont_palabras_next = cont_palabras;
        inst_addr_cont_next = inst_addr_cont;
        
        case (reg_estado)
            ESPERA: begin
                if(i_RX_done) begin // Espera por RX_DONE
                    // Si RX_done esta en 1 significa que ya se puede recibir el dato de RX, hay que ver 
                    // el modo, si es paso a paso o continuo 
                    if(i_RX_out == STEP_BY_STEP_CODE) begin
                        reg_estado_next = STEP_MODO;            // Es modo paso a paso
                        inst_buffer_next = inst_buffer_next;
                        cont_palabras_next = cont_palabras_next;
                        inst_addr_cont_next = inst_addr_cont_next;
                    end
                    else begin // Es modo continuo
                        mem_enable_next = 1;
                        reg_estado_next = CARGANDO;
                        inst_buffer_next = {i_RX_out, inst_buffer[N_BITS_INST-1:N_BITS_RX]};
                        inst_addr_cont_next = inst_addr_cont;
                        cont_palabras_next = cont_palabras + 1;
                    end
                end
                else begin // Si no esta RX_DONE en 1, quiere decir que no se termino de transmitir
                    mem_enable_next = 1;
                    inst_buffer_next = 0;
                    cont_palabras_next = 0;
                    inst_addr_cont_next = inst_addr_cont;
                end
            end
            
            CARGANDO: begin
                if(i_RX_done) begin
                    if(cont_palabras == (N_BITS_INST/N_BITS_RX)-1) begin // Se ve si se pasaron todas las palabras
                        reg_estado_next = LISTO;
                        inst_buffer_next = {i_RX_out, inst_buffer[N_BITS_INST-1:N_BITS_RX]};
                        inst_addr_cont_next = inst_addr_cont;
                        cont_palabras_next = 0;                             
                    end
                    else begin
                        reg_estado_next = CARGANDO;
                        inst_buffer_next = {i_RX_out, inst_buffer[N_BITS_INST-1:N_BITS_RX]};
                        inst_addr_cont_next = inst_addr_cont;
                        cont_palabras_next = cont_palabras + 1;                                          
                    end
                end
            end
            
            LISTO: begin
                reg_estado_next = ESPERA; // Pasa a estado de ESPERA
                inst_buffer_next = inst_buffer_next;
                inst_addr_cont_next = inst_addr_cont + 1; // Se pasa a la siguiente direccion
                cont_palabras_next = 0;
            end
            
            STEP_MODO: begin
                if(i_RX_out == STEP_BY_STEP_CODE) begin
                    if(o_mem_enable == 1 && mem_enable_aux == 1) begin
                        mem_enable_next = 0;
                        mem_enable_aux_next = mem_enable_aux;
                    end
                    else if(o_mem_enable == 0 && mem_enable_aux == 0) begin
                        mem_enable_next = 1;
                        mem_enable_aux_next = 1;
                    end
                    else begin
                        mem_enable_next = o_mem_enable;
                        mem_enable_aux_next = mem_enable_aux;
                    end
                end
                else begin
                    mem_enable_next = 0;
                    mem_enable_aux_next = 0;                    
                end
                
                reg_estado_next = STEP_MODO;
                inst_buffer_next = inst_buffer_next;
                inst_addr_cont_next = inst_addr_cont_next;
                cont_palabras_next = cont_palabras_next;                        
            end
        endcase
    end
    
    // Logica de salida
    always@(*)begin       
        case (reg_estado)
            ESPERA: begin
                o_write_data = o_write_data;
                o_write_addr = o_write_addr;
                o_mem_write_e = 0; // Escritura de instrucciones deshabilitada
                o_mem_read_e = 1;  // Lectura de instrucciones habilitada  
            end
            
            CARGANDO: begin
                o_write_data = 0;
                o_write_addr = o_write_addr;
                o_mem_write_e = 0; // Escritura de instrucciones deshabilitada
                o_mem_read_e = 1;  // Lectura de instrucciones habilitada
            end
            
            LISTO: begin
                o_write_data = inst_buffer; // Se pone la instruccion del buffer cuando esta en LISTO
                o_write_addr = inst_addr_cont; // El contador de palabra va a ser la direccion en memoria
                o_mem_write_e = 1;
                o_mem_read_e = 1;
            end
            
            STEP_MODO: begin
                o_write_data = o_write_data; 
                o_write_addr = o_write_addr;
                o_mem_write_e = 0;
                o_mem_read_e = 1;
            end
            
            default: begin
                o_write_data = 0; 
                o_write_addr = 0;
                o_mem_write_e = 0;
                o_mem_read_e = 1;
            end
        endcase
    end
    
endmodule
