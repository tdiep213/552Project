//Arithmetic module
module alu(out, opcode, funct, Ain, Bin);
    parameter OPERAND_WIDTH = 16;

    output reg[15:0] out;
    input wire[15:0] Ain, Bin;
    input wire[4:0]opcode;  // passed from control
    input wire[1:0]funct;   // passed from main

    wire[15:0] inv;
    reg[15:0] s0, s1, s2;
    wire ltcomp;
    
    wire zero;      // Is this zero flag? Please set as output, and add a sign flag too please!
    assign zero = 0;

    /* Arithmetic logic */
    wire[15:0] sum, diff;
    cla16b RegSum(.sum(sum), .cOut(), .inA(Ain), .inB(Bin), .cIn(zero));

    TwosComp sub(.out(inv), .in(Ain));
    cla16b RegSub(.sum(diff), .cOut(), .inA(Bin), .inB(inv), .cIn(zero));


    /* Conditional logic */
    wire[15:0] slt16, sle16, sCoSum;
    lt16b lt(.out(slt16), .Ain(Ain), .Bin(Bin));

    lt16b le(.out(ltcomp), .Ain(Ain), .Bin(Bin));
    assign sle16 = ltcomp | (&(Ain==Bin));    

    cla16b COSum(.sum(), .cOut(sCoSum), .inA(Ain), .inB(Bin), .cIn(zero));

