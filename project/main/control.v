//Commands other modules
module control(
    //Output(s)
    RegWrite,   // Whether or not we Write to RegFile/RegMem
    // Iformat,    // OBSElETE ? : Choose I-format 1 or I-format 2
    PcSel,      // Choose next instruction, or Jmp/Br Addr
    MemRead,    // Whether or not DataMem can be read
    MemWrite,   // Whether or not DataMem can be written to
    ALUcntrl,   // Controls operations of ALU (Add, sub, addi, subi, rol, etc)
    Val2Reg,    // Choose which value we are sending to RegMem (either ALU out or DataMem out)
    ImmExt,     // AKA ALUSel possibly. Controls whether or not to use Immediate as ALU input.
    ImmSel,     // Choose which extension to perform on which immediate size. AKA zero_ext (2 bits).
                // (default/00: Zero-ext any size, 01: 5-bit signed, 10: 8-bit signed, 11: 10-bit signed).
    I2JSel,     // Selects # of bits to pass to extender. (0: 8bits, 1: 11bits). Works in combo with ImmSel[1].
    Halt,       // Stop current and future instructions from executing
    LinkReg,    // Choose which Register to write to in RegMem (2 bits) (Rs, Rd-I, R7, Rd-R)
    //Input(s)
    Instr,      // 5 msb of instruction

);
    output wire RegWrite, Iformat, PcSel, MemRead, MemWrite, Val2Reg, ImmExt,ImmSel, Halt, LinkReg;
    output wire [1:0] LinkReg;
    output wire[4:0] ALUcntrl;
    input wire[4:0] Instr;


    always @* begin
        case(Instr[4:0])
            5'b00000: begin // HALT
                assign RegWrite = ;
                assign PcSel = ;
                assign MemRead = ;
                assign MemWrite = ;
                assign Val2Reg = ;
                assign ImmExt = ;
                assign ImmSel = ;
                assign Halt = ;
                assign LinkReg[1:0] = ;
                assign ALUcntrl[4:0] = ;

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
                assign RegWrite = 1'b1;         // Do write to RegMem
                assign PcSel = 1'b0;            // Don't branch or jump
                assign MemRead = 1'b0;          // Don't read from memory
                assign MemWrite = 1'b0;         // Don't write to memory
                assign Val2Reg = 1'b0;          // Transmit ALU output 
                assign ImmExt = 1'b1;           // Use the Immediate value in ALU
                assign Halt = 1'b0;             // Not halting
                assign LinkReg[1:0] = 2'b01;    // Rd I-format 1
                assign ALUcntrl[4:0] = Instr[4:0];
                case(Instr[1])
                    1'b0: assign ImmSel[1:0] = 2'b01; // use sign extension (specific to I-format 1!!)   
                    1'b1: assign ImmSel[1:0] = 2'b00;
                    default: ImmSel[1:0] = 2'b00;
                end
            5'b1000?: begin 
                // Common for all I-format 1 Memory Ops
                assign PcSel = 1'b0;            // Don't branch or jump
                assign Val2Reg = 1'b1;  // 1'bX // Transmit ALU output
                assign ImmExt = 1'b1;           // Use the Immediate value in ALU
                assign Halt = 1'b0;             // Not halting
                assign LinkReg[1:0] = 2'b01;    // Rd I-format 1
                assign ALUcntrl[4:0] = 5'b01000;// Act like performing ADDI
                assign ImmSel[1:0] = 2'b01;
                case(Instr[0])
                    1'b0: begin // ST Rd, Rs, immediate Mem[Rs + I(sign ext.)] <- Rd
                        assign RegWrite = 1'b0;
                        assign MemWrite = 1'b1;
                        assign MemRead = 1'b0;
                    end
                    1'b1: begin // LD Rd, Rs, immediate Rd <- Mem[Rs + I(sign ext.)]
                        assign RegWrite = 1'b1;
                        assign MemWrite = 1'b0;
                        assign MemRead = 1'b1;
                    end
            end   
            5'b10011: begin // STU Rd, Rs, immediate Mem[Rs + I(sign ext.)] <- Rd
                                                 //  Rs <- Rs + I(sign ext.)
                assign PcSel = 1'b0;             // Don't branch or jump
                assign Val2Reg = 1'b0;  // 1'bX // Transmit ALU output
                assign ImmExt = 1'b1;           // Use the Immediate value in ALU
                assign Halt = 1'b0;             // Not halting
                assign LinkReg[1:0] = 2'b01;    // Rd I-format 1
                assign ALUcntrl[4:0] = 5'b01000;// Act like performing ADDI
                assign ImmSel[1:0] = 2'b01; 
                assign RegWrite = 1'b1;
                assign MemWrite = 1'b1;
                assign MemRead = 1'b0;
            end
//========================================================//

//===================== R Format =========================//
            5'b11001: begin // BTR
                //;
            end
            5'b11011: begin // ADD
                //;
            end
            5'b11011: begin // SUB
                //;
            end
            5'b11011: begin // XOR
                //;
            end
            5'b11011: begin // ANDN
                //;
            end
            5'b11010: begin // SLL
                //;
            end
            5'b11010: begin // SRL
                //;
            end
            5'b11010: begin // ROL
                //;
            end
            5'b11010: begin // ROR
                //;
            end
            5'b11100: begin // SEQ
                //;
            end
            5'b11101: begin // SLT
                //;
            end
            5'b11110: begin // SLE
                //;
            end
            5'b11111: begin // SCO
                //;
            end
//========================================================//

//===================== I Format 2 =======================//
            5'b01100: begin // BEQZ
                //;
            end
            5'b01101: begin // BNEZ
                //;
            end
            5'b01110: begin // BLTZ
                //;
            end
            5'b01111: begin // BGEZ
                //;
            end
            5'b11000: begin // LBI
                //;
            end
            5'b10010: begin // SLBI
                //;
            end
//---------------------- J Format ------------------------//
            5'b00100: begin // J
                //;
            end
            5'b00110: begin // JAL
                //;
            end
//--------------------------------------------------------//

            5'b00101: begin // JR
                //;
            end
            5'b00111: begin // JALR
                //;
            end
//========================================================//
    end

endmodule