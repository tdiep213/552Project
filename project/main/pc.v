//program counter, increments by 2, jump/branch logic
module pc(
    //Outputs
    PcAddr,
    ReadAddr,
    //Inputs
    ImmSel,
    PcSel,
    Halt

);
    input wire ImmSel, PcSel, Halt;
    output reg[15:0] PcAddr, ReadAddr;
    
endmodule