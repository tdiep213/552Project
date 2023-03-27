//Memeory 
module mem(
    //Output(s)
    ReadData,
    //Input(s)
    Addr,
    WriteData,
    MemWrite,
    MemRead
);
    input wire MemWrite, MemRead;
    input wire[15:0] Addr, WriteData;

    output reg [15:0] ReadData; 

endmodule