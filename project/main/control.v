//Commands other modules
module control(
    //Output(s)
    RegWrite,   // Whether or not we Write to RegFile/RegMem
    Iformat,    // Choose Rd Tru: I-format 1, False: R-format 
    PcSel,      // Choose False: PC incr, or True: PC incr + Imm
    RegJmp,     // Choose False: above, or True: Rs + sign_ext(Imm)
    Pc2Reg,     // True: Write calculated PC value to RegMem, False: Write output of ALU/DataMem to RegMem
    MemEnable,  // Whether or not DataMem can be read           //MOTE! Looks like the provided memory module used "enable" and "wr" 
    MemWr,      // Whether or not DataMem can be written to     // instead of MemEnable/MemWr
    ALUcntrl,   // Controls operations of ALU (Add, sub, addi, subi, rol, etc)
    Val2Reg,    // Choose which value we are sending to RegMem (either ALU out or DataMem out)
    ALUSel,     // AKA ALUSel possibly. Controls whether or not to use Immediate as ALU input.
    ImmSel,     // Choose which extension to perform on which immediate size. (sign?, ImmSize[1:0]) (00: 5, 01: 8, 10: 11)
    Halt,       // Stop current and future instructions from executing
    LinkReg,    // (Link, LBI) Choose which Register to write to in RegMem (00: Rd, 01: Rs, 10: R7, 11: XX) // TODO Remap!
    ctrlErr,    // temporary err flag for phase 1.
    //Input(s)
    Instr,      // 5 msb of instruction
    Zflag, 
    Sflag
);
    output reg RegWrite, Iformat, PcSel, RegJmp, Pc2Reg, MemEnable, MemWr, Val2Reg, ALUSel, Halt, ctrlErr;
    output reg [1:0] LinkReg; // TODO
    output reg [2:0] ImmSel;
    output reg[4:0] ALUcntrl;
    input wire[4:0] Instr;
    input wire Zflag, Sflag;

    always @* begin
        casez(Instr[4:0])
//=================== Special Ops B) =====================//
            5'b000??: begin // These base values do not make permanent changes to the proc state.
                  PcSel         = 1'b0;    // Do Not add Imm to PC + 2
                  RegJmp        = 1'b0;    // Do Not Jmp from Rs
                  Pc2Reg        = 1'b0;    // Do Not write PC to RegMem
                  Val2Reg       = 1'b0;    // Do transmit ALU output // 1'bX 
                  ALUSel        = 1'b1;    // Do use the Immediate value in ALU
                  LinkReg[1:0]  = 2'b00;   // Do Rd I-format 1
                  Iformat       = 1'b1;    // Do use Rd-I
                  ImmSel[2:0]   = 3'b100;  // Do sign extend 5 bits.
                  RegWrite      = 1'b0;    // Do write to register
                  MemWr         = 1'b0;    // Do write to memory
                  MemEnable     = 1'b0;    // Do enable mem access
                case(Instr[1:0])
                    2'b00: begin
                        Halt = 1'b1; // Do Halt PC from executing new instructions
                        ALUcntrl = ALUcntrl; // Do pass on Halt opcode
                    end
                    2'b01: begin    // NOP
                        Halt = 1'b0; // Do Not Halt PC from executing new instructions
                        ALUcntrl = ALUcntrl; // Do pass on NOP opcode
                    end
                    2'b10: begin    // siic // Currently NOP/Okay if it breaks
                        Halt = 1'b1; // Don't Care allowed to break // Do Halt
                        ALUcntrl = ALUcntrl; // Don't Care allowed to break // Do pass along opcode
                    end
                    2'b11: begin    // RTI // Currently NOP
                        Halt = 1'b0; // Do Not Halt PC from executing new instructions 
                        ALUcntrl = 5'b00001; // Do pass on NOP opcode
                    end
                    default: ctrlErr = 1'b1;
                endcase
            end
//========================================================//

