`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.07.2021 21:31:49
// Design Name: 
// Module Name: test_bench_IF_UART
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
`define CLK_PERIOD      10

module test_bench_IF_UART();
    
    //Parameters
    parameter PC_WIDTH = 32;
    parameter WORD_WIDTH = 8;
    parameter INST_WIDTH = 32;
    parameter INST_INDEX_WIDTH = 26;
    parameter INST_MEMORY_DEPTH = 64;
    
    //IF_top inputs
	reg clk, reset, enable, read_enable, uart_enable ,tx_start, rea, mem_enable;
	reg [PC_WIDTH - 1 :0] pc_offset,pc_inst_index,pc_register;
	reg [WORD_WIDTH-1:0] tx_in;
    reg [1:0] pc_src;
    reg IF_ID_write;
    wire wea;
    wire [PC_WIDTH - 1 :0] write_addr;
    wire [INST_WIDTH - 1 :0]instruction_data_write;
    
    //Uart_top inputs   
    wire rx_in, tx_done;
    
    //Uart output
    wire clk_out;
    
    //IF_top outputs
    wire [PC_WIDTH - 1 :0] pc_adder;
    wire [INST_WIDTH - 1 :0] instruction;
    wire [INST_INDEX_WIDTH-1 : 0] instr_index;
    wire tick;

    //Test Variables
    reg [INST_WIDTH-1:0] ram [INST_MEMORY_DEPTH-1:0]  ;
    integer i;
    integer j;
	
	always #`CLK_PERIOD clk = !clk;

    initial
    begin
        $readmemh("C:\Users\facubos\Documents\TP-Final_Arquitectura_de_computadoras\TP_Final_Arqui\TP_Final_Arqui.sim\sim_1\behav\xsim\out.txt",ram);         //Cargo instrucciones
        enable = 1'b0;
        //read_enable = 1'b0;
        //uart_enable = 1'b0;
        tx_start = 1'b0;
        clk =           1'b0;
        // Pc multiplexor input
        pc_offset = 'haa;
        pc_src = 2'b00;
        pc_inst_index = 'hbb;
        pc_register = 'hcc;
        tx_in = {WORD_WIDTH{1'b0}};
        @(posedge clk) #1;   
        reset =         1'b1;
        repeat(10)                                  //Resetear y esperar 10 ciclos de reloj
        @(posedge clk) #1;                   
        reset= 0;
        i = 0;
        j=0 ;
        //Enviar las intrucciones (out.coe)al modulo tx para cargarlas en memoria de instruccion
        while(ram[i] == ram[i])
        begin
            while(j<INST_WIDTH/WORD_WIDTH)
                begin
                    tx_in = ( ram[i] >> (j*WORD_WIDTH) );
                    tx_start = 1'b1;
                    @(negedge tx_done)tx_start = 1'b0;
                    #10000;
                    j = j + 1;
                end
            i = i + 1 ;
            j = 0;
        end
        tx_start = 1'b0;
        rea = 1'b1;
        mem_enable = 1'b1;
        pc_src = 2'b00;  
        @(posedge clk) #1;  
        enable = 1'b1; 
        //read_enable = 1'b1; 
        //uart_enable = 1'b1;
	    IF_ID_write = 1'b1;
        repeat(5)                  //Lectura primeras 10 instrucciones
	   
        @(posedge clk) #1;
        @(negedge clk) #1;
        IF_ID_write = 1'b0;
        pc_src = 2'b01;
        @(negedge clk) #1;
        reset = 1'b1;
        pc_src = 2'b10;
        @(negedge clk) #1;
        pc_src = 2'b11;
        @(negedge clk) #1;
        $finish;
    end
    
    //Instancias de modulos
    UART_top UART_top (
        //inputs
        .top_uart_clock(clk),
        .top_uart_reset(reset),
        .top_uart_rx_in(rx_in),
        .top_uart_tx_start(tx_start),
        .top_uart_tx_in(tx_in),
        
        //outputs
        .top_uart_tx_out(rx_in), //connect tx_out rx_in
        .top_uart_tx_done(tx_done),
        .top_uart_write_en(wea),
        .top_uart_tick(tick),
        .top_uart_data_write(instruction_data_write),
        .top_uart_write_addr(write_addr)
    );
    
    IF_top IF_top(
        //Inputs
        .top1_clock(clk_out),
        .top1_reset(reset),
        .top1_write_addr(write_addr),
        .top1_write_data(instruction_data_write),
        .top1_pc_offset(pc_offset),
        .top1_pc_register(pc_register),
        
        //Input control signals
        .top1_pc_enable(enable),
        .top1_IF_ID_write(IF_ID_write),
        .top1_mux_selector(pc_src),
        .top1_write_e(wea),
        .top1_read_e(rea),
        .top1_mem_enable(mem_enable),
        
        //outputs
        .top1_sumador_out(pc_adder),
        .top1_memoria_out(instruction)
    );  
    
endmodule
