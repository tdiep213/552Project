//program counter, increments by 2, Jump/branch logic
module pc(
    //Outputs
    PC, 
    //Inputs
    Rs, Imm,
    PcStall, RegJmp, PCSel, Halt,//Control Signals
    clk, rst
);

    output wire[15:0] PC;       // PC used on the outside

    input wire [15:0] Rs, Imm;       //
    input wire PcStall, RegJmp, PCSel, Halt;         //
    input wire clk, rst;
    
    wire [15:0] PcImm, RsImm, Inc2;
    reg[15:0] nextPC;

    // assign nextPC = PcStall ? savedNextPC : newAddr;
    // assign PC = PcStall ? prevPC : nextPC;    // If stalling, use the previous PC value, otherwise, listen to nextAddr
    
    // dff_16 PcReg    (.q(prevPC),      .err(), .d(PC),     .clk(clk), .rst(rst));   // Keep track of last PC
    // dff_16 NextPcReg(.q(savedNextPC), .err(), .d(nextPC), .clk(clk), .rst(rst));   // Keep track of last new addr.

    cla16b PcInc(.sum(Inc2),  .cOut(), .inA(PC), .inB(16'h0002), .cIn(1'b0));
    cla16b PCIMM(.sum(PcImm), .cOut(), .inA(Inc2),    .inB(Imm),      .cIn(1'b0));
    cla16b RSIMM(.sum(RsImm), .cOut(), .inA(Rs),      .inB(Imm),      .cIn(1'b0));

    always@* begin
        casex({RegJmp, PCSel, Halt, rst})
            4'b0000: nextPC = Inc2;
            4'b0100: nextPC = PcImm;
            4'b1100: nextPC = RsImm;
            4'b???1: nextPC = 0;
            default: nextPC = PC;     // Default to Halt
        endcase
    end

    dff_16 PC_REG(.q(PC), .err(), .d(nextPC), .clk(clk), .rst(rst));

endmodule