//===================== I Format 1 =======================//

            5'b010??, 5'b101??: begin   // All I-format 1, non-memory instructions
                RegWrite      = 1'b1;        // Do write to RegMem
                PcSel         = 1'b0;        // Do Not add Imm to PC + 2
                RegJmp        = 1'b0;        // Do Not Jmp from Rs
                Pc2Reg        = 1'b0;        // Do Not write PC to RegMem
                MemEnable     = 1'b0;        // Do Not read from memory
                MemWr         = 1'b0;        // Do Not write to memory
                Val2Reg       = 1'b0;        // Do transmit ALU output 
                ALUSel        = 1'b1;        // Do use the Immediate value in ALU
                Halt          = 1'b0;        // Do Not halt
                LinkReg[1:0]  = 2'b00;       // Do use Rd
                Iformat       = 1'b1;        // Do use Rd-I
                ALUcntrl[4:0] = Instr[4:0];  // Do pass opcode to ALU
                case(Instr[1])
                    1'b0: ImmSel[2:0] = 3'b100;   // Do use sign extension (specific to I-format 1!!)
                    1'b1: ImmSel[2:0] = 3'b000;   // Do use zero extension
                    default: ctrlErr = 1'b1;
                endcase
            end
            5'b1000?: begin 
                // Common for all I-format 1 Memory Ops
                PcSel         = 1'b0;        // Do Not add Imm to PC + 2
                RegJmp        = 1'b0;        // Do Not Jmp from Rs
                Pc2Reg        = 1'b0;        // Do Not write PC to RegMem
                ALUSel        = 1'b1;        // Do use the Immediate value in ALU
                Halt          = 1'b0;        // Do Not
                LinkReg[1:0]  = 2'b00;       // Do use Rd I-format 1 for write reg
                Iformat       = 1'b1;        // Do use Rd-I
                ALUcntrl[4:0] = 5'b01000;    // Do act like performing ADDI
                ImmSel[2:0]   = 3'b100;      // Do sign extend 5 bits
                case(Instr[0])
                    1'b0: begin // ST Rd, Rs, immediate Mem[Rs + I(sign ext.)] <- Rd
                        Val2Reg = 1'b1;          // Do transmit ALU output
                        RegWrite = 1'b0;         // Do Not write to register
                        MemWr = 1'b1;            // Do write to memory
                        MemEnable = 1'b1;        // Do enable mem access
                    end
                    1'b1: begin // LD Rd, Rs, immediate Rd <- Mem[Rs + I(sign ext.)]
                        Val2Reg   = 1'b0;    // Do Not transmit ALU output
                        RegWrite  = 1'b1;    // Do write to register
                        MemWr     = 1'b0;    // Do Not write to memory
                        MemEnable = 1'b1;    // Do enable mem access
                    end
                    default:   ctrlErr = 1'b1;
                endcase
            end   
            5'b10011: begin // STU Rd, Rs, immediate Mem[Rs + I(sign ext.)] <- Rd and //  Rs <- Rs + I(sign ext.)
                PcSel         = 1'b0;    // Do Not add Imm to PC + 2
                RegJmp        = 1'b0;    // Do Not Jmp from Rs
                Pc2Reg        = 1'b0;    // Do Not write PC to RegMem
                Val2Reg       = 1'b0;    // Do transmit ALU output // 1'bX 
                ALUSel        = 1'b1;    // Do use the Immediate value in ALU
                Halt          = 1'b0;    // Do Not halt
                LinkReg[1:0]  = 2'b00;   // Do Rd I-format 1
                Iformat       = 1'b1;    // Do use Rd-I
                ALUcntrl[4:0] = 5'b01000;// Do act like performing ADDI
                ImmSel[2:0]   = 3'b100;  // Do sign extend 5 bits.
                RegWrite      = 1'b1;    // Do write to register
                MemWr         = 1'b1;    // Do write to memory
                MemEnable     = 1'b1;    // Do enable mem access
            end
//========================================================//

//===================== R Format =========================//
            // BTR, ADD, SUB, XOR, ANDN, SLL, SRL, ROL, ROR, SEQ, SLT, SLE, SCO
            5'b11001, 5'b1101?, 5'b111??: begin     // Excludes 5'b11000 (LBI)
                PcSel         = 1'b0;        // Do Not add Imm to PC + 2
                RegJmp        = 1'b0;        // Do Not Jmp from Rs
                Pc2Reg        = 1'b0;        // Do Not write PC to RegMem
                Val2Reg       = 1'b0;        // Do transmit ALU output // 1'bX 
                ALUSel        = 1'b0;        // Do Not use the Immediate value in ALU
                Halt          = 1'b0;        // Do Not halt
                LinkReg[1:0]  = 2'b00;       // Do use Rd R-format
                Iformat       = 1'b0;        // Do Not use Rd-I
                ALUcntrl[4:0] = Instr[4:0];  // Pass Thru?
                ImmSel[2:0]   = 3'b000;      // zero extend 5 bits. // Don't Cares 3'bXXX
                RegWrite      = 1'b1;        // Do write to register
                MemWr         = 1'b0;        // Do Not write to memory
                MemEnable     = 1'b0;        // Do Not enable mem access
            end
//========================================================//

