//Commands other modules
module control(
    //Output(s)
    RegWrite,   // Whether or not we Write to RegFile/RegMem
     Iformat,     // OBSElETE ? : Choose I-format 1 or I-format 2 
    //^I'm gonna use this to pick between Instr[4:2] and Instr[7:5] for Rd in decode
    PcSel,      // Choose next instruction, or Jmp/Br Addr
    Pc2Reg,    // True: Write calculated PC value to RegMem, False: Write output of ALU/DataMem to RegMem
    MemRead,    // Whether or not DataMem can be read
    MemWrite,   // Whether or not DataMem can be written to
    ALUcntrl,   // Controls operations of ALU (Add, sub, addi, subi, rol, etc)
    Val2Reg,    // Choose which value we are sending to RegMem (either ALU out or DataMem out)
    ImmExt,     // AKA ALUSel possibly. Controls whether or not to use Immediate as ALU input.
    ImmSel,     // Choose which extension to perform on which immediate size. AKA zero_ext (2 bits).
                // (default/00: Zero-ext any size, 01: 5-bit signed, 10: 8-bit signed, 11: 10-bit signed).
    I2JSel,     // Selects # of bits to pass to extender. (0: 8bits, 1: 11bits). Works in combo with ImmSel[1].
    Halt,       // Stop current and future instructions from executing
    LinkReg,    // Choose which Register to write to in RegMem (2 bits) (00: Rs, 01: Rd-I, 10: R7, 11: Rd-R)
    //Input(s)
    Instr,      // 5 msb of instruction

);
    output wire RegWrite, Iformat, PcSel, Pc2Reg, MemRead, MemWrite, Val2Reg, ImmExt,ImmSel, I2JSel, Halt, LinkReg;
    output wire [1:0] LinkReg;
    output wire[4:0] ALUcntrl;
    input wire[4:0] Instr;
    input wire Zflag, Sflag;
/*  assign RegWrite = ;
    assign PcSel = ;
    assign Pc2Reg = ;
    assign MemRead = ;
    assign MemWrite = ;
    assign Val2Reg = ;
    assign ImmExt = ;
    assign ImmSel[1:0] = ;
    assign I2JSel = ;
    assign Halt = ;
    assign LinkReg[1:0] = ;
    assign ALUcntrl[4:0] = ;
*/

    always @* begin
        case(Instr[4:0])
            5'b00000: begin // HALT
                //;
            end
            5'b00001: begin // NOP
                //;
            end
            
            5'b00010: begin // siic
                //;
            end
            5'b00011: begin // NOP/RTI
                //;
            end