// NOTE! Some of these are control signal operations, 
// so their implementation will be moved to control.v
// ALU ops will stay here and control will pass along opcode.
    always @* begin 
        case(opcode[4:2])
            3'b000: begin //NOP
                out = 0; 
            end
            3'b001: begin //Jump NOT USED
                case(opcode[1:0])
                    2'b00: begin //PC+DISP (J)
                     end
                    2'b01: begin //R + Imm (JR)
                    end 
                    2'b10: begin //JAL
                    end
                    2'b11: begin //JALR
                    end
                endcase
            end
            3'b010: begin //Arithmetic Immediate
                case(opcode[1:0])
                    2'b00: begin //ADDI
                        out = sum; 
                    end
                    2'b01: begin //SUBI
                        out = diff;
                    end
                    2'b10: begin //XORI
                        out = Ain^Bin;
                    end
                    2'b11: begin //NANDI
                        out = Ain&~(Bin);
                    end
                endcase
            end
            3'b011: begin //Branch NOT USED
                case(opcode[1:0])
                    2'b00: begin //BEQZ
                    end
                    2'b01: begin //BNEZ
                    end
                    2'b10: begin //BLTZ
                    end
                    2'b11: begin //BGTZ
                    end
                endcase
            end
            3'b100: begin //Memory Access 
                case(opcode[1:0])
                    2'b00: begin end
                    2'b01: begin end
                    2'b10: begin end
                    2'b11: begin end
                endcase
            end
            3'b101: begin //Shift Immediate
                case(opcode[1:0])
                    2'b01: begin //SLL
                        s0 = Bin[0] ? {Ain[OPERAND_WIDTH - 2 : 0], 1'h0} : Ain;   //Shift 1 
                        s1 = Bin[1] ? {s0[OPERAND_WIDTH - 3 : 0], 2'h0} : s0;     //Shift 2  
                        s2 = Bin[2] ? {s1[OPERAND_WIDTH - 5 : 0], 4'h0} : s1;     //Shift 4  
                        out = Bin[3] ? {s2[OPERAND_WIDTH - 9 : 0], 8'h0} : s2;    //Shift 8
                    end
                    2'b11: begin //SRL
                        s0 = Bin[0] ? {1'b0, Ain[OPERAND_WIDTH - 1 : 1]} : Ain;   //Shift 1
                        s1 = Bin[1] ? {2'h0, s0[OPERAND_WIDTH - 1 : 2]} : s0;     //Shift 2
                        s2 = Bin[2] ? {4'h0, s1[OPERAND_WIDTH - 1 : 4]} : s1;     //Shift 4
                        out = Bin[3] ? {8'h0, s2[OPERAND_WIDTH - 1 : 8]} : s2;    //Shift 8
                    end
                    2'b00: begin //ROL
                        s0 = Bin[0] ? {Ain[OPERAND_WIDTH - 2 : 0], Ain[OPERAND_WIDTH - 1]} : Ain;                     //Shift 1
                        s1 = Bin[1] ? {s0[OPERAND_WIDTH - 3 : 0], s0[OPERAND_WIDTH - 1: OPERAND_WIDTH - 2]} : s0;     //Shift 2
                        s2 = Bin[2] ? {s1[OPERAND_WIDTH - 5 : 0], s1[OPERAND_WIDTH - 1: OPERAND_WIDTH - 4]} : s1;     //Shift 4
                        out = Bin[3] ? {s2[OPERAND_WIDTH - 9 : 0], s2[OPERAND_WIDTH - 1: OPERAND_WIDTH - 8]} : s2;    //Shift 8
                    end
                    2'b10: begin //ROR
                        s0 = Bin[0] ? { Ain[0], Ain[OPERAND_WIDTH - 1 : 1]} : Ain;                    //Shift 1
                        s1 = Bin[1] ? { s0[OPERAND_WIDTH - 1:0], s0[OPERAND_WIDTH - 1 : 2]} : s0;     //Shift 2
                        s2 = Bin[2] ? { s1[OPERAND_WIDTH - 3: 0], s1[OPERAND_WIDTH - 1 : 4]} : s1;    //Shift 4
                       out = Bin[3] ? { s2[OPERAND_WIDTH - 7: 0], s2[OPERAND_WIDTH - 1 : 8]} : s2;    //Shift 8
                    end
                endcase
            end
            // NOTE! Please insert BTR operation :)
            3'b110: begin //Arithmetic/Shift Reg
                case(opcode[1:0])
                    2'b11: begin // Register Arithmetic
                        case(funct)
                            2'b00: begin //ADD
                                out = sum;
                            end
                            2'b01: begin //SUB
                                out = diff; 
                            end
                            2'b10: begin //XOR
                                out = Ain^Bin;
                            end
                            2'b11: begin //NAND
                                out = Ain&~(Bin);
                            end
                        endcase
                    end

                    2'b10: begin //Register Shift
                        case(funct)
                            2'b00: begin //SLL
                                s0 = Bin[0] ? {Ain[OPERAND_WIDTH - 2 : 0], 1'h0} : Ain;       //Shift 1 
                                s1 = Bin[1] ? {s0[OPERAND_WIDTH - 3 : 0], 2'h0} : s0;     //Shift 2  
                                s2 = Bin[2] ? {s1[OPERAND_WIDTH - 5 : 0], 4'h0} : s1;     //Shift 4  
                                out = Bin[3] ? {s2[OPERAND_WIDTH - 9 : 0], 8'h0} : s2;    //Shift 8
                            end
                            2'b01: begin //SRL
                                s0 = Bin[0] ? {1'b0, Ain[OPERAND_WIDTH - 1 : 1]} : Ain;       //Shift 1
                                s1 = Bin[1] ? {2'h0, s0[OPERAND_WIDTH - 1 : 2]} : s0;     //Shift 2
                                s2 = Bin[2] ? {4'h0, s1[OPERAND_WIDTH - 1 : 4]} : s1;     //Shift 4
                                out = Bin[3] ? {8'h0, s2[OPERAND_WIDTH - 1 : 8]} : s2;    //Shift 8
                            end
                            2'b10: begin //ROL
                                s0 = Bin[0] ? {Ain[OPERAND_WIDTH - 2 : 0], Ain[OPERAND_WIDTH - 1]} : Ain;                           //Shift 1
                                s1 = Bin[1] ? {s0[OPERAND_WIDTH - 3 : 0], s0[OPERAND_WIDTH - 1: OPERAND_WIDTH - 2]} : s0;     //Shift 2
                                s2 = Bin[2] ? {s1[OPERAND_WIDTH - 5 : 0], s1[OPERAND_WIDTH - 1: OPERAND_WIDTH - 4]} : s1;     //Shift 4
                                out = Bin[3] ? {s2[OPERAND_WIDTH - 9 : 0], s2[OPERAND_WIDTH - 1: OPERAND_WIDTH - 8]} : s2;    //Shift 8
                            end
                            2'b11: begin //ROR
                                s0 = Bin[0] ? { Ain[0], Ain[OPERAND_WIDTH - 1 : 1]} : Ain;                          //Shift 1
                                s1 = Bin[1] ? { s0[OPERAND_WIDTH - 1:0], s0[OPERAND_WIDTH - 1 : 2]} : s0;     //Shift 2
                                s2 = Bin[2] ? { s1[OPERAND_WIDTH - 3: 0], s1[OPERAND_WIDTH - 1 : 4]} : s1;    //Shift 4
                                out = Bin[3] ? { s2[OPERAND_WIDTH - 7: 0], s2[OPERAND_WIDTH - 1 : 8]} : s2;    //Shift 8
                            end
                        endcase
                    end
                endcase
            end
            3'b111: begin //Conditional
                case(opcode[1:0])
                    2'b00: begin //SEQ A == B
                        out = &(Ain==Bin);
                    end

                    2'b01: begin //SLT 
                        out = slt16;
                    end
                    2'b10: begin //SLE
                        out = sle16;
                    end
                    2'b11: begin //SCO
                        out = sCoSum;
                    end
                endcase
            end
        endcase
    end



endmodule



