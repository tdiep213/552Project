//Connects various computation and storage blocks
module main();
    wire/*TODO*/ ReadAddr, PcAddr;
    wire[15:0] Instruction;
    wire/*TODO*/ ReadData;
    wire[15:0] Reg1Data, Reg2Data;
    wire Iformat, PcSel, MemRead, MemWrite, ALUcntrl, Val2Reg, ImmExt,ImmSel, Halt, LinkReg, RegWrite;
    /* Suggested New/Renamed Signals:                            ^-------^ not sure what these control.
    ALUSel - chooses ALU input B, 
    WriteDataSel - chooses new PCAddr or OperOutput to write to RegFile,
    WriteRegSel - chooses which register should act as destination.
    Cin - For subtraction operations
    */
//============== PC ==============//
   
    pc(.PcAddr(PcAddr),.ReadAddr(ReadAddr),.ImmSel(ImmSel),.PcSel(PcSel),.Halt(Halt));

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
    mux4_1 WriteRegAddrMux [2:0]  (.out(WriteRegAddr[2:0]), .inputA(Instruction[10:8]), .inputB(R7[2:0]), .inputC(Instruction[7:5]), .inputD(Instruction[4:2]), .sel(WriteRegSel[2:0]));
    mux2_1 WriteDataMux    [15:0] (.out(WriteDataIn[15:0]), .inputA(PCAddr[15:0]), .inputB(OperOutput[15:0]), .sel(WriteDataSel));

    RegMem(.Reg1Data(Reg1Data), .Reg2Data(Reg2Data), .Reg1Addr(Instruction[10:8]), .Reg2Addr(Instruction[7:5]),
           .WriteRegAddr(WriteRegAddr[2:0]), .WriteData(WriteDataIn[15:0]), .RegWrite(RegWrite));

//--------- RegMem Out -----------//

    // wire [15:0] aluInB, I1ExtMuxOut, I_sExt, I_zExt, I2_sExt, J_sExt, JumpExt;

    // mux2_1 ExtMux_I1 [15:0] (.out(I1ExtMuxOut[15:0]), .inputA(I_sExt[15:0]), inputB(I_zExt[15:0]), .sel(I1ExtSel))  // I1 and I2 ExtSel should match up with Iformat or other sel signals
    // mux2_1 SignExtMux_I2 [15:0] (.out(JumpExt[15:0]), .inputA(I2_sExt[15:0]), inputB(J_sExt[15:0]), .sel(I2JExtSel)) 
    
    // mux2_1 ALUInBMux [15:0] (.out(aluInB[15:0]), .inputA(Reg2Data[15:0]), .inputB(I1ExtMuxOut[15:0]), .sel(ALUSel));

    wire [15:0] Zext10b_16b, ZSext4b7b_16b, aluInB, JumpExt; 
    wire [10:0] ZSextOut;

    assign ZSext4b7b_16b = {ZSextOut[10:0],Instruction[4:0]};
    assign Zext10b_16b = {[0,0,0,0,0], Instruction[10:0]};

    mux4_1 ZSext [10:0] (.out(ZSextOut[10:0]), .inputA({11{0}}), .inputB({{8{0}},Instruction[7:5]}), .inputC({11{Instruction[4]}}), .inputD({{8{Instruction[7]}},Instruction[7:5]}), .sel());

    mux2_1 IformatMux [15:0] (.out(JumpExt[15:0]), .inputA(ZSext4b7b_16b[15:0]), .inputB(Zext10b_16b[15:0]), .sel(ImmSel));
    mux2_1 ALUInBMux  [15:0] (.out(aluInB[15:0]), .inputA(Reg2Data[15:0]), .inputB(ZSext4b7b_16b[15:0]), .sel(ALUSel));

//================================//



//=========== Control ============//

    control(.RegWrite(RegWrite),.Iformat(Iformat),.PcSel(PcSel),.MemRead(MemRead),.MemWrite(MemWrite),
            .ALUcntrl(ALUcntrl),.Val2Reg(Val2Reg),.ImmSel(ImmSel),.ImmExt(ImmExt),.Halt(Halt),
            .LinkReg(LinkReg),.Instr(Instruction[15:11]));

//================================//



//============= ALU ==============//
   
    alu (.Out(aluOut[15:0]), .Ofl(Ofl), .Zero(ZeroFlag), 
         .InA(Reg1Data[15:0]), .InB(aluInB[15:0]), .Cin(Cin), 
         .Oper(ALUcntrl[somebits]), .invA(ALUcntrl[bit]), .invB(ALUcntrl[bit]), .sign(ALUcntrl[bit]));
         // must determine how ALUcntrl/ALUctrl is split up to control functions.
//----------- ALU Out ------------//

//================================//



//=========== DataMem ============//

    // May need a mux and ctrl signal to choose where MemAddr comes from (ALU vs. Extension)
    // MemDataIn may be just WriteData, also likely the output of a mux coming from ALU and elsewhere (maybe)
    mem(.ReadData(ReadData),.Addr(MemAddr), WriteData(MemDataIn), .MemWrite(MemWrite), .MemRead(MemRead));

//--------- DataMem Out ----------//

//================================//
endmodule