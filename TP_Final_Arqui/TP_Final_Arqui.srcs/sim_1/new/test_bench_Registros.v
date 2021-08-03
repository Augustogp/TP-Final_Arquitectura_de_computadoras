`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.07.2021 17:29:14
// Design Name: 
// Module Name: test_bench_Registros
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
`define CLK_PERIOD      5

module test_bench_Registros();

    //Test Parameters
    parameter REGISTERS_DEPTH = 32;
    parameter REGISTERS_WIDTH = 32;
    parameter REGISTERS_ADDR_WIDTH = $clog2(REGISTERS_DEPTH);

    //Test Inputs
	reg clk;
	reg reset;
	reg control_write;
	reg enable;
	reg [REGISTERS_ADDR_WIDTH-1:0] read_register1;
	reg [REGISTERS_ADDR_WIDTH-1:0] read_register2;
	reg [REGISTERS_ADDR_WIDTH-1:0] write_register;
	reg [REGISTERS_WIDTH-1:0]     write_data;

//Test Outputs
	wire [REGISTERS_WIDTH-1:0] read_data1;
	wire [REGISTERS_WIDTH-1:0] read_data2;
	
	always #`CLK_PERIOD clk = !clk;
	
	initial
	begin
	   read_register1 = {REGISTERS_ADDR_WIDTH{1'b0}};//set addr del registro para lectura 1 en 0000
	   read_register2 = {REGISTERS_ADDR_WIDTH{1'b0}};//set addr del registro para lectura 2 en 0000
	   clk =           1'b0;
	   reset =         1'b1;
	   
	   repeat(10)                                  //Esperar 10 ciclos de reloj + #1
	   @(posedge clk) #1;                          //Escribir ffff en registro 0000
	   reset =         1'b0 ;
	   enable =        1'b1;
	   write_data =    {REGISTERS_WIDTH{1'b1}};
	   write_register = {REGISTERS_ADDR_WIDTH{1'b0}};
       control_write = 1'b1 ;
       
	   repeat(10)                                //Esperar 10 clocks mas y desactivar la escritura
	   @(posedge clk) #1;
	   control_write = 1'b0 ;
	   
	   //repeat(10)                                //Esperar 10 clocks mas y resetear todo
	   //@(posedge clk) #1;
	   //reset = 1'b1 ;
	   
	   //repeat(10)
	   //@(posedge clk) #1;
	   //reset = 1'b0 ;
	   
	   repeat(10)
	   @(posedge clk) #1;
	   $finish;
	   
	end

    //Instancia del modulo
	Banco_Registros Banco_Registros(
		.i_clock(clk), 
		.i_reset(reset),
		.i_enable(enable),
		.i_control_wr(control_write), 
		.i_ra(read_register1), 
		.i_rb(read_register2), 
		.i_reg_wr(write_register), 
		.i_data_wr(write_data), 
		.o_read_data1(read_data1), 
		.o_read_data2(read_data2)
    );


endmodule

