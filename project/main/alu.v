//Arithmetic module
module alu(out, opcode, Ain, Bin);
    parameter OPERAND_WIDTH = 16;

    output wire[15:0] out;
    input wire[15:0] A, B;
    input wire[4:0]opcode;
    input wire[1:0]funct;

    wire[15:0] inv;
    always @* begin 
        case(opcode[4:2])
            3'b000: begin //NOP
                out = 0; 
            end
            3'b001: begin //Jump
                case(opcode[1:0])
                    2'00: begin //PC+DISP (J)

                     end
                    2'01: begin //R + Imm (JR)
                    end 
                    2'10: begin //JAL
                    end
                    2'11: begin //JALR
                    end
                endcase
            end
            3'b010: begin //Arithmetic Immediate
                case(opcode[1:0])
                    2'00: begin //ADDI
                        cla16b ImmSum(.sum(out), .cOut(), .inA(Ain), inB.(Bin), .cIn());
                    end
                    2'01: begin //SUBI
                        TwosComp sub(.out(inv), .in(B));
                        cla16b ImmSub(.sum(out), .cOut(), .inA(Ain), inB.(inv), .cIn());
                    end
                    2'10: begin //XORI
                        out = A^B;
                    end
                    2'11: begin //NANDI
                        out = ~(A&B);
                    end
                endcase
            end
            3'b011: begin //Branch
                case(opcode[1:0])
                    2'00: begin //BEQZ
                    end
                    2'01: begin //BNEZ
                    end
                    2'10: begin //BLTZ
                    end
                    2'11: begin //BGTZ
                    end
                endcase
            end
            3'b100: begin //Memory Access
                case(opcode[1:0])
                    2'00: begin end
                    2'01: begin end
                    2'10: begin end
                    2'11: begin end
                endcase
            end
            3'b101: begin //Shift Immediate
                case(opcode[1:0])
                    2'00: begin //SLL
                        s0 = B[0] ? {A[OPERAND_WIDTH - 2 : 0], 1'h0} : A;       //Shift 1 
                        s1 = B[1] ? {s0[OPERAND_WIDTH - 3 : 0], 2'h0} : s0;     //Shift 2  
                        s2 = B[2] ? {s1[OPERAND_WIDTH - 5 : 0], 4'h0} : s1;     //Shift 4  
                        Out = B[3] ? {s2[OPERAND_WIDTH - 9 : 0], 8'h0} : s2;    //Shift 8
                    end
                    2'01: begin //SRL
                        s0 = B[0] ? {1'b0, A[OPERAND_WIDTH - 1 : 1]} : A;       //Shift 1
                        s1 = B[1] ? {2'h0, s0[OPERAND_WIDTH - 1 : 2]} : s0;     //Shift 2
                        s2 = B[2] ? {4'h0, s1[OPERAND_WIDTH - 1 : 4]} : s1;     //Shift 4
                        Out = B[3] ? {8'h0, s2[OPERAND_WIDTH - 1 : 8]} : s2;    //Shift 8
                    end
                    2'10: begin //ROL
                        s0 = B[0] ? {A[OPERAND_WIDTH - 2 : 0], A[OPERAND_WIDTH - 1]} : A;                           //Shift 1
                        s1 = B[1] ? {s0[OPERAND_WIDTH - 3 : 0], s0[OPERAND_WIDTH - 1: OPERAND_WIDTH - 2]} : s0;     //Shift 2
                        s2 = B[2] ? {s1[OPERAND_WIDTH - 5 : 0], s1[OPERAND_WIDTH - 1: OPERAND_WIDTH - 4]} : s1;     //Shift 4
                        Out = B[3] ? {s2[OPERAND_WIDTH - 9 : 0], s2[OPERAND_WIDTH - 1: OPERAND_WIDTH - 8]} : s2;    //Shift 8
                    end
                    2'11: begin //ROR
                        s0 = B[0] ? { A[0], A[OPERAND_WIDTH - 1 : 1]} : A;                          //Shift 1
                        s1 = B[1] ? { s0[OPERAND_WIDTH - 1:0], s0[OPERAND_WIDTH - 1 : 2]} : s0;     //Shift 2
                        s2 = B[2] ? { s1[OPERAND_WIDTH - 3: 0], s1[OPERAND_WIDTH - 1 : 4]} : s1;    //Shift 4
                       Out = B[3] ? { s2[OPERAND_WIDTH - 7: 0], s2[OPERAND_WIDTH - 1 : 8]} : s2;    //Shift 8
                    end
                endcase
            end
            3'b110: begin //Arithmetic/Shift Reg
                case(opcode[1:0])
                    2'b11: begin // Register Arithmetic
                        case(funct)
                            2'00: begin //ADD
                                cla16b RegSum(.sum(out), .cOut(), .inA(Ain), inB.(inv), .cIn());
                            end
                            2'01: begin //SUB
                                TwosComp sub(.out(inv), .in(B));
                                cla16b RegSub(.sum(out), .cOut(), .inA(Ain), inB.(inv), .cIn());
                            end
                            2'10: begin //XOR
                                out = A^B;
                            end
                            2'11: begin //NAND
                                out = ~(A&B);
                            end
                        endcase
                    end

                    2'b10: begin //Register Shift
                        case(funct)
                            2'00: begin //SLL
                                s0 = B[0] ? {A[OPERAND_WIDTH - 2 : 0], 1'h0} : A;       //Shift 1 
                                s1 = B[1] ? {s0[OPERAND_WIDTH - 3 : 0], 2'h0} : s0;     //Shift 2  
                                s2 = B[2] ? {s1[OPERAND_WIDTH - 5 : 0], 4'h0} : s1;     //Shift 4  
                                Out = B[3] ? {s2[OPERAND_WIDTH - 9 : 0], 8'h0} : s2;    //Shift 8
                            end
                            2'01: begin //SRL
                                s0 = B[0] ? {1'b0, A[OPERAND_WIDTH - 1 : 1]} : A;       //Shift 1
                                s1 = B[1] ? {2'h0, s0[OPERAND_WIDTH - 1 : 2]} : s0;     //Shift 2
                                s2 = B[2] ? {4'h0, s1[OPERAND_WIDTH - 1 : 4]} : s1;     //Shift 4
                                Out = B[3] ? {8'h0, s2[OPERAND_WIDTH - 1 : 8]} : s2;    //Shift 8
                            end
                            2'10: begin //ROL
                                s0 = B[0] ? {A[OPERAND_WIDTH - 2 : 0], A[OPERAND_WIDTH - 1]} : A;                           //Shift 1
                                s1 = B[1] ? {s0[OPERAND_WIDTH - 3 : 0], s0[OPERAND_WIDTH - 1: OPERAND_WIDTH - 2]} : s0;     //Shift 2
                                s2 = B[2] ? {s1[OPERAND_WIDTH - 5 : 0], s1[OPERAND_WIDTH - 1: OPERAND_WIDTH - 4]} : s1;     //Shift 4
                                Out = B[3] ? {s2[OPERAND_WIDTH - 9 : 0], s2[OPERAND_WIDTH - 1: OPERAND_WIDTH - 8]} : s2;    //Shift 8
                            end
                            2'11: begin //ROR
                                s0 = B[0] ? { A[0], A[OPERAND_WIDTH - 1 : 1]} : A;                          //Shift 1
                                s1 = B[1] ? { s0[OPERAND_WIDTH - 1:0], s0[OPERAND_WIDTH - 1 : 2]} : s0;     //Shift 2
                                s2 = B[2] ? { s1[OPERAND_WIDTH - 3: 0], s1[OPERAND_WIDTH - 1 : 4]} : s1;    //Shift 4
                            Out = B[3] ? { s2[OPERAND_WIDTH - 7: 0], s2[OPERAND_WIDTH - 1 : 8]} : s2;    //Shift 8
                            end
                        endcase
                    end
                endcase
            end
            3'b111: begin //Conditional
                case(opcode[1:0])
                    2'00: begin //SEQ
                    end
                    2'01: begin //SLT 
                    end
                    2'10: begin //SLE
                    end
                    2'11: begin //SCO
                    end
                endcase
            end
        endcase
    end
endmodule



