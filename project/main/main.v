//Connects various computation and storage blocks
module main();
    wire/*TODO*/ ReadAddr, PcAddr;
    wire[15:0] Instruction;
    wire/*TODO*/ ReadData;
    wire/*TODO*/ Reg1Data, Reg2Data;
    wire Iformat, PcSel, MemRead, MemWrite, ALUcntrl, Val2Reg, ImmExt,ImmSel, Halt, LinkReg, RegWrite; 
    

    pc(.PcAddr(PcAddr),.ReadAddr(ReadAddr),.ImmSel(ImmSel),.PcSel(PcSel),.Halt(Halt));

    InstrMem(.Instr(Instruction),.ReadAddr(ReadAddr));

    RegMem(.Reg1Data(Reg1Data),.Reg2Data(Reg2Data),.Reg1Addr(Instruction[10:8]),.Reg2Addr(Instruction[7:5]),
            .WriteRegAddr(Instruction[7:5]),.WriteData(/*TODO*/),.RegWrite(RegWrite));

    control(.RegWrite(RegWrite),.Iformat(Iformat),.PcSel(PcSel),.MemRead(MemRead),.MemWrite(MemWrite),
            .ALUcntrl(ALUcntrl),.Val2Reg(Val2Reg),.ImmSel(ImmSel),.ImmExt(ImmExt),.Halt(Halt),
            .LinkReg(LinkReg),.Instr(Instruction[15:11]));
    
    alu(/*TODO*/);
    
    mem(.ReadData(/*TODO*/),.Addr/*TODO*/WriteData(Reg2Data),.MemWrite(MemWrite),.MemRead(MemRead));
endmodule