//Commands other modules
module control(
    //Output(s)
    RegWrite,   // Whether or not we Write to RegFile/RegMem
    DestRegSel, // Choose WriteRegister 00: Rs, 01: Rd-R, 10: R7, 11: Rd-I
    PcSel,      // Choose False: PC incr, or True: PC incr + Imm
    RegJmp,     // Choose False: above, or True: Rs + sign_ext(Imm)
    MemEnable,  // Whether or not DataMem can be read           //MOTE! Looks like the provided memory module used "enable" and "wr" 
    MemWr,      // Whether or not DataMem can be written to     // instead of MemEnable/MemWr
    ALUcntrl,   // Controls operations of ALU (Add, sub, addi, subi, rol, etc)
    Val2Reg,    // Choose which value we are sending to RegMem (either ALU out or DataMem out)
    ALUSel,     // AKA ALUSel possibly. Controls whether or not to use Immediate as ALU input.
    ImmSel,     // Choose which extension to perform on which immediate size. (sign?, ImmSize[1:0]) (00: 5, 01: 8, 10: 11)
    Halt,       // Stop current and future instructions from executing
    Link,       // Jump and Link instructions
    LBI,        // Load byte immediate instructions
    ctrlErr,    // temporary err flag for phase 1.
    SIIC,       // SIIC
    b_flag,     // whomst? :P
    valid_n,    // whomst? :P
    j_flag,
    //Input(s)
    Instr     // 5 msb of instruction
);
    output reg  Halt, ctrlErr, SIIC, valid_n,   // special control
                RegWrite, Val2Reg, Link, LBI,   // Register control
                PcSel, RegJmp, b_flag, j_flag,  // PC control
                MemEnable, MemWr,               // Memory Control
                ALUSel;                         // ALU control (obselete?)
    output reg [1:0] DestRegSel; // TODO
    output reg [2:0] ImmSel;
    output reg[4:0] ALUcntrl;
    input wire[4:0] Instr;

    always @* begin
        casex(Instr[4:0])
        default: begin
            PcSel           = 1'b0;    // Do Not add Imm to PC + 2
            RegJmp          = 1'b0;    // Do Not Jmp from Rs
            Val2Reg         = 1'b0;    // Do transmit ALU output // 1'bX 
            ALUSel          = 1'b0;    // Do Not use the Immediate value in ALU
            Link            = 1'b0;    // Do Not LBI
            LBI             = 1'b0;    // Do Not Link, 
            DestRegSel[1:0] = 2'b00;   // Do use Rs
            ImmSel[2:0]     = 3'b000;  // Do zero extend 5 bits.
            RegWrite        = 1'b0;    // Do Not write to register
            MemWr           = 1'b0;    // Do Not write to memory
            MemEnable       = 1'b0;    // Do Not enable mem access
            SIIC            = 1'b0;    // Do Not SIIC
            b_flag          = 1'b0;    // Do set branch flag
            valid_n         = 1'b0;    // Do set valid NOP
            Halt            = 1'b0;    // Do Not Halt
            ALUcntrl        = Instr;   // Do pass instr through
            ctrlErr         = 1'b0;    // Do Not set error bit
        end
//=================== Special Ops B) =====================//
            5'b000??: begin // These base values do not make permanent changes to the proc state.
                  ALUSel            = 1'b1;    // Do use the Immediate value in ALU
                  DestRegSel[1:0]   = 2'b11;   // Do use Rd-I
                  ImmSel[2:0]       = 3'b100;  // Do sign extend 5 bits.
                case(Instr[1:0])
                    2'b00: begin
                        Halt = 1'b1; // Do Halt PC from executing new instructions
                    end
                    2'b01: begin    // NOP
                    end
                    2'b10: begin    // siic // Currently NOP/Okay if it breaks
                        SIIC = 1'b1;
                    end
                    2'b11: begin    // RTI // Currently NOP
                        ALUcntrl = 5'b00001; // Do pass on NOP opcode
                    end
                    default: ctrlErr = 1'b1;
                endcase
            end
//========================================================//

