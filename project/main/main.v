//Connects various computation and storage blocks
module main();
    wire/*TODO*/ ReadAddr;
    wire[15:0] Instruction;
    wire/*TODO*/ ReadData;
    wire[15:0] Reg1Data, Reg2Data;
    wire Iformat, PcSel, MemRead, MemWrite, ALUcntrl, Val2Reg, Imm, Halt, LinkReg, RegWrite;
    /* Suggested New/Renamed Signals:                            
    ALUSel - chooses ALU input B, 
    WriteDataSel - chooses new PCAddr or OperOutput to write to RegFile,
    WriteRegSel - chooses which register should act as destination.
    Cin - For subtraction operations
    */
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
            1'b0: assign extIn[15:0] = Instruction[4:0];   // If 5 bit, pass 5 bits
            1'b1: begin
                case(I2JSel)
                    1'b0: assign extIn[15:0] = Instruction[7:0];   // If 8 bit, pass 8 bit
                    1'b1: assign extIn[15:0] = Instruction[10:0];  // If 11 bit, pass 11 bit
                    default: assign extIn[15:0] = {16{0}};
            end
            default: assign extIn[15:0] = {16{0}};
    end

    sign_ext EXTBLOCK (.out(extOut), .in(extIn[15:0]), .zero_ext());

//--------------------------------//


    mux2_1 ALUInBMux  [15:0] (.out(aluInB[15:0]), .inputA(Reg2Data[15:0]), .inputB(extOut[15:0]), .sel(ALUSel));

//================================//



//=========== Control ============//

    control(.RegWrite(RegWrite),.Iformat(Iformat),.PcSel(PcSel),.MemRead(MemRead),.MemWrite(MemWrite),
            .ALUcntrl(ALUcntrl),.Val2Reg(Val2Reg),.ImmSel(ImmSel),.ImmExt(ImmExt),.Halt(Halt),
            .LinkReg(LinkReg),.Instr(Instruction[15:11]),.Opcode(Instruction[1:0])));

//================================//



//============= ALU ==============//
   wire[15:0] aluOut;
    alu (.Out(aluOut[15:0]), .Ofl(Ofl), .Zero(ZeroFlag), 
         .InA(Reg1Data[15:0]), .InB(aluInB[15:0]), .Cin(Cin), 
         .Oper(ALUcntrl[somebits]), .invA(ALUcntrl[bit]), .invB(ALUcntrl[bit]), .sign(ALUcntrl[bit]));
         // must determine how ALUcntrl/ALUctrl is split up to control functions.
//----------- ALU Out ------------//

//================================//



//=========== DataMem ============//

    // May need a mux and ctrl signal to choose where MemAddr comes from (ALU vs. Extension)
    // MemDataIn may be just WriteData, also likely the output of a mux coming from ALU and elsewhere (maybe)
    mem(.ReadData(ReadData),.Addr(MemAddr), .WriteData(MemDataIn), .MemWrite(MemWrite), .MemRead(MemRead));

//--------- DataMem Out ----------//

//================================//
endmodule