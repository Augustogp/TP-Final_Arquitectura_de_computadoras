`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.06.2021 14:58:41
// Design Name: 
// Module Name: Tx
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




module Tx
#(	
    parameter WORD_WIDTH = 8, //#Data Nbits
    parameter STOP_BIT_COUNT = 1 , //bits for stop signal
    parameter BIT_RESOLUTION = 16, //Number of s_ticks per bit sample
    parameter STOP_TICK_COUNT = STOP_BIT_COUNT * BIT_RESOLUTION,
    parameter BIT_COUNTER_WIDTH = $clog2(WORD_WIDTH),
    parameter TICK_COUNTER_WIDTH = $clog2(STOP_TICK_COUNT)
)
( 
input  i_clock, i_reset, s_tick, tx_start,
input  [WORD_WIDTH-1:0] tx, 
output  reg  o_tx_done,               //Must be checked externally to load new value or disable tx_start
output  reg  dout_tx
);
					 
localparam NSTATES = 4;
  
// One hot  state  constants
localparam  [NSTATES-1:0]
	IDLE  =  4'b0001, 
	START =  4'b0010, 
	DATA  =  4'b0100, 
	STOP  =  4'b1000; 

// Signal  declarations 
reg  [NSTATES-1:0]  state_reg, state_next;
reg  [TICK_COUNTER_WIDTH - 1:0]  s_reg, s_next; 
reg  [BIT_COUNTER_WIDTH:0]  n_reg, n_next; 
reg  [WORD_WIDTH-1:0]  b_reg, b_next; 
reg tx_done_reg;
reg tx_reg, tx_next;

//  FSMD memory ( states  &  DATA  registers )
always  @(posedge i_clock) 
	if (i_reset) 
		begin 
			state_reg  <=  IDLE; //comienzo en IDLE
			s_reg  <=  0; //contador de ticks
			n_reg  <=  0; //contador de bits
			b_reg  <=  0;//byte a transmitir
			tx_reg <= 0;
		end 
	else 
		begin 
			state_reg  <=  state_next ; 
			s_reg  <=  s_next; 
			n_reg  <=  n_next; 
			b_reg  <=  b_next; 
			tx_reg <= tx_next;
		end 

//  FSMD  next-state  logic 
always  @* 
begin 
	state_next  =  state_reg; 
	tx_done_reg  =  1'b0; 
	s_next  =  s_reg; 
	n_next  =  n_reg; 
	b_next  =  b_reg; 
	tx_next = tx_reg;

	case (state_reg) 
		IDLE:
			begin
				if  (tx_start) //si el bit de start = 1 ,comienza la transmision
					begin 
						state_next  =  START; //siguiente estado START
						s_next  =  0; //reseteo contador ticks
						b_next = tx;
					end 
			end
		START:
			begin
				if  (s_tick) 
					if  (s_reg==BIT_RESOLUTION-1) //cuento ticks hasta el final del STOP bit
						begin 
							state_next  =  DATA; //sampleo
							s_next  =  0; //reseteo contador de ticks/bits
							n_next  =  0; 
						end 
					else 
						s_next  =  s_reg  +  1;//contador ticks +1
			end
		DATA:
			begin
				tx_next = b_reg[0]; //Transmito el bit menos significativo
				if  (s_tick) 
					if  (s_reg==BIT_RESOLUTION-1) //sampleo cada 16 ticks
						begin 
							s_next  =  0; //Reseteo contador de ticks
							b_next  =  b_reg >> 1 ; //desplazo byte a la derecha
							if  (n_reg==(WORD_WIDTH - 1)) //al transmitir DBIT's
								state_next  =  STOP  ; //defino siguiente estado en STOP
							else 
								n_next  =  n_reg  +  1; //contador de bits + 1
						end 
					else 
						s_next  =  s_reg  +  1; //contador de ticks + 1
			end
		STOP: 
			begin
				if  (s_tick) 
					if  (s_reg == (STOP_TICK_COUNT - 1)) //Mantengo el bit de stop hasta 'stop_tick_count' ticks
						begin 
							state_next  =  IDLE;//vuelvo al IDLE
							tx_done_reg  = 1'b1;//seteo la flag del buff para cargar nuevo dato
						end 
				else 
					s_next  =  s_reg  +  1;//contador de ticks + 1
			end
	endcase

end

//Output logic
always@(*)
case(state_reg)
    IDLE :
    begin
    	dout_tx =  1'b1;//Genero bit de stop/idle (1) , Idle transmision signal hasta q se indique el comienzo de la transmision
    	o_tx_done = 0;
    end
    START :
    begin
    	dout_tx = 1'b0;//Genero bit de start (0) durante la etapa del start
    	o_tx_done = 0;
    end
    DATA :
    begin
    	dout_tx = tx_reg;//Transmitiendo bits del buffer (8)
    	o_tx_done = 0;
    end
    STOP :
    begin
    	dout_tx = 1'b1;//Genero bit de stop/idle (1) lo que dure etapa stop   
    	o_tx_done = tx_done_reg;//Al finalizar se setea la flag
    end
    default :
	begin
    	dout_tx = 0;
		o_tx_done = 0;
	end
endcase

endmodule
