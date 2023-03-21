//Commands other modules
module control(
    //Output(s)
    RegWrite,   // Whether or not we Write to RegFile/RegMem
    Iformat,    // Choose I-format 1 or I-format 2
    PcSel,      // Choose next instruction, or Jmp/Br Addr
    MemRead,    // Whether or not DataMem can be read
    MemWrite,   // Whether or not DataMem can be written to
    ALUcntrl,   // Controls operations of ALU (Add, sub, addi, subi, rol, etc)
    Val2Reg,    // Choose which value we are sending to RegMem (either ALU out or DataMem out)
    ImmExt,     // ??
    ImmSel,     // Choose which extension to perform on which immediate size. AKA zero_ext (2 bits). 00 or default value is zero-ext for all sizes
    Halt,       // Stop current and future instructions from executing
    LinkReg,    // Choose which Register to write to in RegMem (2 bits) (Rs, Rd-I, R7, Rd-R)
    //Input(s)
    Instr,      // 5 msb of instruction
    OpCode      // 2 lsb of instruction
);
    output wire RegWrite, Iformat, PcSel, MemRead, MemWrite, Val2Reg, ImmExt,ImmSel, Halt, LinkReg;
    output wire [1:0] LinkReg;
    output wire[4:0] ALUcntrl;
    input wire[4:0] Instr;
    input wire[1:0] OpCode;

    always @* begin
        case(Instr[4:0])
            5'b00000: begin // HALT
                assign RegWrite = ;
                assign Iformat = ;
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
            5'b01000: begin // ADDI
                assign RegWrite = 1'b1;
                assign Iformat = ;
                assign PcSel = 1'b0;
                assign MemRead = 1'b0;
                assign MemWrite = 1'b0;
                assign Val2Reg = 1'b0;
                assign ImmExt = //TODO;
                assign ImmSel = 1;
                assign Halt = 1'b0;
                assign LinkReg[1:0] = ;
                assign ALUcntrl[4:0] = ;

            end
            5'b01001: begin // SUBI
                //;
            end
            5'b01010: begin // XORI
                //;
            end
            5'b01011: begin // ANDNI
                //;
            end
            5'b10100: begin // ROLI
                //;
            end
            5'b10101: begin // SLLI
                //;
            end
            5'b10110: begin // RORI
                //;
            end
            5'b10111: begin // SRLI
                //;
            end
            5'b10000: begin // ST
                //;
            end
            5'b10001: begin // LD
                //;
            end
            5'b10011: begin // STU
                //;
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