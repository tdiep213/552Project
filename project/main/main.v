//Connects various computation and storage blocks
module main();
    wire/*TODO*/ ReadAddr;
    wire[15:0] Instruction;
    wire/*TODO*/ ReadData;
    wire[15:0] Reg1Data, Reg2Data;
//===== control signal wires =====//
    // definitions in control.v
    wire PcSel, Pc2Reg, RegWrite, 
         MemRead, MemWrite, ImmExt, 
         I2JSel, Halt, Val2Reg;
    wire [1:0] ImmSel, LinkReg;
    wire [5:0] ALUcntrl;
//================================//

//============== PC ==============//
   wire[15:0] PcAddr;

    pc(.PcAddr(PcAddr),.Imm(Imm),.Rs(Rs),.PcSel(PcSel),.RegJmp(RegJmp),.Halt(Halt));

//------------ PC Out ------------//

//================================//



//========== InstrMem ============//
   
    InstrMem(.Instr(Instruction),.ReadAddr(ReadAddr));

//-------- InstrMem Out ----------//

//================================//



//=========== RegMem =============//
    
    // Additional Input Logic
    wire [15:0] WriteDataIn, OperOutput;
    wire [2:0] WriteRegAddr, R7;
    assign R7 = 3'b111;

    mux2_1 WriteDataMux    [15:0] (.out(WriteDataIn[15:0]), .inputA(PcAddr[15:0]), .inputB(OperOutput[15:0]), .sel(WriteDataSel));
    assign WriteRegAddr = Imm ? Instruction[7:5] : Instruction[4:2]; // Unsure if necessary, see RegMem.

    RegMem(.Reg1Data(Reg1Data), .Reg2Data(Reg2Data), .Reg1Addr(Instruction[10:8]), .Reg2Addr(Instruction[7:5]),
           .WriteRegAddr(WriteRegAddr[2:0]), .WriteData(WriteDataIn[15:0]), .RegWrite(RegWrite));

//--------- RegMem Out -----------//

    //  Unoptimized old impl.
    //mux4_1 ZSext [10:0] (.out(ZSextOut[10:0]), .inputA({11{0}}), .inputB({{8{0}},Instruction[7:5]}), .inputC({11{Instruction[4]}}), .inputD({{8{Instruction[7]}},Instruction[7:5]}), .sel());
    //
    //mux2_1 IformatMux [15:0] (.out(JumpExt[15:0]), .inputA(ZSext4b7b_16b[15:0]), .inputB(Zext10b_16b[15:0]), .sel(ImmSel));
    
//---------- Extender ------------//
    wire [15:0] extIn, extOut;
    always @* begin         // Choose # bits to extend
        case(ImmSel[1])
            1'b0: extIn = Instruction[4:0];   // If 5 bit, pass 5 bits
            1'b1: begin
                case(I2JSel)
                    1'b0: extIn = Instruction[7:0];   // If 8 bit, pass 8 bit
                    1'b1: extIn = Instruction[10:0];  // If 11 bit, pass 11 bit
                    default: extIn[15:0] = 16'h0000;
                endcase
            end
            default: extIn[15:0] = 16'h0000;
        endcase
    end

    sign_ext EXTBLOCK (.out(extOut[15:0]), .in(extIn[15:0]), .zero_ext(ImmSel[1:0]));

//--------------------------------//

    wire [15:0] aluInB;
    mux2_1 ALUInBMux  [15:0] (.out(aluInB[15:0]), .inputA(Reg2Data[15:0]), .inputB(extOut[15:0]), .sel(ALUSel));

//================================//



//=========== Control ============//

    control(.RegWrite(RegWrite),.Iformat(Iformat),.PcSel(PcSel),.MemRead(MemRead),.MemWrite(MemWrite),
            .ALUcntrl(ALUcntrl),.Val2Reg(Val2Reg),.ImmSel(ImmSel),.ImmExt(ImmExt),.Halt(Halt),
            .LinkReg(LinkReg),.Instr(Instruction[15:11]),.Opcode(Instruction[1:0]));

//================================//



//============= ALU ==============//
   wire[15:0] aluOut;
    alu (.Out(aluOut[15:0]), .Ofl(Ofl), .Zero(ZeroFlag), 
         .InA(Reg1Data[15:0]), .InB(aluInB[15:0]), .Cin(Cin), // NOTE! If ALU controls (i.e. subtractions) are contained within alu.v, we can remove Cin from module i/o.
         .Oper(ALUcntrl[somebits]), .invA(ALUcntrl[bit]), .invB(ALUcntrl[bit]), .sign(ALUcntrl[bit]));

         // NOTE! Currently ALU is written as alu(out, opcode, funct, Ain, Bin);
         // inverse(2's comp) is done internally
         // Sign is assumed
         // There are two operands - opcode and funct, opcode is Instr[15:11] and funct is Instr[1:0]
         // Ofl and zero aren't used yet? idk about those
         
//----------- ALU Out ------------//

//================================//



//=========== DataMem ============//

    // May need a mux and ctrl signal to choose where MemAddr comes from (ALU vs. (--Extension--> no direction use))
    // MemDataIn may be just WriteData, also likely the output of a mux coming from ALU and elsewhere (maybe)
    mem(.ReadData(ReadData),.Addr(MemAddr), .WriteData(MemDataIn), .MemWrite(MemWrite), .MemRead(MemRead));

//--------- DataMem Out ----------//

//================================//
endmodule