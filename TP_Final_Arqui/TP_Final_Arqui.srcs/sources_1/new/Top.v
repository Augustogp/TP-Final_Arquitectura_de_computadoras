`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.07.2021 17:52:08
// Design Name: 
// Module Name: Top
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


module Top#(
        
        parameter   N_BITS_WORD = 8,       // Bits de 
        parameter   N_BITS_PC = 32, // Bits de ancho de la memoria
        parameter   N_BITS_INST = 32,       // Bits de direcciones de la memoria
        parameter   N_BITS_INST_INDEX = 26, // Bits program counter
        parameter   N_BITS_REGISTERS = 32,        // Bits de direccion a escribir 
        parameter   N_BITS_RD = 5,
        parameter   N_BITS_RT = 5,
        parameter   N_BITS_RS = 5,
        parameter   N_BITS_ALU_OP = 4,
        parameter   N_BITS_REGISTERS_DEPTH = 32,
        parameter   N_BITS_REGISTERS_ADDR = $clog2(N_BITS_REGISTERS_DEPTH),
        parameter   RS_SBIT = 21,
        parameter   RT_SBIT = 16,
        parameter   RD_SBIT = 11
    )
    (
        input   wire    i_clock, i_reset, i_start, i_tx_start,
        input   wire    [N_BITS_WORD - 1 : 0]   i_tx,
        
        output  wire    tx_done
    );
    
    //-------------UART out to IF in-----------------------
    
    wire        wr_enable, rd_enable, enable_uart;
    wire    [N_BITS_PC - 1 : 0] wr_addr;
    wire    [N_BITS_INST - 1 : 0]   instr_data_wr;
    //Uart Input
    wire        rx_in;
    
    //-------------Unidad de cortocircuitos out to Ex in-----------------------
    wire    [1 : 0] operand1_corto;
    wire    [1 : 0] operand2_corto;
    
    //-------------Stall unit out conections-----------------------
    wire    pc_enable;
    wire    IF_ID_wr;
    wire    control_enable;
    
    //-------------IF connections-----------------------
    
    //-------------IF out to IF in-----------------------
    wire    [N_BITS_INST_INDEX - 1 : 0] IF_pc_instr_index;
    
    //-------------IF out to ID in-----------------------
    wire    [N_BITS_PC - 1 : 0] IF_pc_adder;
    wire    [N_BITS_INST - 1 : 0]   IF_instr;
    
    //-------------ID connections-----------------------
    
    //-------------ID out to EX in-----------------------
    wire    [N_BITS_PC - 1 : 0] ID_pc_adder;
    wire    [N_BITS_REGISTERS - 1 : 0]  ID_rd_data1, ID_rd_data2;
    wire    [N_BITS_REGISTERS - 1 : 0]  ID_offset;
    wire    [N_BITS_RT - 1 : 0] ID_rt;
    wire    [N_BITS_RD - 1 : 0] ID_rd;
    
    //-------------ID out to Unidad corto in-----------------------
    wire    [N_BITS_RS - 1 : 0] ID_rs;
    
    //-------------Control out to Ex in-----------------------
    wire    [1 : 0] ID_alu_src, ID_reg_dst;
    wire    [N_BITS_ALU_OP - 1 : 0] ID_alu_op;
    
    //-------------Control connections-----------------------
    wire    [1 : 0]                     ID_pc_src;
    wire                                IF_ID_reset;
    wire    [N_BITS_REGISTERS - 1 : 0]  rd_data1_out;
    
    wire                                ID_branch, ID_mem_wr, ID_reg_wr;
    wire                                EX_MEM_reset;
    wire                                ID_mem_rd;
    wire    [1 : 0]                     ID_mem_to_reg; 
    
    //-------------EX connections-----------------------

    //-------------EX out to MEM in-----------------------
    wire    [N_BITS_PC - 1 : 0] EX_mem_pc_adder;
    wire    [N_BITS_REGISTERS - 1 : 0]  EX_alu_result;
    wire    [N_BITS_REGISTERS_ADDR - 1 : 0] EX_wr_addr;
    wire    [N_BITS_REGISTERS - 1 : 0]  EX_rd_data;
    wire    [N_BITS_RD - 1 : 0] EX_rd;
    
    //-------------Control signals-----------------------
    wire                EX_mem_wr;
    wire    [1 : 0]     EX_mem_to_reg;
    wire                EX_MEM_reg_wr;
    wire                EX_mem_rd;
    
    //-------------EX out to IF in-----------------------
    wire    [N_BITS_PC - 1 : 0] EX_pc_adder;
    
    //-------------EX out to ID in-----------------------
    wire    EX_zero;
    wire    EX_branch;
    
    //-------------MEM connections-----------------------
    
    //-------------MEM out to WB in-----------------------
    wire    [N_BITS_REGISTERS - 1 : 0] MEM_rd_data, MEM_alu_result;
    wire    [N_BITS_PC - 1 : 0]        MEM_pc_adder;
    wire    [1 : 0]                    MEM_mem_to_reg;
    
    //-------------MEM out to ID in-----------------------
    wire    [N_BITS_REGISTERS_ADDR - 1 : 0] MEM_wr_addr;
    
    //-------------MEM out to Unidad Cortocircuitos-----------------------
    wire    [N_BITS_RD - 1 : 0]         MEM_rd;
    wire                                MEM_WB_reg_wr;
    
    //-------------WB connections-----------------------
    
    //-------------WB out ID in-----------------------
    wire    [N_BITS_REGISTERS - 1 : 0]  WB_wr_data;
    
    
    //-------------MODULES-----------------------
    
    UART_top top_uart
    (
        //Inputs
        .top_uart_clock(i_clock), 
        .top_uart_reset(i_reset),
        .top_uart_tx_start(i_tx_start),
        .top_uart_tx_in(i_tx),
        .top_uart_rx_in(rx_in),
        
        // Outputs
        .top_uart_tx_out(rx_in),
        .top_uart_tx_done(tx_done),
        .top_uart_read_en(rd_enable), 
        .top_uart_write_en(wr_enable),
        .top_uart_enable(enable_uart),
        .top_uart_write_addr(wr_addr),
        .top_uart_data_write(instr_data_wr)
    );
    
    IF_top top_if
    (
        // Inputs
        .top1_clock(i_clock),
        .top1_reset(i_reset),
        .top1_write_addr(wr_addr),     // Direccion de escritura de instruccion
        .top1_write_data(instr_data_wr),     // Instruccion a escribir en memoria de instrucciones
        .top1_pc_offset(EX_pc_adder),      // PC <= PC + 1 + Offset 
        .top1_pc_register(rd_data1_out),    // PC <= rs (read_data1_out)
        .top1_mux_selector(ID_pc_src),   // Selector del multiplexor
        .top1_write_e(wr_enable),        // Enable para escritura debug
        .top1_read_e(rd_enable),         // Enable para lecutra debug
        .top1_pc_enable(pc_enable & enable_uart),      // PC enable
        .top1_mem_enable(enable_uart),     // Memoria enable
        .top1_IF_ID_write(IF_ID_wr & enable_uart),    // Control de escritura en esta etapa
        .top1_IF_ID_reset(IF_ID_reset),    // Control de reset en esta etapa
        
        //Outputs
        .top1_sumador_out(IF_pc_adder),    // Salida del sumador, seria la siguiente direccion de instruccion
        .top1_memoria_out(IF_instr)     // Actual instruccion que sale de la memoria de instrucciones   
    );
    
    Stall_Unit stall_unit
    (
        //Inputs
        .SU_start(i_start),
        .ID_EX_MemRead(ID_mem_rd),
        .IF_ID_rs(IF_instr[RS_SBIT + N_BITS_RS - 1 : RS_SBIT]),
        .IF_ID_rt(IF_instr[RT_SBIT + N_BITS_RT - 1 : RT_SBIT]),
        .ID_EX_rt(ID_rt),
        
        //Outputs
        .enable_pc(pc_enable),
        .control_enable(control_enable),
        .IF_ID_write(IF_ID_wr)    
    );
    
    ID_top top_id
    (
        // Inputs
        .top2_clock(i_clock),
        .top2_reset(i_reset),
        .top2_pc_adder_in(IF_pc_adder),
        .top2_instruction_in(IF_instr),
        .top2_wr_addr(MEM_wr_addr),     // Direccion de escritura de instruccion
        .top2_wr_data(WB_wr_data),     // Instruccion a escribir en memoria de instrucciones
        .top2_reg_wr_in(MEM_WB_reg_wr), 
        .top2_branch_in(EX_branch), 
        .top2_zero_in(EX_zero), 
        .top2_control_enable(control_enable), 
        .top2_ID_write_in(enable_uart),
        
        //Outputs
        .top2_pc_adder_out(ID_pc_adder),   
        .top2_read_data1_out(ID_rd_data1), 
        .top2_read_data2_out(ID_rd_data2),     // Actual instruccion que sale de la memoria de instrucciones   
        .top2_offset_out(ID_offset),
        .top2_rt_out(ID_rt),
        .top2_rd_out(ID_rd),
        .top2_rs_out(ID_rs),
        .top2_branch_out(ID_branch), 
        .top2_mem_rd_out(ID_mem_rd), 
        .top2_mem_wr_out(ID_mem_wr), 
        .top2_reg_wr_out(ID_reg_wr),
        .top2_alu_op_out(ID_alu_op),
        .top2_alu_src_out(ID_alu_src), 
        .top2_reg_dst_out(ID_reg_dst),
        .top2_mem_to_reg_out(ID_mem_to_reg),
        .top2_pc_src_out(ID_pc_src),
        .top2_IF_ID_reset(IF_ID_reset),
        .top2_EX_MEM_reset(EX_MEM_reset)
    );
    
    Unidad_Cortocircuito unidad_cortocircuito
    (
        //Inputs
        .EX_MEM_RegWrite(EX_MEM_reg_wr),
        .MEM_WB_RegWrite(MEM_WB_reg_wr),
        .ID_EX_rs(ID_rs),
        .ID_EX_rt(ID_rt),
        .EX_MEM_WriteAddr(EX_wr_addr),
        .MEM_WB_WriteAddr(MEM_wr_addr),
        
        //Outputs
        .operando1_corto(operand1_corto),
        .operando2_corto(operand2_corto)
    );
    
    EX_top top_ex
    (
        //Inputs
        .top3_clock(i_clock),
        .top3_reset(i_reset),
        .top3_pc_sumador_in(ID_pc_adder),     // Resultado de sumador de etapa IF
        .top3_offset(ID_offset),            // Offset que viene de extension de signo
        .top3_read_data1_in(ID_rd_data1),     // Dato 1 de banco de registros
        .top3_read_data2_in(ID_rd_data2),     // Dato 2 de banco de registros
        .top3_rd_in(ID_rd),             // Identificador de registro fuente rd
        .top3_rt_in(ID_rt),             // Identificador de registro fuente rt
        .top3_Mem_Wb_Write_data(WB_wr_data), // Dato que se escribe en la ultima etapa
        .top3_op1_corto(operand1_corto),         // Operando 1 de cortocircuito para control de mux4
        .top3_op2_corto(operand2_corto),         // Operando 2 de cortocircuito para control de mux5
        
        // Inputs de control
        .top3_enable(enable_uart),            // Enable de etapa EX                     
        .top3_ID_EX_reset(EX_MEM_reset),       // Reset de esta etapa
        .top3_mux3_control(ID_reg_dst),      // Control de mux3 
        .top3_Alu_control_oper(ID_alu_op),  // Control de codigo de operacion ALU
        .top3_mux1_2_control(ID_alu_src),    // Control de mux1 y mux2
        .Branch_in(ID_branch),
        .MemtoReg_in(ID_mem_to_reg),
        .MemRead_in(ID_mem_rd),
        .MemWrite_in(ID_mem_wr),
        .RegWrite_in(ID_reg_wr),//control signals not used in this stage
        
        // Outputs
        .top3_pc_sumador1_out(EX_pc_adder),   // Es la entrada al sumador (pc_sumador_in)
        .top3_pc_sumador2_out(EX_mem_pc_adder),   // Es la salida del sumador
        .top3_alu_result_out(EX_alu_result),    // Resultado de la ALU
        .top3_read_data2_out(EX_rd_data),    // Dato 2 del banco de registros que se pone como salida 
        .top3_write_addr_out(EX_wr_addr),    // Salida de mux3 con la direccion de escritura
        .top3_rd_out(EX_rd),             // Identificador de registro fuente rd
            
        // Oututs de control
        .top3_Branch(EX_branch),         // Salida de branch de control
        .top3_MemRead(EX_mem_rd),
        .top3_MemWrite(EX_mem_wr), 
        .top3_RegWrite(EX_MEM_reg_wr),
        .top3_zero_out(EX_zero),        // Control de cero en ALU  
        .top3_MemtoReg(EX_mem_to_reg)        
    );
    
    MEM_top top_mem
    (
        // Inputs
        .top4_clock(i_clock), 
        .top4_reset(i_reset),
        .top4_addr(EX_alu_result),
        .top4_write_data(EX_rd_data),
        .top4_write_addr(EX_wr_addr),
        .top4_pc_adder(EX_mem_pc_adder),
        .top4_rd(EX_rd),
        //Inputs control
        .top4_mem_wr(EX_mem_wr), 
        .top4_mem_rd(EX_mem_rd), 
        .top4_reg_wr(EX_MEM_reg_wr),
        .top4_mem_to_reg(EX_mem_to_reg),
        .top4_mem_enable(enable_uart),
        
        //Outputs
        .top4_read_data_out(MEM_rd_data), 
        .top4_alu_result_out(MEM_alu_result),
        .top4_write_addr_out(MEM_wr_addr),
        //Outputs control
        .top4_pc_adder_out(MEM_pc_adder),
        .top4_mem_to_reg_out(MEM_mem_to_reg),
        .top4_reg_write_out(MEM_WB_reg_wr),
        .top4_rd_out(MEM_rd)
    );
    
    WB_top top_wb
    (
        //Inputs
        .top5_read_data(MEM_rd_data),     // Dato leído en memoria de datos (store)
        .top5_alu_result(MEM_alu_result),    // Resultado de la Alu (instrucciones aritméticas/lógicas)
        .top5_return_addr(MEM_pc_adder),   // Segunda dirección siguiente de la instrucción JALR
       
        // Inputs de control
        .top5_Mem_to_Reg(MEM_mem_to_reg),        // Control de mux de WB 
        
        // Outputs
        .top5_write_data_out(WB_wr_data)     // Escritura en memoria     
    );
    
endmodule
