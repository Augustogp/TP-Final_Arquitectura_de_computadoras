`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.03.2021 12:59:26
// Design Name: 
// Module Name: Control
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


module Control#(

        //Parameters
        parameter   N_BITS_OPCODE    =   6,
        parameter   N_BITS_FUNCTION  =   6,
        parameter   N_BITS_ALUOP     =   4,
        
        parameter   R_TYPE_ALUCODE          =   4'b0000,
        parameter   LOAD_STORE_ADDI_ALUCODE =   4'b0001,
        parameter   ANDI_ALUCODE            =   4'b0010,
        parameter   ORI_ALUCODE             =   4'b0011,
        parameter   XORI_ALUCODE            =   4'b0100,
        parameter   LUI_ALUCODE             =   4'b0101,
        parameter   SLTI_ALUCODE            =   4'b0110,
        parameter   BEQ_ALUCODE             =   4'b0111,
        parameter   BNE_ALUCODE             =   4'b1000,
                
        parameter   R_TYPE_OPCODE    =   6'b000000,
        parameter   LB_OPCODE        =   6'b100000,
        parameter   LH_OPCODE        =   6'b100001,
        parameter   LW_OPCODE        =   6'b100011,
        parameter   LWU_OPCODE       =   6'b100111,
        parameter   LBU_OPCODE       =   6'b100100,
        parameter   LHU_OPCODE       =   6'b100101,
        parameter   SB_OPCODE        =   6'b101000,
        parameter   SH_OPCODE        =   6'b101001,
        parameter   SW_OPCODE        =   6'b101011,
        parameter   ADDI_OPCODE      =   6'b001000,
        parameter   ANDI_OPCODE      =   6'b001100,   
        parameter   ORI_OPCODE       =   6'b001101,    
        parameter   XORI_OPCODE      =   6'b001110,    
        parameter   LUI_OPCODE       =   6'b001111,   
        parameter   SLTI_OPCODE      =   6'b001010,    
        parameter   BEQ_OPCODE       =   6'b000100,        
        parameter   BNE_OPCODE       =   6'b000101,
        parameter   J_OPCODE         =   6'b000010,  
        parameter   JAL_OPCODE       =   6'b000011,   
        
        parameter   SLL_FUNCTIONCODE =  6'b000000,
        parameter   SRL_FUNCTIONCODE =  6'b000001,
        parameter   SRA_FUNCTIONCODE =  6'b000010,
        parameter   ADD_FUNCTIONCODE =  6'b000011,
        parameter   SUB_FUNCTIONCODE =  6'b000100,
        parameter   AND_FUNCTIONCODE =  6'b000101,
        parameter   OR_FUNCTIONCODE  =  6'b000110,
        parameter   XOR_FUNCTIONCODE =  6'b000111,
        parameter   NOR_FUNCTIONCODE =  6'b001000,
        parameter   SLT_FUNCTIONCODE =  6'b001001,
        parameter   SLLV_FUNCTIONCODE = 6'b001010,
        parameter   SRLV_FUNCTIONCODE = 6'b001011,
        parameter   SRAV_FUNCTIONCODE = 6'b001100,
        parameter   JALR_FUNCTIONCODE = 6'b001001,
        parameter   JR_FUNCTIONCODE   = 6'b001000
    )
    (
        //Input 
        input   wire    control_enable,
        input   wire    i_zero, i_branch,
        input   wire    [N_BITS_OPCODE - 1 : 0]     i_opcode,
        input   wire    [N_BITS_FUNCTION - 1 : 0]   i_function,
        
        //Output
        output  reg             o_reg_wr,
        output  reg     [1:0]   o_reg_dst,
        output  reg             o_branch,
        output  reg             o_mem_rd, o_mem_wr,
        output  reg     [1:0]   o_alu_src,o_pc_src,
        output  reg     [N_BITS_ALUOP - 1 : 0]  o_alu_op,
        output  reg     [1:0]   o_mem_to_reg,
        //Output en caso de branch, para realizar un flush 
        output  reg             if_id_reset,
        output  reg             ex_mem_reset  
    );
    
    always@(*)
    begin
        //Si se ejecuto un branch, flush sobre las instrucciones de ID, EX
        if(i_branch && i_zero) //VER PORQUE IMPORTA LA SEÑAL DE CERO
        begin
            if_id_reset = 1'b1;
            ex_mem_reset = 1'b1;
            o_pc_src = 2'b01;           //IF (PC <= PC + offset + 1)
            o_reg_wr = 1'b0;            //ID
            o_alu_src = 2'b00;          //EX
            o_alu_op = R_TYPE_ALUCODE;
            o_reg_dst = 2'b00;
            o_mem_rd = 1'b0;            //MEM
            o_mem_wr = 1'b0;
            o_branch = 1'b0;
            o_mem_to_reg = 2'b00;       //WB
        end
        
        else if(control_enable)
        begin
            if_id_reset = 1'b0;
            ex_mem_reset = 1'b0;
            case(i_opcode)
                //Register type instuctions
                R_TYPE_OPCODE:
                begin
                    case(i_function)
                        SLL_FUNCTIONCODE:
                        begin
                            o_pc_src = 2'b00;               //IF
                            o_reg_wr = 1'b1;                //ID
                            o_alu_src = 2'b11;              //EX
                            o_alu_op = R_TYPE_ALUCODE;
                            o_reg_dst = 2'b01;
                            o_mem_rd = 1'b0;                //MEM
                            o_mem_wr = 1'b0;
                            o_branch = 1'b0;
                            o_mem_to_reg = 2'b01;           //WB
                        end
                        SRL_FUNCTIONCODE:
                        begin
                            o_pc_src = 2'b00;               //IF
                            o_reg_wr = 1'b1;                //ID
                            o_alu_src = 2'b00;              //EX
                            o_alu_op = R_TYPE_ALUCODE;
                            o_reg_dst = 2'b01;
                            o_mem_rd = 1'b0;                //MEM
                            o_mem_wr = 1'b0;
                            o_branch = 1'b0;
                            o_mem_to_reg = 2'b01;           //WB
                        end
                        SRA_FUNCTIONCODE:
                        begin
                            o_pc_src = 2'b00;               //IF
                            o_reg_wr = 1'b1;                //ID
                            o_alu_src = 2'b00;              //EX
                            o_alu_op = R_TYPE_ALUCODE;
                            o_reg_dst = 2'b01;
                            o_mem_rd = 1'b0;                //MEM
                            o_mem_wr = 1'b0;
                            o_branch = 1'b0;
                            o_mem_to_reg = 2'b01;           //WB
                        end
                        SRLV_FUNCTIONCODE:
                        begin
                            o_pc_src = 2'b00;               //IF
                            o_reg_wr = 1'b1;                //ID
                            o_alu_src = 2'b00;              //EX
                            o_alu_op = R_TYPE_ALUCODE;
                            o_reg_dst = 2'b01;
                            o_mem_rd = 1'b0;                //MEM
                            o_mem_wr = 1'b0;
                            o_branch = 1'b0;
                            o_mem_to_reg = 2'b01;           //WB
                        end
                        SRAV_FUNCTIONCODE:
                        begin
                            o_pc_src = 2'b00;               //IF
                            o_reg_wr = 1'b1;                //ID
                            o_alu_src = 2'b00;              //EX
                            o_alu_op = R_TYPE_ALUCODE;
                            o_reg_dst = 2'b01;
                            o_mem_rd = 1'b0;                //MEM
                            o_mem_wr = 1'b0;
                            o_branch = 1'b0;
                            o_mem_to_reg = 2'b01;           //WB
                        end
                        ADD_FUNCTIONCODE:
                        begin
                            o_pc_src = 2'b00;               //IF
                            o_reg_wr = 1'b1;                //ID
                            o_alu_src = 2'b00;              //EX
                            o_alu_op = R_TYPE_ALUCODE;
                            o_reg_dst = 2'b01;
                            o_mem_rd = 1'b0;                //MEM
                            o_mem_wr = 1'b0;
                            o_branch = 1'b0;
                            o_mem_to_reg = 2'b01;           //WB
                        end
                        SLLV_FUNCTIONCODE:
                        begin
                            o_pc_src = 2'b00;               //IF
                            o_reg_wr = 1'b1;                //ID
                            o_alu_src = 2'b00;              //EX
                            o_alu_op = R_TYPE_ALUCODE;
                            o_reg_dst = 2'b01;
                            o_mem_rd = 1'b0;                //MEM
                            o_mem_wr = 1'b0;
                            o_branch = 1'b0;
                            o_mem_to_reg = 2'b01;           //WB
                        end
                        SUB_FUNCTIONCODE:
                        begin
                            o_pc_src = 2'b00;               //IF
                            o_reg_wr = 1'b1;                //ID
                            o_alu_src = 2'b00;              //EX
                            o_alu_op = R_TYPE_ALUCODE;
                            o_reg_dst = 2'b01;
                            o_mem_rd = 1'b0;                //MEM
                            o_mem_wr = 1'b0;
                            o_branch = 1'b0;
                            o_mem_to_reg = 2'b01;           //WB
                        end
                        AND_FUNCTIONCODE:
                        begin
                            o_pc_src = 2'b00;               //IF
                            o_reg_wr = 1'b1;                //ID
                            o_alu_src = 2'b00;              //EX
                            o_alu_op = R_TYPE_ALUCODE;
                            o_reg_dst = 2'b01;
                            o_mem_rd = 1'b0;                //MEM
                            o_mem_wr = 1'b0;
                            o_branch = 1'b0;
                            o_mem_to_reg = 2'b01;           //WB
                        end
                        OR_FUNCTIONCODE:
                        begin
                            o_pc_src = 2'b00;               //IF
                            o_reg_wr = 1'b1;                //ID
                            o_alu_src = 2'b00;              //EX
                            o_alu_op = R_TYPE_ALUCODE;
                            o_reg_dst = 2'b01;
                            o_mem_rd = 1'b0;                //MEM
                            o_mem_wr = 1'b0;
                            o_branch = 1'b0;
                            o_mem_to_reg = 2'b01;           //WB
                        end
                        XOR_FUNCTIONCODE:
                        begin
                            o_pc_src = 2'b00;               //IF
                            o_reg_wr = 1'b1;                //ID
                            o_alu_src = 2'b00;              //EX
                            o_alu_op = R_TYPE_ALUCODE;
                            o_reg_dst = 2'b01;
                            o_mem_rd = 1'b0;                //MEM
                            o_mem_wr = 1'b0;
                            o_branch = 1'b0;
                            o_mem_to_reg = 2'b01;           //WB
                        end
                        NOR_FUNCTIONCODE:
                        begin
                            o_pc_src = 2'b00;               //IF
                            o_reg_wr = 1'b1;                //ID
                            o_alu_src = 2'b00;              //EX
                            o_alu_op = R_TYPE_ALUCODE;
                            o_reg_dst = 2'b01;
                            o_mem_rd = 1'b0;                //MEM
                            o_mem_wr = 1'b0;
                            o_branch = 1'b0;
                            o_mem_to_reg = 2'b01;           //WB
                        end
                        SLT_FUNCTIONCODE:
                        begin
                            o_pc_src = 2'b00;               //IF
                            o_reg_wr = 1'b1;                //ID
                            o_alu_src = 2'b00;              //EX
                            o_alu_op = R_TYPE_ALUCODE;
                            o_reg_dst = 2'b01;
                            o_mem_rd = 1'b0;                //MEM
                            o_mem_wr = 1'b0;
                            o_branch = 1'b0;
                            o_mem_to_reg = 2'b01;           //WB
                        end
                        JALR_FUNCTIONCODE:
                        begin
                            o_pc_src = 2'b11;               //IF
                            o_reg_wr = 1'b1;                //ID
                            //o_alu_src = 2'b00;              //EX
                            //o_alu_op = R_TYPE_ALUCODE;
                            o_reg_dst = 2'b01;
                            o_mem_rd = 1'b0;                //MEM
                            o_mem_wr = 1'b0;
                            o_branch = 1'b0;
                            o_mem_to_reg = 2'b10;           //WB
                        end
                        JR_FUNCTIONCODE:
                        begin
                            o_pc_src = 2'b11;               //IF
                            o_reg_wr = 1'b0;                //ID
                            //o_alu_src = 2'b00;              //EX
                            //o_alu_op = R_TYPE_ALUCODE;
                            //o_reg_dst = 2'b01;
                            o_mem_rd = 1'b0;                //MEM
                            o_mem_wr = 1'b0;
                            o_branch = 1'b0;
                            //o_mem_to_reg = 2'b10;           //WB
                        end
                    endcase
                end
                
                //Immediate-type instructions
                LB_OPCODE:
                begin
                    o_pc_src = 2'b00;               //IF
                    o_reg_wr = 1'b1;                //ID
                    o_alu_src = 2'b10;              //EX
                    o_alu_op = LOAD_STORE_ADDI_ALUCODE;
                    o_reg_dst = 2'b00;
                    o_mem_rd = 1'b1;                //MEM
                    o_mem_wr = 1'b0;
                    o_branch = 1'b0;
                    o_mem_to_reg = 2'b00;           //WB
                end
                LH_OPCODE:
                begin
                    o_pc_src = 2'b00;               //IF
                    o_reg_wr = 1'b1;                //ID
                    o_alu_src = 2'b10;              //EX
                    o_alu_op = LOAD_STORE_ADDI_ALUCODE;
                    o_reg_dst = 2'b00;
                    o_mem_rd = 1'b1;                //MEM
                    o_mem_wr = 1'b0;
                    o_branch = 1'b0;
                    o_mem_to_reg = 2'b00;           //WB
                end
                LW_OPCODE:
                begin
                    o_pc_src = 2'b00;               //IF
                    o_reg_wr = 1'b1;                //ID
                    o_alu_src = 2'b10;              //EX
                    o_alu_op = LOAD_STORE_ADDI_ALUCODE;
                    o_reg_dst = 2'b00;
                    o_mem_rd = 1'b1;                //MEM
                    o_mem_wr = 1'b0;
                    o_branch = 1'b0;
                    o_mem_to_reg = 2'b00;           //WB
                end
                LWU_OPCODE:
                begin
                    o_pc_src = 2'b00;               //IF
                    o_reg_wr = 1'b1;                //ID
                    o_alu_src = 2'b10;              //EX
                    o_alu_op = LOAD_STORE_ADDI_ALUCODE;
                    o_reg_dst = 2'b00;
                    o_mem_rd = 1'b1;                //MEM
                    o_mem_wr = 1'b0;
                    o_branch = 1'b0;
                    o_mem_to_reg = 2'b00;           //WB
                end
                LBU_OPCODE:
                begin
                    o_pc_src = 2'b00;               //IF
                    o_reg_wr = 1'b1;                //ID
                    o_alu_src = 2'b10;              //EX
                    o_alu_op = LOAD_STORE_ADDI_ALUCODE;
                    o_reg_dst = 2'b00;
                    o_mem_rd = 1'b1;                //MEM
                    o_mem_wr = 1'b0;
                    o_branch = 1'b0;
                    o_mem_to_reg = 2'b00;           //WB
                end
                LHU_OPCODE:
                begin
                    o_pc_src = 2'b00;               //IF
                    o_reg_wr = 1'b1;                //ID
                    o_alu_src = 2'b10;              //EX
                    o_alu_op = LOAD_STORE_ADDI_ALUCODE;
                    o_reg_dst = 2'b00;
                    o_mem_rd = 1'b1;                //MEM
                    o_mem_wr = 1'b0;
                    o_branch = 1'b0;
                    o_mem_to_reg = 2'b00;           //WB
                end
                SB_OPCODE:
                begin
                    o_pc_src = 2'b00;               //IF
                    o_reg_wr = 1'b0;                //ID
                    o_alu_src = 2'b10;              //EX
                    o_alu_op = LOAD_STORE_ADDI_ALUCODE;
                    //o_reg_dst = 2'b00;
                    o_mem_rd = 1'b0;                //MEM
                    o_mem_wr = 1'b1;
                    o_branch = 1'b0;
                    //o_mem_to_reg = 2'b01;           //WB
                end
                SH_OPCODE:
                begin
                    o_pc_src = 2'b00;               //IF
                    o_reg_wr = 1'b0;                //ID
                    o_alu_src = 2'b10;              //EX
                    o_alu_op = LOAD_STORE_ADDI_ALUCODE;
                    //o_reg_dst = 2'b00;
                    o_mem_rd = 1'b0;                //MEM
                    o_mem_wr = 1'b1;
                    o_branch = 1'b0;
                    //o_mem_to_reg = 2'b01;           //WB
                end
                SW_OPCODE:
                begin
                    o_pc_src = 2'b00;               //IF
                    o_reg_wr = 1'b0;                //ID
                    o_alu_src = 2'b10;              //EX
                    o_alu_op = LOAD_STORE_ADDI_ALUCODE;
                    //o_reg_dst = 2'b00;
                    o_mem_rd = 1'b0;                //MEM
                    o_mem_wr = 1'b1;
                    o_branch = 1'b0;
                    //o_mem_to_reg = 2'b01;           //WB
                end
                ADDI_OPCODE:
                begin
                    o_pc_src = 2'b00;               //IF
                    o_reg_wr = 1'b1;                //ID
                    o_alu_src = 2'b10;              //EX
                    o_alu_op = LOAD_STORE_ADDI_ALUCODE;
                    o_reg_dst = 2'b00;
                    o_mem_rd = 1'b0;                //MEM
                    o_mem_wr = 1'b0;
                    o_branch = 1'b0;
                    o_mem_to_reg = 2'b01;           //WB
                end
                ANDI_OPCODE:
                begin
                    o_pc_src = 2'b00;               //IF
                    o_reg_wr = 1'b1;                //ID
                    o_alu_src = 2'b10;              //EX
                    o_alu_op = ANDI_ALUCODE;
                    o_reg_dst = 2'b00;
                    o_mem_rd = 1'b0;                //MEM
                    o_mem_wr = 1'b0;
                    o_branch = 1'b0;
                    o_mem_to_reg = 2'b01;           //WB
                end
                ORI_OPCODE:
                begin
                    o_pc_src = 2'b00;               //IF
                    o_reg_wr = 1'b1;                //ID
                    o_alu_src = 2'b10;              //EX
                    o_alu_op = ORI_ALUCODE;
                    o_reg_dst = 2'b00;
                    o_mem_rd = 1'b0;                //MEM
                    o_mem_wr = 1'b0;
                    o_branch = 1'b0;
                    o_mem_to_reg = 2'b01;           //WB
                end
                XORI_OPCODE:
                begin
                    o_pc_src = 2'b00;               //IF
                    o_reg_wr = 1'b1;                //ID
                    o_alu_src = 2'b10;              //EX
                    o_alu_op = XORI_ALUCODE;
                    o_reg_dst = 2'b00;
                    o_mem_rd = 1'b0;                //MEM
                    o_mem_wr = 1'b0;
                    o_branch = 1'b0;
                    o_mem_to_reg = 2'b01;           //WB
                end
                LUI_OPCODE:
                begin
                    o_pc_src = 2'b00;               //IF
                    o_reg_wr = 1'b1;                //ID
                    o_alu_src = 2'b10;              //EX
                    o_alu_op = LUI_ALUCODE;
                    o_reg_dst = 2'b00;
                    o_mem_rd = 1'b0;                //MEM
                    o_mem_wr = 1'b0;
                    o_branch = 1'b0;
                    o_mem_to_reg = 2'b01;           //WB
                end
                SLTI_OPCODE:
                begin
                    o_pc_src = 2'b00;               //IF
                    o_reg_wr = 1'b1;                //ID
                    o_alu_src = 2'b10;              //EX
                    o_alu_op = SLTI_ALUCODE;
                    o_reg_dst = 2'b00;
                    o_mem_rd = 1'b0;                //MEM
                    o_mem_wr = 1'b0;
                    o_branch = 1'b0;
                    o_mem_to_reg = 2'b01;           //WB
                end
                BEQ_OPCODE:
                begin
                    //o_pc_src = 2'b00;               //IF
                    o_reg_wr = 1'b0;                //ID
                    o_alu_src = 2'b00;              //EX
                    o_alu_op = BEQ_ALUCODE;
                    //o_reg_dst = 2'b00;
                    o_mem_rd = 1'b0;                //MEM
                    o_mem_wr = 1'b0;
                    o_branch = 1'b1;
                    //o_mem_to_reg = 2'b01;           //WB
                end
                BNE_OPCODE:
                begin
                    //o_pc_src = 2'b00;               //IF
                    o_reg_wr = 1'b0;                //ID
                    o_alu_src = 2'b00;              //EX
                    o_alu_op = BNE_ALUCODE;
                    //o_reg_dst = 2'b00;
                    o_mem_rd = 1'b0;                //MEM
                    o_mem_wr = 1'b0;
                    o_branch = 1'b1;
                    //o_mem_to_reg = 2'b01;           //WB
                end
                J_OPCODE:
                begin
                    o_pc_src = 2'b10;               //IF
                    o_reg_wr = 1'b0;                //ID
                    //o_alu_src = 2'b11;              //EX
                    //o_alu_op = BRANCH_ALUCODE;
                    //o_reg_dst = 2'b00;
                    o_mem_rd = 1'b0;                //MEM
                    o_mem_wr = 1'b0;
                    o_branch = 1'b0;
                    //o_mem_to_reg = 2'b01;           //WB
                end
                JAL_OPCODE:
                begin
                    o_pc_src = 2'b10;               //IF
                    o_reg_wr = 1'b1;                //ID
                    //o_alu_src = 2'b11;              //EX
                    //o_alu_op = BEQ_ALUCODE;
                    o_reg_dst = 2'b10;
                    o_mem_rd = 1'b0;                //MEM
                    o_mem_wr = 1'b0;
                    o_branch = 1'b0;
                    o_mem_to_reg = 2'b10;           //WB
                end
                default:
                begin
                    o_pc_src = 2'b00;               //IF
                    o_reg_wr = 1'b0;                //ID
                    o_alu_src = 2'b00;              //EX
                    o_alu_op = 'b0;
                    o_reg_dst = 2'b00;
                    o_mem_rd = 1'b0;                //MEM
                    o_mem_wr = 1'b0;
                    o_branch = 1'b0;
                    o_mem_to_reg = 2'b00;           //WB
                end
            endcase
        end
        else
        begin
            o_pc_src = 2'b00;               //IF
            o_reg_wr = 1'b0;                //ID
            o_alu_src = 2'b00;              //EX
            o_alu_op = 'b0;
            o_reg_dst = 2'b00;
            o_mem_rd = 1'b0;                //MEM
            o_mem_wr = 1'b0;
            o_branch = 1'b0;
            o_mem_to_reg = 2'b00;           //WB
        end
    end  
    
endmodule
