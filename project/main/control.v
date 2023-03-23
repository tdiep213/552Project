//Commands other modules
module control(
    //Output(s)
    RegWrite,   // Whether or not we Write to RegFile/RegMem
    Iformat,    // Choose Rd Tru: I-format 1, False: R-format 
    PcSel,      // Choose next instruction, or Jmp/Br Addr
    Pc2Reg,     // True: Write calculated PC value to RegMem, False: Write output of ALU/DataMem to RegMem
    MemEnable,  // Whether or not DataMem can be read           //MOTE! Looks like the provided memory module used "enable" and "wr" 
    MemWr,      // Whether or not DataMem can be written to     // instead of MemEnable/MemWr
    ALUcntrl,   // Controls operations of ALU (Add, sub, addi, subi, rol, etc)
    Val2Reg,    // Choose which value we are sending to RegMem (either ALU out or DataMem out)
    ALUSel,     // AKA ALUSel possibly. Controls whether or not to use Immediate as ALU input.
    ImmSel,     // Choose which extension to perform on which immediate size. (sign?, ImmSize[1:0]) (00: 5, 01: 8, 10: 11)
    Halt,       // Stop current and future instructions from executing
    LinkReg,    // LinkReg[1] = Link, LinkReg[0] = LBI Choose which Register to write to in RegMem (00: Rd, 01: Rs, 10: R7, 11: XX) // TODO Remap!
    //Input(s)
    Instr,      // 5 msb of instruction

);
    output wire RegWrite, Iformat, PcSel, Pc2Reg, MemEnable, MemWr, Val2Reg, ALUSel, Halt, LinkReg;
    output wire [1:0] LinkReg; // TODO
    output wire [2:0] ImmSel;
    output wire[4:0] ALUcntrl;
    input wire[4:0] Instr;
    input wire Zflag, Sflag;
