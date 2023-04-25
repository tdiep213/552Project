//program counter, increments by 2, Jump/branch logic
module pc(
    //Outputs
    PC, prevPC,
    //Inputs
    newAddr,
    PcStall,//Control Signals
    clk, rst
);

    output reg [15:0] prevPC;   // Previous PC Instruction 
    output wire[15:0] PC;       // PC used on the outside

    input wire [15:0] newAddr; // Proposed next PC coming from Brancher
    input wire PcStall;         // Control signal, 
    input wire clk, rst;
    
    wire [15:0] nextPC, savedNextPC;

    assign nextPC = PCStall ? savedNextPC : newAddr;
    assign PC = PCStall ? prevPC : nextPC;    // If stalling, use the previous PC value, otherwise, listen to nextAddr
    
    dff_16 PcReg    (.q(prevPC),      .err(), .d(PC),     .clk(clk), .rst(rst));   // Keep track of last PC
    dff_16 NextPcReg(.q(savedNextPC), .err(), .d(nextPC), .clk(clk), .rst(rst));   // Keep track of last new addr.

endmodule