//===================== I Format 1 =======================//

            5'b010??, 5'b101??: begin   // All I-format 1, non-memory instructions
                RegWrite        = 1'b1;     // Do write to RegMem
                ALUSel          = 1'b1;     // Do use the Immediate value in ALU
                DestRegSel[1:0] = 2'b11;    // Do use Rd-I
                valid_n         = 1'b1;
                case(Instr[1])
                    1'b0: ImmSel[2:0]   = 3'b100;   // Do use sign extension (specific to I-format 1!!)
                    default: ctrlErr    = 1'b1;
                endcase
            end
            5'b1000?: begin 
                // Common for all I-format 1 Memory Ops
                ALUSel          = 1'b1;     // Do use the Immediate value in ALU
                DestRegSel[1:0] = 2'b11;    // Do use Rd-I
                ImmSel[2:0]     = 3'b100;   // Do sign extend 5 bits
                valid_n         = 1'b1;
                MemEnable       = 1'b1;     // Do enable mem access
                case(Instr[0])
                    1'b0: begin // ST Rd, Rs, immediate Mem[Rs + I(sign ext.)] <- Rd
                        MemWr       = 1'b1;     // Do write to memory
                    end
                    1'b1: begin // LD Rd, Rs, immediate Rd <- Mem[Rs + I(sign ext.)]
                        Val2Reg     = 1'b1;     // Do Not transmit ALU output
                        RegWrite    = 1'b1;     // Do write to register 
                    end
                    default:   ctrlErr = 1'b1;
                endcase
            end   
            5'b10011: begin // STU Rd, Rs, immediate Mem[Rs + I(sign ext.)] <- Rd and //  Rs <- Rs + I(sign ext.)
                ALUSel          = 1'b1;     // Do use the Immediate value in ALU
                ImmSel[2:0]     = 3'b100;   // Do sign extend 5 bits.
                RegWrite        = 1'b1;     // Do write to register
                MemWr           = 1'b1;     // Do write to memory
                MemEnable       = 1'b1;     // Do enable mem access
                valid_n         = 1'b1;
            end
//========================================================//

//===================== R Format =========================//
            // BTR, ADD, SUB, XOR, ANDN, SLL, SRL, ROL, ROR, SEQ, SLT, SLE, SCO
            5'b11001, 5'b1101?, 5'b111??: begin     // Excludes 5'b11000 (LBI)
                DestRegSel[1:0] = 2'b01;    // Do use Rd-R
                RegWrite        = 1'b1;     // Do write to register;
                valid_n         = 1'b1;
            end
//========================================================//

//===================== I Format 2 =======================//
            5'b011??: begin
                ImmSel[2:0] = 3'b101;      // Do sign extend 8 bits.
                valid_n     = 1'b1;
            end
            5'b11000, 5'b10010: begin   // LBI and SLBI
                ALUSel      = 1'b1;     // Do use the Immediate value in ALU
                RegWrite    = 1'b1;     // Do write to register
                valid_n     = 1'b1;
                case(Instr[4:0])
                    5'b11000: begin             // LBI Rs, immediate Rs <- I(sign ext.)
                        ImmSel[2:0] = 3'b101;   // Do sign extend 8 bits   
                        LBI         = 1'b1;     // Do LBI, 
                    end
                    5'b10010: begin             // SLBI Rs, immediate Rs <- (Rs << 8) | I(zero ext.)
                        ImmSel[2:0] = 3'b001;   // Do zero extend 8 bits.
                    end
                    default: ctrlErr = 1'b1;
                endcase
            end
            5'b001??: begin 
                ALUSel          = 1'b1;     // Sometimes Care // Do use the Immediate value in ALU
                DestRegSel[1:0] = 2'b10;    // Do use R7

                case(Instr[0])
//---------------------- J Format ------------------------//
                    1'b0:  begin 
                        j_flag      = 1'b1;
                        ImmSel[2:0] = 3'b110;       // Do sign extend 11 bits.
                        case(Instr[1]) // J-format
                            1'b0: begin // J displacement PC <- PC + 2 + D(sign ext.)
                                b_flag      = 1'b1;     // Do add Imm to PC + 2
                            end
                            1'b1: begin // JAL displacement R7 <- PC + 2 and PC <- PC + 2 + D(sign ext.)
                                Link        = 1'b1;
                                b_flag      = 1'b1;     // Do add Imm to PC + 2
                                RegWrite    = 1'b1;     // Do write to register
                                valid_n     = 1'b1;
                            end
                            default: ctrlErr = 1'b1;  
                        endcase
                    end
//--------------------------------------------------------//
                    1'b1: begin
                        RegJmp      = 1'b1;     // Do Jmp from Rs
                        ImmSel[2:0] = 3'b101;   // Do sign extend 8 bits.
                        
                        case(Instr[1])
                            1'b0: begin // JR Rs, immediate PC <- Rs + I(sign ext.)
                                b_flag      = 1'b1;    // Do add Imm to PC + 2
                            end
                            1'b1: begin // JALR Rs, immediate R7 <- PC + 2 and PC <- Rs + I(sign ext.)
                                Link        = 1'b1;    // Do Link
                                RegWrite    = 1'b1;    // Do write to register
                                valid_n     = 1'b1;
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