/*  assign RegWrite = ;
    assign PcSel = ;
    assign Pc2Reg = ;
    assign MemEnable = ;
    assign MemWr = ;
    assign Val2Reg = ;
    assign ALUSel = ;
    assign ImmSel[2:0] = ;
    assign Iformat = ;
    assign Halt = ;
    assign LinkReg[1:0] = ; // TODO
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
                assign MemEnable     = 1'b0;        // Do Not read from memory
                assign MemWr         = 1'b0;        // Do Not write to memory
                assign Val2Reg       = 1'b0;        // Do transmit ALU output 
                assign ALUSel        = 1'b1;        // Do use the Immediate value in ALU
                assign Halt          = 1'b0;        // Do Not halt
                assign LinkReg[1:0]  = 2'b00;       // Do use Rd
                assign Iformat       = 1'b1;        // Do use Rd-I
                assign ALUcntrl[4:0] = Instr[4:0];  // Do pass opcode to ALU
                case(Instr[1])
                    1'b0: assign ImmSel[2:0] = 3'b100;   // Do use sign extension (specific to I-format 1!!)
                    1'b1: assign ImmSel[2:0] = 3'b000;   // Do use zero extension
                    default: ImmSel[2:0]     = 3'b000;   // Do default to 5 bit zero-extension // TODO
                end
            5'b1000?: begin 
                // Common for all I-format 1 Memory Ops
                assign PcSel         = 1'b0;        // Do Not branch or jump
                assign Pc2Reg        = 1'b0;        // Do Not write PC to RegMem
                assign ALUSel        = 1'b1;        // Do use the Immediate value in ALU
                assign Halt          = 1'b0;        // Do Not
                assign LinkReg[1:0]  = 2'b00;       // Do use Rd I-format 1 for write reg
                assign Iformat       = 1'b1;        // Do use Rd-I
                assign ALUcntrl[4:0] = 5'b01000;    // Do act like performing ADDI
                assign ImmSel[2:0]   = 3'b101;      // Do sign extend 5 bits
                case(Instr[0])
                    1'b0: begin // ST Rd, Rs, immediate Mem[Rs + I(sign ext.)] <- Rd
                        assign Val2Reg = 1'b1;          // Do transmit ALU output
                        assign RegWrite = 1'b0;         // Do Not write to register
                        assign MemWr = 1'b1;            // Do write to memory
                        assign MemEnable = 1'b1;        // Do enable mem access
                    end
                    1'b1: begin // LD Rd, Rs, immediate Rd <- Mem[Rs + I(sign ext.)]
                        assign Val2Reg = 1'b0;          // Do Not transmit ALU output
                        assign RegWrite = 1'b1;         // Do write to register
                        assign MemWr = 1'b0;            // Do Not write to memory
                        assign MemEnable = 1'b1;        // Do enable mem access
                    end
            end   
            5'b10011: begin // STU Rd, Rs, immediate Mem[Rs + I(sign ext.)] <- Rd and //  Rs <- Rs + I(sign ext.)
                assign PcSel         = 1'b0;    // Do Not branch or jump
                assign Pc2Reg = 1'b0;           // Do Not write PC to RegMem
                assign Val2Reg       = 1'b0;    // Do transmit ALU output // 1'bX 
                assign ALUSel        = 1'b1;    // Do use the Immediate value in ALU
                assign Halt          = 1'b0;    // Do Not halt
                assign LinkReg[1:0]  = 2'b00;   // Do Rd I-format 1
                assign Iformat       = 1'b1;    // Do use Rd-I
                assign ALUcntrl[4:0] = 5'b01000;// Do act like performing ADDI
                assign ImmSel[3:0]   = 3'b101;  // Do sign extend 5 bits.
                assign RegWrite      = 1'b1;    // Do write to register
                assign MemWr         = 1'b1;    // Do write to memory
                assign MemEnable     = 1'b1;    // Do enable mem access
            end
//========================================================//

//===================== R Format =========================//
            // BTR, ADD, SUB, XOR, ANDN, SLL, SRL, ROL, ROR, SEQ, SLT, SLE, SCO
            5'b11001, 5'b1101?, 5'b111??: begin     // Excludes 5'b11000 (LBI)
                assign PcSel         = 1'b0;        // Do Not branch or jump
                assign Pc2Reg        = 1'b0;        // Do Not write PC to RegMem
                assign Val2Reg       = 1'b0;        // Do transmit ALU output // 1'bX 
                assign ALUSel        = 1'b0;        // Do Not use the Immediate value in ALU
                assign Halt          = 1'b0;        // Do Not halt
                assign LinkReg[1:0]  = 2'b00;       // Do use Rd R-format
                assign Iformat       = 1'b0;        // Do Not use Rd-I
                assign ALUcntrl[4:0] = Instr[4:0];  // Pass Thru?
                assign ImmSel[3:0]   = 3'b000;      // zero extend 5 bits. // Don't Cares 3'bXXX
                assign RegWrite      = 1'b1;        // Do write to register
                assign MemWr         = 1'b0;        // Do Not write to memory
                assign MemEnable     = 1'b0;        // Do Not enable mem access
            end
//========================================================//

//===================== I Format 2 =======================//
            5'b011??: begin
                assign Pc2Reg        = 1'b0;        // Don't write PC to RegMem
                assign Val2Reg       = 1'b0;        // Don't Care // Do transmit ALU output // 1'bX 
                assign ALUSel        = 1'b0;        // Don't Care // Do Not use the Immediate value in ALU
                assign Halt          = 1'b0;        // Do Not halt
                assign LinkReg[1:0]  = 2'b01;       // Don't Care // Do use Rs
                assign Iformat       = 1'b1;        // Don't Care // Don't Use Rd-I
                assign ALUcntrl[4:0] = Instr[4:0];  // Don't Care // Pass Thru?
                assign ImmSel[2:0]   = 3'b101;      // Do sign extend 8 bits.
                assign RegWrite      = 1'b0;        // Do Not write to register
                assign MemWr         = 1'b0;        // Do Not write to memory
                assign MemEnable     = 1'b0;        // Do Not enable mem access
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
                assign ALUSel        = 1'b1;        // Sometimes Care // Do Not use the Immediate value in ALU
                assign Halt          = 1'b0;        // Do Not halt
                assign LinkReg[1:0]  = 2'b10;       // Sometimes Care // Do use R7 //
                assign Iformat       = 1'b1;        // Don't Care // Do use Rd-I
                assign ALUcntrl[4:0] = 5'b01000;    // Pass ADDI Opcode
                assign MemWr         = 1'b0;        // Do Not write to memory
                case(Instr[0])
//---------------------- J Format ------------------------//
                    1'b0:  begin 
                        assign ImmSel[2:0]   = 3'b110;         // Do sign extend 11 bits.
                        case(Instr[1]) // J-format
                            1'b0: begin // J displacement PC <- PC + 2 + D(sign ext.)
                                assign Pc2Reg   = 1'b0;        // Do Not write PC to RegMem
                                assign RegWrite = 1'b0;        // Do Not write to register
                                assign MemEnable= 1'b0;        // Do Not enable mem acces
                            end
                            1'b1: begin // JAL displacement R7 <- PC + 2 and PC <- PC + 2 + D(sign ext.)
                                assign Pc2Reg   = 1'b1;        // Do write PC to RegMem
                                assign RegWrite = 1'b1;        // Do write to register
                                assign MemEnable= 1'b1;        // Do enable mem access
                            end  
                    end
//--------------------------------------------------------//
                    1'b1: begin
                        assign ImmSel[2:0]   = 3'b101;         // Do sign extend 8 bits.
                        case(Instr[1])
                            1'b0: begin // JR Rs, immediate PC <- Rs + I(sign ext.)
                                assign Pc2Reg   = 1'b0;        // Do Not write PC to RegMem
                                assign RegWrite = 1'b0;        // Do Not write to register
                                assign MemEnable= 1'b0;        // Do enable mem access
                            end
                            1'b1: begin // JALR Rs, immediate R7 <- PC + 2 and PC <- Rs + I(sign ext.)
                                assign Pc2Reg   = 1'b1;        // Do write PC to RegMem
                                assign RegWrite = 1'b1;        // Do write to register
                                assign MemEnable= 1'b1;        // Do enable mem access
                            end 
                    end    
            end    
//========================================================//
    end

endmodule