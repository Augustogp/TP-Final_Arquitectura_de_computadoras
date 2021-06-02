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


module Tx#(      
        parameter   N_BITS = 8,
        parameter   N_BITS_P = 4,
        parameter   N_BITS_ESTADO = 2,
        parameter   N_BITS_RESOLUTION = 16
    )
    (
        //Inputs
        input   wire    s_tick,
        input   wire    [N_BITS-1:0]    tx, //00110011
        input   wire    tx_start,
        input   wire    i_clock,
        input   wire    i_reset,
        
        //Outputs
        output  reg     dout_tx,
        output  reg     o_tx_done
        //output  reg                     tx_done_tick //salida en 1 si se termino de transmitir el byte
    );
    
    localparam [N_BITS_ESTADO - 1:0]    IDLE    =   2'b00;
    localparam [N_BITS_ESTADO - 1:0]    DATA    =   2'b01;
    localparam [N_BITS_ESTADO - 1:0]    STOP    =   2'b10;
    
    // Declaracion de señales
    reg     [N_BITS_P-1:0]   contador_tx, next_contador_tx;
    reg     [N_BITS_ESTADO - 1:0]   estado, next_estado;
    reg     [N_BITS_P-1:0]   bit_count, next_bit_count; // Registro para ver por cual de los 8 bits va
    reg     next_o_tx_done;
    
    always@(posedge i_clock) begin
        if(i_reset) begin
            estado <= IDLE;
            contador_tx <= 0;
            bit_count <= 0;
            o_tx_done <= 0;
        end
        else begin 
            if(s_tick)
                estado <= next_estado;
                contador_tx <= next_contador_tx;
                bit_count <= next_bit_count;
                o_tx_done <= next_o_tx_done;
        end
    end
    
    always@(posedge s_tick) begin
        //if(s_tick == 1)
        //begin
            next_contador_tx = contador_tx;
            next_bit_count = bit_count;
            next_o_tx_done = 0;
            case(estado)
                IDLE: //Esta en estado de IDLE (todavia no llego el tick 7)
                    begin
                        if(tx_start == 1 && contador_tx == 4'b0000) 
                        begin
                            //tx_done_tick = 1'b0;
                            next_estado = DATA; //Ya llego al punto medio, y empieza a tomar datos
                            next_contador_tx = 1'b0;
                            next_bit_count = 4'b0000; 
                            dout_tx = 1'b0; //Se le pasa un 0 en idle porque con el primer 0 es el start
                        end
                        else 
                            begin
                                next_contador_tx = next_contador_tx + 1'b1;
                            end
                    end
                DATA: //El contador ya llego a 7 y ahora se reinicia y empieza a tomar datos.
                    begin
                        next_contador_tx = next_contador_tx + 1'b1;
                        if(contador_tx == 4'b1111) //si el contador llega a 15 ya se tiene el valor de un bit
                        begin
                            next_estado = DATA; //Sigue siendo DATA porque talvez necesite mas bits
                            case(bit_count)                                    
                                4'b0000 : dout_tx = tx >> 7;            
                                4'b0001 : dout_tx = tx >> 6;            
                                4'b0010 : dout_tx = tx >> 5;    
                                4'b0011 : dout_tx = tx >> 4; 
                                4'b0100 : dout_tx = tx >> 3;
                                4'b0101 : dout_tx = tx >> 2;
                                4'b0110 : dout_tx = tx >> 1;
                                4'b0111 : dout_tx = tx;
                                default : dout_tx = 0;
                            endcase
                            if(bit_count == 3'b111) //Si es 7 bit count significa que ya paso los 8 bits.
                            begin 
                                next_estado = STOP; //Quiere decir que el proximo bit va a ser de STOP
                                next_bit_count = 1'b0;
                                next_contador_tx =  1'b0;
                                //tx_done_tick <= 1'b0;
                            end
                            else begin
                                next_bit_count = next_bit_count + 1'b1; //Se dice que se transmitio un bit mas
                                next_contador_tx = 1'b0; //Al ser contador de 4 bits, a los 15 se reinicia con el +1
                            end                    
                        end     
                    end                            
                STOP:
                    begin
                        next_contador_tx = next_contador_tx + 1'b1;
                        if(contador_tx == 4'b1111)
                        begin
                           //rx_done_tick <= 1'b1;
                           dout_tx = 1'b1; //Se transmite el bit de stop
                           next_o_tx_done = 1'b1;
                           next_estado = IDLE; //Va a quedar en IDLE nuevamente hasta que se vacie el dato
                           next_contador_tx = 1'b1; //se reinicia el contador
                        end 
                    end
                        
                default: 
                    begin
                        //tx_done_tick <= 1'b0; 
                        next_estado = IDLE; //Esta todo en 0 va a pasar a estado de IDLE y esperar a los 7 ticks
                        next_contador_tx = 1'b0;
                        next_bit_count = 1'b0; 
                        dout_tx = 1'b1;
                    end             
                endcase             
        //end
    end
    
    //Instanciacion de modulos
 //   baud_rate_gen baud_rate_gen(.o_tick(s_tick));
    
endmodule

