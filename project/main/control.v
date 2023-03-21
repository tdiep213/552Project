//Commands other modules
module control(
    //Output(s)
    RegWrite,
    Iformat,
    PcSel,
    MemRead,
    MemWrite,
    ALUcntrl,
    Val2Reg,
    ImmExt,
    ImmSel,
    Halt,
    LinkReg,
    //Input(s)
    Instr
);
    output wire RegWrite, Iformat, PcSel, MemRead, MemWrite, Val2Reg, ImmExt,ImmSel, Halt, LinkReg;
    output wire[4:0] ALUcntrl;
    input wire[4:0] Instr;
endmodule