//===================== I Format 2 =======================//
            5'b011??: begin
                RegJmp        = 1'b0;        // Do Not Jmp from Rs
                Pc2Reg        = 1'b0;        // Don't write PC to RegMem
                Val2Reg       = 1'b0;        // Don't Care // Do transmit ALU output // 1'bX 
                ALUSel        = 1'b0;        // Don't Care // Do Not use the Immediate value in ALU
                Halt          = 1'b0;        // Do Not halt
                LinkReg[1:0]  = 2'b01;       // Don't Care // Do use Rs
                Iformat       = 1'b1;        // Don't Care // Don't Use Rd-I
                ALUcntrl[4:0] = Instr[4:0];  // Don't Care // Pass Thru?
                ImmSel[2:0]   = 3'b101;      // Do sign extend 8 bits.
                RegWrite      = 1'b0;        // Do Not write to register
                MemWr         = 1'b0;        // Do Not write to memory
                MemEnable     = 1'b0;        // Do Not enable mem access
                case(Instr[1:0])
                    2'b00: PcSel = Zflag;    // BEQZ Rs, immediate if (Rs == 0) then PC <- PC + 2 + I(sign ext.)   
                    2'b01: PcSel = ~Zflag;   // BNEZ Rs, immediate if (Rs != 0) then PC <- PC + 2 + I(sign ext.)
                    2'b10: PcSel = Sflag;    // BLTZ Rs, immediate if (Rs < 0) then PC <- PC + 2 + I(sign ext.)
                    2'b11: PcSel = ~Sflag;   // BGEZ Rs, immediate if (Rs >= 0) then PC <- PC + 2 + I(sign ext.)
                    default: ctrlErr = 1'b1;
                endcase
            end
            5'b11000, 5'b10010: begin // LBI and SLBI
                PcSel         = 1'b0;    // Do Not add Imm to PC + 2
                RegJmp        = 1'b0;    // Do Not Jmp from Rs
                Pc2Reg        = 1'b0;    // Do Not write PC to RegMem
                Val2Reg       = 1'b0;    // Do transmit ALU output // 1'bX 
                ALUSel        = 1'b1;    // Do use the Immediate value in ALU
                Halt          = 1'b0;    // Do Not halt
                LinkReg[1:0]  = 2'b01;   // Do use Rs
                Iformat       = 1'b1;    // Don't Care // Do use Rd-I
                ALUcntrl[4:0] = 5'b11000;// Do pass LBI instr to ALU
                RegWrite      = 1'b1;    // Do write to register
                MemWr         = 1'b0;    // Do Not write to memory
                MemEnable     = 1'b0;    // Do Not enable mem access
                case(Instr[4:0])
                    5'b11000: ImmSel[2:0] = 3'b101; // Do sign extend 8 bits   // LBI Rs, immediate Rs <- I(sign ext.)
                    5'b10010: ImmSel[2:0] = 3'b001;  // Do zero extend 8 bits. // SLBI Rs, immediate Rs <- (Rs << 8) | I(zero ext.)
                    default: ctrlErr = 1'b1;
                endcase
            end
            5'b001??: begin 
                PcSel         = 1'b1;        // Do add Imm to PC + 2
                Val2Reg       = 1'b0;        // Sometimes Care // Do transmit ALU output
                ALUSel        = 1'b1;        // Sometimes Care // Do Not use the Immediate value in ALU
                Halt          = 1'b0;        // Do Not halt
                LinkReg[1:0]  = 2'b10;       // Sometimes Care // Do use R7 //
                Iformat       = 1'b1;        // Don't Care // Do use Rd-I
                ALUcntrl[4:0] = 5'b01000;    // Pass ADDI Opcode
                MemWr         = 1'b0;        // Do Not write to memory
                case(Instr[0])
//---------------------- J Format ------------------------//
                    1'b0:  begin 
                        RegJmp        = 1'b0;           // Do Not Jmp from Rs
                        ImmSel[2:0]   = 3'b110;         // Do sign extend 11 bits.
                        case(Instr[1]) // J-format
                            1'b0: begin // J displacement PC <- PC + 2 + D(sign ext.)
                                Pc2Reg   = 1'b0;        // Do Not write PC + 2 to RegMem
                                RegWrite = 1'b0;        // Do Not write to register
                                MemEnable= 1'b0;        // Do Not enable mem acces
                            end
                            1'b1: begin // JAL displacement R7 <- PC + 2 and PC <- PC + 2 + D(sign ext.)
                                Pc2Reg   = 1'b1;        // Do write PC + 2 to RegMem
                                RegWrite = 1'b1;        // Do write to register
                                MemEnable= 1'b1;        // Do enable mem access
                            end
                            default: ctrlErr = 1'b1;  
                        endcase
                    end
//--------------------------------------------------------//
                    1'b1: begin
                        RegJmp        = 1'b1;           // Do Jmp from Rs
                        ImmSel[2:0]   = 3'b101;         // Do sign extend 8 bits.
                        case(Instr[1])
                            1'b0: begin // JR Rs, immediate PC <- Rs + I(sign ext.)
                                Pc2Reg   = 1'b0;        // Do Not write PC + 2 to RegMem
                                RegWrite = 1'b0;        // Do Not write to register
                                MemEnable= 1'b0;        // Do enable mem access
                            end
                            1'b1: begin // JALR Rs, immediate R7 <- PC + 2 and PC <- Rs + I(sign ext.)
                                Pc2Reg   = 1'b1;        // Do write PC + 2 to RegMem
                                RegWrite = 1'b1;        // Do write to register
                                MemEnable= 1'b1;        // Do enable mem access
                            end
                            default: ctrlErr = 1'b1; 
                        endcase
                    end
                    default: ctrlErr = 1'b1;   
                endcase 
            end
            default: ctrlErr = 1'b1;
        endcase 
//========================================================//
    end

endmodule