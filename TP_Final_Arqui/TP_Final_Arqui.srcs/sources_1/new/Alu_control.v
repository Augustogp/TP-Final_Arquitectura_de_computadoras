`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.03.2021 20:42:53
// Design Name: 
// Module Name: Alu_control
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


module Alu_control#(
        //Parameters
        parameter   N_BITS_FUNC = 6,
        parameter   N_BITS_ALUOP = 4,
        parameter   N_BITS_ALUCON = 4,
        parameter   SLL_FUNCTIONCODE =  6'b000000,
        parameter   SRL_FUNCTIONCODE =  6'b000010,
        parameter   SRA_FUNCTIONCODE =  6'b000011,
        parameter   ADD_FUNCTIONCODE =  6'b100000,
        parameter   SUB_FUNCTIONCODE =  6'b100010,
        parameter   AND_FUNCTIONCODE =  6'b100100,
        parameter   OR_FUNCTIONCODE  =  6'b100101,
        parameter   XOR_FUNCTIONCODE =  6'b100110,
        parameter   NOR_FUNCTIONCODE =  6'b100111,
        parameter   SLT_FUNCTIONCODE =  6'b101010,
        parameter   SLLV_FUNCTIONCODE = 6'b000100,
        parameter   SRLV_FUNCTIONCODE = 6'b000110,
        parameter   SRAV_FUNCTIONCODE = 6'b000111
    )
    (
        // Inputs
        input wire  [N_BITS_FUNC - 1 : 0]   Alu_control_funcion,    // Codigo de instruccion para las Instrucciones tipo R 
        input wire  [N_BITS_ALUOP - 1 : 0]  Alu_control_oper,       // Tipo de instruccion       
        
        // Output
        output reg  [N_BITS_ALUCON - 1 : 0] Alu_control_opcode      // Señal que va a la ALU con el codigo de operacion
    );
    
    always@(*) begin
        case(Alu_control_oper)
            4'b0000:                                    // INSTRUCCIONES RTYPE 
                case(Alu_control_funcion)
                    SLL_FUNCTIONCODE :   Alu_control_opcode = 4'b0000;  //  SLL Shift left logical (r1<<r2)  
                    SRL_FUNCTIONCODE :   Alu_control_opcode = 4'b0001;  // SRL Shift right logical (r1>>r2)  
                    SRA_FUNCTIONCODE :   Alu_control_opcode = 4'b0010;  // SRA  Shift right arithmetic (r1>>>r2)
                    ADD_FUNCTIONCODE :   Alu_control_opcode = 4'b0011;  // ADD Sum (r1+r2)
                    SUB_FUNCTIONCODE :   Alu_control_opcode = 4'b0100;  // SUB Substract (r1-r2)
                    AND_FUNCTIONCODE :   Alu_control_opcode = 4'b0101;  // AND Logical and (r1&r2)
                    OR_FUNCTIONCODE :    Alu_control_opcode = 4'b0110;  // OR Logical or (r1|r2)
                    XOR_FUNCTIONCODE :   Alu_control_opcode = 4'b0111;  // XOR Logical xor (r1^r2)
                    NOR_FUNCTIONCODE :   Alu_control_opcode = 4'b1000;  // NOR Logical nor ~(r1|r2)
                    SLT_FUNCTIONCODE :   Alu_control_opcode = 4'b1001;  // SLT Compare (r1<r2)
                    SLLV_FUNCTIONCODE :  Alu_control_opcode = 4'b1010;  // SLLV
                    SRLV_FUNCTIONCODE :  Alu_control_opcode = 4'b1011;  // SRLV
                    SRAV_FUNCTIONCODE :  Alu_control_opcode = 4'b1100;  // SRAV
                    default :            Alu_control_opcode = Alu_control_opcode;                      
                endcase                
            4'b0001 : Alu_control_opcode = 4'b0011;  // INSTRUCCION ITYPE - ADDI -> ADD de ALU
            4'b0010 : Alu_control_opcode = 4'b0101;  // INSTRUCCION ITYPE - ANDI -> AND de ALU
            4'b0011 : Alu_control_opcode = 4'b0110;  // INSTRUCCION ITYPE - ORI -> OR de ALU
            4'b0100 : Alu_control_opcode = 4'b0111;  // INSTRUCCION ITYPE - XORI -> XOR de ALU
            4'b0101 : Alu_control_opcode = 4'b1101;  // INSTRUCCION ITYPE - LUI -> SLL16 de ALU
            4'b0110 : Alu_control_opcode = 4'b1001;  // INSTRUCCION ITYPE - SLTI -> SLT de ALU
            4'b0111 : Alu_control_opcode = 4'b0100;  // INSTRUCCION ITYPE - BEQ -> SUB de ALU
            4'b1000 : Alu_control_opcode = 4'b1110;  // INSTRUCCION ITYPE - BNE -> NEQ de ALU
            default : Alu_control_opcode = Alu_control_opcode;
        endcase
    end
    
endmodule