//===================== I Format 1 =======================//

            5'b010??, 5'b101??: begin   // All I-format 1, non-memory instructions
                assign RegWrite      = 1'b1;        // Do write to RegMem
                assign PcSel         = 1'b0;        // Do Not branch or jump
                assign Pc2Reg        = 1'b0;        // Do Not write PC to RegMem
                assign MemRead       = 1'b0;        // Do Not read from memory
                assign MemWrite      = 1'b0;        // Do Not write to memory
                assign Val2Reg       = 1'b0;        // Do transmit ALU output 
                assign ImmExt        = 1'b1;        // Do use the Immediate value in ALU
                assign Halt          = 1'b0;        // Do Not halt
                assign LinkReg[1:0]  = 2'b01;       // Do use Rd I-format 1
                assign ALUcntrl[4:0] = Instr[4:0];  // Do pass opcode to ALU
                assign I2JSel = 1'b0;               // Do pass 5 bits to sign extender
                case(Instr[1])
                    1'b0: assign ImmSel[1:0] = 2'b01;   // Do use sign extension (specific to I-format 1!!)   
                    1'b1: assign ImmSel[1:0] = 2'b00;   // Do use zero extension
                    default: ImmSel[1:0]     = 2'b00;       // Do default to zero-extension
                end
            5'b1000?: begin 
                // Common for all I-format 1 Memory Ops
                assign PcSel         = 1'b0;        // Do Not branch or jump
                assign Pc2Reg        = 1'b0;        // Do Not write PC to RegMem
                assign ImmExt        = 1'b1;        // Do use the Immediate value in ALU
                assign Halt          = 1'b0;        // Do Not
                assign LinkReg[1:0]  = 2'b01;       // Do use Rd I-format 1 for write reg
                assign ALUcntrl[4:0] = 5'b01000;    // Do act like performing ADDI
                assign ImmSel[1:0]   = 2'b01;       // Do sign extend 5 bits
                assign I2JSel        = 1'b0;        // Don't Care // Do pass 5 bits to extender
                case(Instr[0])
                    1'b0: begin // ST Rd, Rs, immediate Mem[Rs + I(sign ext.)] <- Rd
                        assign Val2Reg = 1'b1;          // Do transmit ALU output
                        assign RegWrite = 1'b0;         // Do Not write to register
                        assign MemWrite = 1'b1;         // Do write to memory
                        assign MemRead = 1'b0;          // Do Not read from memory
                    end
                    1'b1: begin // LD Rd, Rs, immediate Rd <- Mem[Rs + I(sign ext.)]
                        assign Val2Reg = 1'b0;          // Do Not transmit ALU output
                        assign RegWrite = 1'b1;         // Do write to register
                        assign MemWrite = 1'b0;         // Do Not write to memory
                        assign MemRead = 1'b1;          // Do read from memory
                    end
            end   
            5'b10011: begin // STU Rd, Rs, immediate Mem[Rs + I(sign ext.)] <- Rd and //  Rs <- Rs + I(sign ext.)
                assign PcSel         = 1'b0;    // Do Not branch or jump
                assign Pc2Reg = 1'b0;           // Do Not write PC to RegMem
                assign Val2Reg       = 1'b0;    // Do transmit ALU output // 1'bX 
                assign ImmExt        = 1'b1;    // Do use the Immediate value in ALU
                assign Halt          = 1'b0;    // Do Not halt
                assign LinkReg[1:0]  = 2'b01;   // Do Rd I-format 1
                assign ALUcntrl[4:0] = 5'b01000;// Do act like performing ADDI
                assign ImmSel[1:0]   = 2'b01;   // sign extend 5 bits.
                assign I2JSel        = 1'b0;    // Do pass 5 bits to extender.
                assign RegWrite      = 1'b1;    // Do write to register
                assign MemWrite      = 1'b1;    // Do write to memory
                assign MemRead       = 1'b0;    // Do Not read from memory
            end
//========================================================//

//===================== R Format =========================//
            // BTR, ADD, SUB, XOR, ANDN, SLL, SRL, ROL, ROR, SEQ, SLT, SLE, SCO
            5'b11001, 5'b1101?, 5'b111??: begin     // Excludes 5'b11000 (LBI)
                assign PcSel         = 1'b0;        // Do Not branch or jump
                assign Pc2Reg        = 1'b0;        // Do Not write PC to RegMem
                assign Val2Reg       = 1'b0;        // Do transmit ALU output // 1'bX 
                assign ImmExt        = 1'b0;        // Do Not use the Immediate value in ALU
                assign Halt          = 1'b0;        // Do Not halt
                assign LinkReg[1:0]  = 2'b11;       // Do use Rd R-format
                assign ALUcntrl[4:0] = Instr[4:0];  // Pass Thru?
                assign ImmSel[1:0]   = 2'b00;       // zero extend 5 bits. // Don't Cares 2'bXX
                assign I2JSel        = 1'b0;        // Do pass 5 bits to extender. // Don't Care 1'bX
                assign RegWrite      = 1'b1;        // Do write to register
                assign MemWrite      = 1'b0;        // Do Not write to memory
                assign MemRead       = 1'b0;        // Do Not read from memory
            end
//========================================================//

