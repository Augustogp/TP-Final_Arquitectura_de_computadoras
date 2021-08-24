`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.06.2021 14:59:00
// Design Name: 
// Module Name: Rx
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


module Rx
#(	
    parameter WORD_WIDTH = 8, //#Data Nbits
    parameter STOP_BIT_COUNT = 1 , //bits for stop signal
    parameter BIT_RESOLUTION = 16, //Number of s_ticks per bit sample
    parameter STOP_TICK_COUNT = STOP_BIT_COUNT * BIT_RESOLUTION,
    parameter BIT_COUNTER_WIDTH = $clog2(WORD_WIDTH),
    parameter TICK_COUNTER_WIDTH = $clog2(STOP_TICK_COUNT)
)
( 
    input  i_clock, i_reset, 
    input  rx,  s_tick, 
    output  reg  rx_done_tick, 
    output  reg  [WORD_WIDTH-1:0]  dout
);
					 
localparam STATE_WIDTH = 4;
  
// One hot  state  constants
localparam  [STATE_WIDTH:0]
	IDLE  =  4'b0001, 
	START =  4'b0010, 
	DATA  =  4'b0100, 
	STOP  =  4'b1000; 

// Signal  declarations 
reg  [STATE_WIDTH-1:0]  state_reg, state_next;
reg  [TICK_COUNTER_WIDTH - 1:0]  s_reg, s_next; 
reg  [BIT_COUNTER_WIDTH:0]  n_reg, n_next; 
reg  [WORD_WIDTH-1:0]  b_reg, b_next; 
reg done_reg;

//  FSMD memory ( states  &  DATA  registers )
always  @(posedge i_clock) 
	if (i_reset) 
		begin 
			state_reg  <=  IDLE; //comienzo en IDLE
			s_reg  <=  0; //contador de s_ticks
			n_reg  <=  0; //contador de bits
			b_reg  <=  0;//byte a recibir
		end 
	else 
		begin 
			state_reg  <=  state_next ; 
			s_reg  <=  s_next; 
			n_reg  <=  n_next; 
			b_reg  <=  b_next; 
		end 

//  FSMD  next-state  logic 
always  @* 
begin 
	state_next  =  state_reg; 
	done_reg  =  1'b0; 
	s_next  =  s_reg; 
	n_next  =  n_reg; 
	b_next  =  b_reg; 

	case (state_reg) 
		IDLE:
			if  (~rx) //si el bit rx = 0 (START)
			begin 
				state_next  =  START; //siguiente estado START
				s_next  =  0; //i_reseteo contador s_ticks
			end 
		START:
			if  (s_tick) 
				if  (s_reg==BIT_RESOLUTION/2) //cuento s_ticks hasta la mitad del STOP bit
					begin 
						state_next  =  DATA; //sampleo
						s_next  =  0; //i_reseteo contador de s_ticks/bits
						n_next  =  0; 
					end 
				else 
					s_next  =  s_reg  +  1;//contador s_ticks +1
		DATA:
			if  (s_tick) 
				if  (s_reg==BIT_RESOLUTION-1) //sampleo cada 16 s_ticks con desfasaje de 8
					begin 
						s_next  =  0; 
						//desplazo byte a la izq y agrego el bit rx al Lsb
						b_next  =  {rx , b_reg  [WORD_WIDTH-1 : 1]} ; 
						if  (n_reg==(WORD_WIDTH - 1)) //al recibir DBIT's
							state_next  =  STOP  ; //defino siguiente estado en STOP
						else 
							n_next  =  n_reg  +  1; //contador de bits + 1
					end 
				else 
					s_next  =  s_reg  +  1; //contador de s_ticks + 1
		STOP: 
			if  (s_tick) 
				if  (s_reg == (STOP_TICK_COUNT - 1)) //Cuento s_ticks de bit de STOP
					begin 
						state_next  =  IDLE;//vuelvo al IDLE
						done_reg  = 1'b1;//seteo la flag del buff para cargar nuevo dato
					end 
				else 
					s_next  =  s_reg  +  1;//contador de s_ticks + 1
		default:
		begin
            state_next  =  IDLE; 
            done_reg  =  0; 
            s_next  =  0; 
            n_next  =  0; 
            b_next  =  0; 
        end
	endcase

end

//Output logic
always@(*)
case(state_reg)
    IDLE :
    begin
    dout = dout;//Mantain dout and done flag till start recieving again
    rx_done_tick = 0;
    end
    START :
    begin
    dout = 0;
    rx_done_tick = 0;
    end
    DATA :
    begin
    dout = 0;
    rx_done_tick = 0;
    end
    STOP :
    begin
    dout = b_reg;//Set dout and done flag        
    rx_done_tick = done_reg;
    end
    default :
    dout = 0;
endcase

endmodule
