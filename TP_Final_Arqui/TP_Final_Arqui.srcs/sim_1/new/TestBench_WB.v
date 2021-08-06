`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.07.2021 20:43:13
// Design Name: 
// Module Name: TestBench_WB
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


module TestBench_WB#(
        parameter   N_BITS_REG = 32,
        parameter   N_BITS_MUX_CON = 2
    );
    
    reg     [N_BITS_REG - 1 : 0]        tb_rd_data;
    reg     [N_BITS_REG - 1 : 0]        tb_alu_result;
    reg     [N_BITS_REG - 1 : 0]        tb_return_addr;
    reg     [N_BITS_MUX_CON - 1 : 0]    tb_mem_to_reg;
    wire     [N_BITS_REG - 1 : 0]        tb_wr_data_o;

    
    WB_top WB_top
    (
        //Inputs
        .top5_read_data(tb_rd_data),     
        .top5_alu_result(tb_alu_result),    
        .top5_return_addr(tb_return_addr),   
       
        // Inputs de control
        .top5_Mem_to_Reg(tb_mem_to_reg),        // Control de mux de WB 
        
        // Outputs
        .top5_write_data_out(tb_wr_data_o)     // Escritura en memoria     
    );
    
    integer i;
    
    initial
    begin
        i = 0;
        while(i < 4)
        begin
            tb_rd_data = i + 10;
            tb_alu_result = i + 15;
            tb_return_addr = i + 20;
            tb_mem_to_reg = i;
            i = i + 1;
            #10;
        end
    end
    
    
endmodule