//===================== I Format 2 =======================//
            5'b011??: begin
                assign Pc2Reg        = 1'b0;        // Don't write PC to RegMem
                assign Val2Reg       = 1'b0;        // Don't Care // Do transmit ALU output // 1'bX 
                assign ImmExt        = 1'b0;        // Don't Care // Do Not use the Immediate value in ALU
                assign Halt          = 1'b0;        // Do Not halt
                assign LinkReg[1:0]  = 2'b00;       // Don't Care // Do use Rs
                assign ALUcntrl[4:0] = Instr[4:0];  // Don't Care // Pass Thru?
                assign ImmSel[1:0]   = 2'b10;       // Do sign extend 8 bits.
                assign I2JSel        = 1'b0;        // Do pass 8 bits to extender.
                assign RegWrite      = 1'b0;        // Do Not write to register
                assign MemWrite      = 1'b0;        // Do Not write to memory
                assign MemRead       = 1'b0;        // Do Not read
                case(Instr[1:0])
                    2'b00: assign PcSel = Zflag;    // BEQZ Rs, immediate if (Rs == 0) then PC <- PC + 2 + I(sign ext.)   
                    2'b01: assign PcSel = ~Zflag;   // BNEZ Rs, immediate if (Rs != 0) then PC <- PC + 2 + I(sign ext.)
                    2'b10: assign PcSel = Sflag;    // BLTZ Rs, immediate if (Rs < 0) then PC <- PC + 2 + I(sign ext.)
                    2'b11: assign PcSel = ~Sflag;   // BGEZ Rs, immediate if (Rs >= 0) then PC <- PC + 2 + I(sign ext.)
            end
            5'b11000: begin // LBI Rs, immediate Rs <- I(sign ext.)
                // TODO;
            end
            5'b10010: begin // SLBI Rs, immediate Rs <- (Rs << 8) | I(zero ext.)
                // TODO;
            end
            5'b001??: begin 
                assign PcSel         = 1'b1;        // Do branch or jump
                assign Val2Reg       = 1'b0;        // Sometimes Care // Do transmit ALU output
                assign ImmExt        = 1'b1;        // Sometimes Care // Do Not use the Immediate value in ALU
                assign Halt          = 1'b0;        // Do Not halt
                assign LinkReg[1:0]  = 2'b11;       // Sometimes Care // Do use R7
                assign ALUcntrl[4:0] = ADDi;        // Pass ADDI Cpcode
                assign MemWrite      = 1'b0;        // Do Not write to memory
                assign MemRead       = 1'b0;        // Do Not read from memory
                case(Instr[0])
//---------------------- J Format ------------------------//
                    1'b0:  begin 
                        assign ImmSel[1:0]   = 2'b11;       // Do sign extend 11 bits.
                        assign I2JSel        = 1'b1;        // Do pass 11 bits to extender.
                        case(Instr[1]) // J-format
                            1'b0: begin // J displacement PC <- PC + 2 + D(sign ext.)
                                assign Pc2Reg   = 1'b0;        // Do Not write PC to RegMem
                                assign RegWrite = 1'b0;        // Do Not write to register
                            end
                            1'b1: begin // JAL displacement R7 <- PC + 2 and PC <- PC + 2 + D(sign ext.)
                                assign Pc2Reg   = 1'b1;        // Do write PC to RegMem
                                assign RegWrite = 1'b1;        // Do write to register
                            end  
                    end
//--------------------------------------------------------//
                    1'b1: begin
                        assign ImmSel[1:0]   = 2'b10;       // Do sign extend 8 bits.
                        assign I2JSel        = 1'b0;        // Do pass 8 bits to extender.
                        case(Instr[1])
                            1'b0: begin // JR Rs, immediate PC <- Rs + I(sign ext.)
                                assign Pc2Reg   = 1'b0;        // Do Not write PC to RegMem
                                assign RegWrite = 1'b0;        // Do Not write to register
                            end
                            1'b1: begin // JALR Rs, immediate R7 <- PC + 2 and PC <- Rs + I(sign ext.)
                                assign Pc2Reg   = 1'b1;        // Do write PC to RegMem
                                assign RegWrite = 1'b1;        // Do write to register
                            end 
                    end    
            end    
//========================================================//
    end

endmodule