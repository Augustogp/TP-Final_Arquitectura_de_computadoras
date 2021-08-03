`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.06.2021 15:53:28
// Design Name: 
// Module Name: UART_top
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


module UART_top#(
        
        parameter   N_BITS_WORD = 8,
        parameter   N_BITS_PC = 32,
        parameter   N_BITS_INST = 32        
    )
    (
        //Inputs
        input wire top_uart_clock, top_uart_reset, top_uart_rx_in,
        input wire top_uart_tx_start,
        input wire [N_BITS_WORD - 1 : 0] top_uart_tx_in,
        
        // Outputs
        output wire top_uart_read_en, top_uart_tx_done,
        output wire top_uart_write_en, top_uart_tick,
        output wire top_uart_tx_out,
        output wire [N_BITS_PC - 1 : 0] top_uart_write_addr,
        output wire [N_BITS_INST - 1 : 0] top_uart_data_write,
        output wire top_uart_enable
    );
    
    // Cables internos
    wire wire_rx_done;
    wire [N_BITS_WORD - 1:0] reg_rx_out;
    
    
    // Instancias de modulos
    
    Baud_rate_gen Baud_rate_gen(
        .i_clock(top_uart_clock),     
        .i_reset(top_uart_reset), 
        .o_tick(top_uart_tick)
    );
    
    Rx Rx (
        .i_clock(top_uart_clock),
        .s_tick(top_uart_tick),
        .rx(top_uart_rx_in),
        .i_reset(top_uart_reset),
        .dout(reg_rx_out),
        .rx_done_tick(wire_rx_done)
    );
    
    Tx Tx (
        .i_clock(top_uart_clock),
        .s_tick(top_uart_tick),
        .tx(top_uart_tx_in),
        .i_reset(top_uart_reset),
        .dout_tx(top_uart_tx_out),
        .tx_start(top_uart_tx_start),
        .o_tx_done(top_uart_tx_done)
    );
    
    Unidad_Debug Unidad_Debug(
        .i_UD_clock(top_uart_clock),
        .i_UD_reset(top_uart_reset),
        .i_RX_out(reg_rx_out),
        .i_RX_done(wire_rx_done), 
        .o_write_data(top_uart_data_write),   
        .o_write_addr(top_uart_write_addr),   
        .o_mem_write_e(top_uart_write_en),
        .o_mem_read_e(top_uart_read_en),
        .o_mem_enable(top_uart_enable)    
    );
     
endmodule
