`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.03.2021 17:31:43
// Design Name: 
// Module Name: ALU
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

module ALU#(
        //Parameters
        parameter   N_BITS_REG = 32,
        parameter   N_BITS_ALU = 4
    )    
    (
        //Inputs
        input wire  [N_BITS_REG - 1 : 0]   Alu_operand_1,
        input wire  [N_BITS_REG - 1 : 0]   Alu_operand_2,
        input wire  [N_BITS_ALU - 1 : 0]   Alu_control_opcode,

        //Outputs
        output wire                         Zero_out,
        output reg  [N_BITS_REG - 1 : 0]    Alu_result_out 
    );
   
    always@(*) begin
        case(Alu_control_opcode)
            4'b0000 : Alu_result_out = Alu_operand_1 << Alu_operand_2;      //  SLL Shift left logical (r1<<r2)
            4'b0001 : Alu_result_out = Alu_operand_1 >> Alu_operand_2;      // SRL Shift right logical (r1>>r2)
            4'b0010 : Alu_result_out = Alu_operand_1 >>> Alu_operand_2;     // SRA  Shift right arithmetic (r1>>>r2)
            4'b0011 : Alu_result_out = Alu_operand_1 + Alu_operand_2;       // ADD Sum (r1+r2)
            4'b0100 : Alu_result_out = Alu_operand_1 - Alu_operand_2;       // SUB Substract (r1-r2)
            4'b0101 : Alu_result_out = Alu_operand_1 & Alu_operand_2;       // AND Logical and (r1&r2)
            4'b0110 : Alu_result_out = Alu_operand_1 | Alu_operand_2;       // OR Logical or (r1|r2)
            4'b0111 : Alu_result_out = Alu_operand_1 ^ Alu_operand_2;       // XOR Logical xor (r1^r2)
            4'b1000 : Alu_result_out = ~(Alu_operand_1 | Alu_operand_2);    // NOR Logical nor ~(r1|r2)
            4'b1001 : Alu_result_out = Alu_operand_1 < Alu_operand_2;       // SLT Compare (r1<r2)
            4'b1010 : Alu_result_out = Alu_operand_1 << Alu_operand_2;      // SLLV
            4'b1011 : Alu_result_out = Alu_operand_1 >> Alu_operand_2;      // SRLV
            4'b1100 : Alu_result_out = Alu_operand_1 >>> Alu_operand_2;     // SRAV
            4'b1101 : Alu_result_out = Alu_operand_1 << 16;                 // SLL16
            4'b1110 : Alu_result_out = (Alu_operand_1 == Alu_operand_2);    // NEQ         
            default : Alu_result_out = {N_BITS_REG{1'b0}}; 
        endcase
    end
    
    assign Zero_out = Alu_result_out == 0; // Si Alu_resul_out es igual a 0 se asigna un uno a Zero_out
       
endmodule
