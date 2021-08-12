`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.07.2021 15:37:23
// Design Name: 
// Module Name: TestBench_Top
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
/*
addi 11,2,5 ; reg[11] = reg[2] + 5
addi 0,0,1 ; f1 = reg[0] = reg[0] + 1 = 1
addi 1,2,1 ; f2 = reg[1] = reg[2] + 1 = 1
addi 2,0,0;  n = reg[2] = reg[0] + 0 = 1
addi 3,0,8 ; Niter = reg[3] = reg[0] + 8 = 9
beq 2,3,7 ;  if(n==Niter)jump pc+1+6 (i= 62 )
addi 2,2,1 ; n = n+1
add 4,0,1 ; reg[4] = reg[0] + reg[1]
add 0,0,1 ; f1 = f1 + f2
sub 1,0,1 ; f2 = f1 - f2
jalr 10,11 ; pc = reg[11] = 5 , reg[10] = 11       reg[2]= 2(10), 3(17), 5(24),8(31),13(38),21(45),34(52),55(59)
nop
*/

module TestBench_Topx#(
        parameter   N_BITS = 8,
        parameter   N_BITS_INSTR = 32,
        parameter   N_BITS_MEMORY_DEPTH = 12
    );
    
    //-----------------TOP-INPUTS-------------------
    reg     tb_clock, tb_reset, tb_start, tb_tx_start;
    reg     [N_BITS - 1 : 0]    tb_tx_in;
    
    //-----------------TOP-OUTPUTS-------------------
    wire    tb_tx_done;
    
    //-----------------Variables-------------------
    reg     [N_BITS_INSTR - 1 : 0]  ram     [N_BITS_MEMORY_DEPTH - 1 : 0];
    reg     [$clog2 (N_BITS_MEMORY_DEPTH) - 1 : 0]  i;
    reg     [$clog2 (N_BITS_MEMORY_DEPTH) - 1 : 0]  j;
    
    localparam STEP_BY_STEP_CODE    = 'b10111011;
    
    Top top
    (
        .i_clock(tb_clock), 
        .i_reset(tb_reset), 
        .i_start(tb_start), 
        .i_tx_start(tb_tx_start),
        .i_tx(tb_tx_in),
        
        .tx_done(tb_tx_done)
    );
        
    always
    begin
        #10
        tb_clock = !tb_clock;
    end
    
    initial
    #1
    begin
        tb_reset = 1'b1;
        tb_clock = 1'b0;
        tb_tx_start = 1'b0;
        tb_start = 1'b0;
        
        @(posedge tb_clock) #10000;
        tb_reset = 1'b0;
        @(posedge tb_clock) #1;
        
        $readmemh("out.mem",ram,0);
        i = 0;
        j = 0;
        
        while(ram[i] == ram[i])
        begin
            while(j < N_BITS_INSTR / N_BITS)
            begin
               // #10000;
                tb_tx_in = (ram[i] >> (j * N_BITS));
                tb_tx_start = 1'b1;
                @(negedge tb_tx_done) tb_tx_start = 1'b0;
                #10000;
                j = j + 1;
            end
            i = i + 1;
            j = 0;
        end
        
        send_step();
        tb_tx_start = 1'b0;
        tb_start = 1'b1;
        
        @(posedge tb_clock);
        @(posedge tb_clock);
        i = 1;
        while(i < 90)
        begin
            send_step();
            i = i + 1;
        end
        
        $finish;        
    end
    
    //Envia un step_code del uart al loader, para una ejecucion por step del pipeline
     task send_step;
        begin: send_step
            tb_tx_in = STEP_BY_STEP_CODE;
            tb_tx_start = 1'b1;
            @(negedge tb_tx_done) tb_tx_start = 1'b0;
            #10000;
            tb_tx_in = 'h00;
            tb_tx_start = 1'b1;
            @(negedge tb_tx_done) tb_tx_start = 1'b0;
            #10000;
        end
     endtask
    
    
endmodule
