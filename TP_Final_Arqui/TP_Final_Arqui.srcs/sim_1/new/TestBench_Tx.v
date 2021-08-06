`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.07.2021 21:16:55
// Design Name: 
// Module Name: TestBench_Tx
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


module TestBench_Tx#(
        parameter   N_BITS = 8
    );
    
    reg     [N_BITS - 1 : 0]  tb_tx_in;
    reg                       tb_clk;
    reg                       tb_reset;
    reg                       tb_tx_start;
    
    wire                      tb_tick;
    wire                      tb_tx_done;
    wire                      tb_tx_out;
      
    
    Baud_rate_gen Baud_rate_gen
    (
        .i_clock(tb_clk),     
        .i_reset(tb_reset), 
        .o_tick(tb_tick)
    );
    
    Tx tx
    (
        .s_tick(tb_tick),
        .tx(tb_tx_in), 
        .tx_start(tb_tx_start),
        .i_clock(tb_clk),
        .i_reset(tb_reset),
        
        .dout_tx(tb_tx_out),
        .o_tx_done(tb_tx_done)
    );
    
    always
    begin
        #10;
        tb_clk = ~tb_clk;
    end
    
    initial
	begin
	   tb_clk =           1'b0;
	   @(posedge tb_clk) #1;   
	   tb_reset =         1'b1;
	   repeat(10)                                  //Resetear y esperar 10 ciclos de reloj
	   @(posedge tb_clk) #1;                   
        tb_reset= 1'b0;
        tb_tx_in = 8'h55;
        tb_tx_start = 1'b1;                            //Comenzar transmision primer dato
	                               
        @(posedge tb_tx_done) #1;
        @(negedge tb_tx_done) #1;
        tb_tx_in = 8'h77;
        @(posedge tb_tx_done) #1;
        @(negedge tb_tx_done) #1;
        tb_tx_in = 8'h44;
        @(posedge tb_tx_done) #1;
        @(negedge tb_tx_done) #1;
        tb_tx_in = 8'h66;
        @(posedge tb_tx_done) #1;
        @(negedge tb_tx_done) #1;
        
        tb_tx_start = 1'b0;
        repeat(200)
        @(posedge tb_tick) #1;
        
        tb_tx_start = 1'b1;
        tb_tx_in = 8'h77;
        @(posedge tb_tx_done) #1;
        @(negedge tb_tx_done) #1;
        tb_tx_in = 8'h44;
        @(posedge tb_tx_done) #1;
        @(negedge tb_tx_done) #1;
        
        tb_tx_start = 1'b0;

	   $finish;
	   
	end
    
endmodule
