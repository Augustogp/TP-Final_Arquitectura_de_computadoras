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


module Rx#(
        parameter   N_BITS_ESTADO = 2,
        parameter   N_BITS = 8,
        parameter   N_BITS_P = 4
    )
    (
        //Inputs
        input   wire    s_tick,
        input   wire    rx,
        input   wire    i_clock,
        input   wire    i_reset,
        
        //Outputs
        output  reg     [N_BITS-1:0]    dout, //Registro que va a ir a la ALU
        output  reg                     rx_done_tick //salida en 1 si se termino de recibir el byte
    );

    localparam [N_BITS_ESTADO - 1:0]    IDLE    =   2'b00;
    localparam [N_BITS_ESTADO - 1:0]    DATA    =   2'b01;
    localparam [N_BITS_ESTADO - 1:0]    STOP    =   2'b10;
     
    reg     [N_BITS_P-1:0]   contador, next_contador;
    reg     [2:0]            estado;
    reg     [2:0]            next_estado;
    reg     [N_BITS_P-1:0]   bit_count, next_bit_count; // Registro para ver por cual de los 8 bits va


    always@(posedge i_clock) begin
        if(i_reset) begin
            estado <= IDLE;
            contador <= 0;
            bit_count <= 0;
        end
        else begin 
            if(s_tick)
                estado <= next_estado;
                contador <= next_contador;
                bit_count <= next_bit_count;                
        end
    end

    always@ (posedge s_tick) begin
        //if(s_tick == 1)
        //begin
            case(estado)
                IDLE: //Esta en estado de IDLE (todavia no llego el tick 7)
                    begin
                        if(rx == 0)
                        begin
                            //contador = contador + 1'b1; //quiere decir que todavia no llego a los primeros 7 ticks
                            if(contador == 4'b0111) 
                            begin
                                rx_done_tick = 1'b0;
                                next_estado = DATA; //Ya llego al punto medio, y empieza a tomar datos
                                next_contador = 1'b0;
                                next_bit_count = 1'b0; 
                                dout = 1'b0;
                            end
                            else 
                                begin
                                    next_contador = next_contador + 1'b1;
                                end 
                        end
                    end
                        
                DATA: //El contador ya llego a 7 y ahora se reinicia y empieza a tomar datos.
                    begin
                        next_contador = next_contador + 1'b1;
                        if(contador == 4'b1111) //si el contador llega a 15 ya se tiene el valor de un bit
                        begin
                            next_estado = DATA; //Sigue siendo DATA porque talvez necesite mas bits
                            dout = {dout[0 +: N_BITS-1 ],rx}; //Se va a ir concatenando hasta tener los 8 bits en dout 
                            //bit_count = bit_count + 1'b1; //Se dice que ya se concateno 1 bit mas
                            next_contador = next_contador + 1'b1; //Al ser contador de 4 bits, a los 15 se reinicia con el +1
                            if(bit_count == 3'b111) //Si es 7 bit count significa que ya paso los 8 bits.
                            begin 
                                next_estado = STOP; //Quiere decir que el proximo bit va a ser de STOP
                                next_bit_count = 1'b0;
                                rx_done_tick = 1'b0;
                            end 
                            else
                                next_bit_count = next_bit_count + 1'b1; //Se dice que ya se concateno 1 bit mas                   
                        end                            
                    end
                STOP:
                    begin
                        next_contador = next_contador + 1'b1;
                        if(contador == 4'b1111)
                        begin
                           rx_done_tick = 1'b1;
                           next_estado = IDLE; //Va a quedar en IDLE nuevamente hasta que se vacie el dato
                           next_contador = 1'b1; //se reinicia el contador
                        end 
                    end
                default: 
                    begin
                        rx_done_tick = 1'b0; 
                        next_estado = IDLE; //Esta todo en 0 va a pasar a estado de IDLE y esperar a los 7 ticks
                        next_contador = 1'b0;
                        next_bit_count = 1'b0; 
                        dout = 1'b0;
                    end             
                endcase             
        //end
    end
    
    //Instanciacion de modulos
   // baud_rate_gen baud_rate_gen(.o_tick(s_tick));
    
endmodule

