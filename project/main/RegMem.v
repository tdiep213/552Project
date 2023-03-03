//Register memory block
module RegMem(
    //Output(s)
    Reg1Data,
    Reg2Data,
    //Input(s)
    Reg1Addr, 
    Reg2Addr, 
    WriteRegAddr, 
    WriteData,
    RegWrite
);
    input wire[2:0] Reg1Addr, Reg2Addr, WriteRegAddr, WriteData;
    input wire RegWrite; 
    output reg[15:0] Reg1Data, Reg2Data;
endmodule