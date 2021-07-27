`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.03.2021 15:13:24
// Design Name: 
// Module Name: EX_top
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


module EX_top#(
        
        parameter   N_BITS_PC = 32,         // Bits del PC
        parameter   N_BITS_INST = 32,       // Bits de instruccion
        parameter   N_BITS_REG = 32,        // Bits de registros
        parameter   N_BITS_RT = 5,          // Bits de rt
        parameter   N_BITS_RD = 5,          // Bits de rd
        parameter   N_BITS_ALUOP = 4,       // Bits de codigo de operacion ALU
        parameter   N_BITS_ALUCON = 4,      // Bits de control de operacion ALU 
        parameter   N_BITS_REG_ADDR = $clog2(N_BITS_REG), // Bits de registro de direccion (4 bits)
        parameter   N_BITS_MUX_CON = 2      // Bits para control de mux
    )
    (
        //Inputs
        input wire                          top3_clock,
        input wire                          top3_reset,
        input wire [N_BITS_PC - 1 : 0]      top3_pc_sumador_in,     // Resultado de sumador de etapa IF
        input wire [N_BITS_REG - 1 : 0]     top3_offset,            // Offset que viene de extension de signo
        input wire [N_BITS_REG - 1 : 0]     top3_read_data1_in,     // Dato 1 de banco de registros
        input wire [N_BITS_REG - 1 : 0]     top3_read_data2_in,     // Dato 2 de banco de registros
        input wire [N_BITS_RD - 1 : 0]      top3_rd_in,             // Identificador de registro fuente rd
        input wire [N_BITS_RT - 1 : 0]      top3_rt_in,             // Identificador de registro fuente rt
        input wire [N_BITS_REG - 1 : 0]     top3_Mem_Wb_Write_data, // Dato que se escribe en la ultima etapa
        input wire [N_BITS_MUX_CON - 1:0]   top3_op1_corto,         // Operando 1 de cortocircuito para control de mux4
        input wire [N_BITS_MUX_CON - 1:0]   top3_op2_corto,         // Operando 2 de cortocircuito para control de mux5
        
        // Inputs de control
        input wire                          top3_enable,            // Enable de etapa EX                     
        input wire                          top3_ID_EX_reset,       // Reset de esta etapa
        input wire [N_BITS_MUX_CON - 1:0]   top3_mux3_control,      // Control de mux3 
        input wire [N_BITS_ALUCON - 1:0]    top3_Alu_control_oper,  // Control de codigo de operacion ALU
        input wire [N_BITS_MUX_CON - 1:0]   top3_mux1_2_control,    // Control de mux1 y mux2
        input wire                          MemRead_in,MemWrite_in,Branch_in,RegWrite_in,//control signals not used in this stage
        input wire [1:0]                    MemtoReg_in,
        
        // Outputs
        output reg [N_BITS_PC - 1 : 0]          top3_pc_sumador1_out,   // Es la entrada al sumador (pc_sumador_in)
        output reg [N_BITS_PC - 1 : 0]          top3_pc_sumador2_out,   // Es la salida del sumador
        output reg [N_BITS_REG - 1 : 0]         top3_alu_result_out,    // Resultado de la ALU
        output reg [N_BITS_REG - 1 : 0]         top3_read_data2_out,    // Dato 2 del banco de registros que se pone como salida 
        output reg [N_BITS_REG_ADDR - 1 : 0]    top3_write_addr_out,    // Salida de mux3 con la direccion de escritura
        output reg [N_BITS_RD - 1 : 0]          top3_rd_out,             // Identificador de registro fuente rd
            
        // Oututs de control
        output reg top3_Branch, top3_MemRead, top3_MemWrite, top3_RegWrite,
        output reg top3_zero_out,        // Control de cero en ALU  
        output reg [1:0] top3_MemtoReg        
    );
    
    // Cables internos
    wire [N_BITS_REG - 1 : 0]       cable_Alu_operando1;
    wire [N_BITS_REG - 1 : 0]       cable_Alu_operando2;
    wire [N_BITS_ALUCON - 1 : 0]    cable_Alu_control_opcode;
    wire [N_BITS_ALUOP -1 : 0]      cable_Alu_control_oper;
    wire [N_BITS_REG - 1 : 0]       cable_mux1_out;
    wire [N_BITS_REG - 1 : 0]       cable_mux2_out;
    wire [N_BITS_PC - 1 : 0]        cable_pc_sumador_out;    
    wire                            cable_Zero_out;
    wire [N_BITS_REG - 1 : 0]       cable_Alu_result_out;
    wire [N_BITS_REG_ADDR - 1 : 0]  cable_write_addr_out;   

 
    always@(posedge top3_clock) begin
        if(top3_reset) begin
            top3_pc_sumador1_out    <= 0;
            top3_pc_sumador2_out    <= 0; 
            top3_alu_result_out     <= 0;
            top3_read_data2_out     <= 0; 
            top3_write_addr_out     <= 0;
            top3_rd_out             <= 0;
            top3_Branch             <= 0;
            top3_MemRead            <= 0;
            top3_MemWrite           <= 0;
            top3_MemtoReg           <= 0;    
            top3_RegWrite           <= 0;
            top3_zero_out           <= 0;                
        end
        
        else begin
            if(top3_ID_EX_reset && top3_enable) begin
                top3_pc_sumador1_out    <= top3_pc_sumador1_out;
                top3_pc_sumador2_out    <= top3_pc_sumador2_out; 
                top3_alu_result_out     <= top3_alu_result_out;
                top3_read_data2_out     <= top3_read_data2_out; 
                top3_write_addr_out     <= top3_write_addr_out;
                top3_rd_out             <= top3_rd_out;
                top3_Branch             <= top3_Branch;
                top3_MemRead            <= top3_MemRead;
                top3_MemWrite           <= top3_MemWrite;
                top3_MemtoReg           <= top3_MemtoReg;
                top3_RegWrite           <= top3_RegWrite;
                top3_zero_out           <= top3_zero_out;
            end
            else if (top3_enable) begin
                top3_pc_sumador1_out    <= top3_pc_sumador_in;
                top3_pc_sumador2_out    <= cable_pc_sumador_out; 
                top3_alu_result_out     <= cable_Alu_result_out;
                top3_read_data2_out     <= top3_read_data2_in; 
                top3_write_addr_out     <= cable_write_addr_out;
                top3_rd_out             <= top3_rd_in;
                top3_Branch             <= Branch_in;
                top3_MemRead            <= MemRead_in;
                top3_MemWrite           <= MemWrite_in;
                top3_MemtoReg           <= MemtoReg_in;
                top3_RegWrite           <= RegWrite_in;
                top3_zero_out           <= cable_Zero_out;                
            end                           
        end
    end
    
    // Instancias de modulos
    
    Sumador Sumador_EX(
        .in_sum_1(top3_pc_sumador_in),
        .in_sum_2(top3_offset),
        .out_sum_mux(cable_pc_sumador_out)
    );       

    Mux_2a1 Mux1_EX(
        .in_mux_control(top3_mux1_2_control[0]),
        .in_mux_1(top3_read_data1_in),
        .in_mux_2(top3_read_data2_in),
        .out_mux(cable_mux1_out)
    );
    
    Mux_2a1 Mux2_EX(
        .in_mux_control(top3_mux1_2_control[1]),
        .in_mux_1(top3_offset),
        .in_mux_2(top3_read_data2_in),
        .out_mux(cable_mux2_out)
    );
    
    Mux_4a1 Mux3_EX(
        .in_mux_control(top3_mux3_control),
        .in_mux_1(top3_rt_in),
        .in_mux_2(top3_rd_in),
        .in_mux_3(5'b11111),    // 31 para la instruccion JAL
        .in_mux_4(1'b0),        // No se usa esta entrada
        .out_mux(cable_write_addr_out)
    );
    
    Mux_4a1 Mux4_EX(
        .in_mux_control(top3_op1_corto),
        .in_mux_1(cable_mux1_out),
        .in_mux_2(cable_Alu_result_out),
        .in_mux_3(top3_Mem_Wb_Write_data),
        .in_mux_4(1'b0),        // No se usa esta entrada
        .out_mux(cable_Alu_operando1)
    );
    
    Mux_4a1 Mux5_EX(
        .in_mux_control(top3_op2_corto),
        .in_mux_1(cable_mux2_out),
        .in_mux_2(cable_Alu_result_out),
        .in_mux_3(top3_Mem_Wb_Write_data),
        .in_mux_4(1'b0),        // No se usa esta entrada
        .out_mux(cable_Alu_operando2)
    );
    
    ALU ALU_EX(
        .Alu_operand_1(cable_Alu_operando1),
        .Alu_operand_2(cable_Alu_operando2),
        .Alu_control_opcode(cable_Alu_control_opcode),
        .Zero_out(cable_Zero_out),
        .Alu_result_out(cable_Alu_result_out)
    );
    
    Alu_control Alu_Control_EX(
        .Alu_control_funcion(top3_offset[5:0]), 
        .Alu_control_oper(top3_Alu_control_oper),       
        .Alu_control_opcode(cable_Alu_control_opcode)
    );
    
    

    
endmodule
