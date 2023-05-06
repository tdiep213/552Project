module if_id(InstrOut, ImmExtOut, PcOut, InstrIn, ImmExtIn, PcIn, clk, rst,
        LinkRegOut, WriteRegAddrOut, RegWriteOut, b_flagOut, j_flagOut,RegJmpOut, //Decode control
        LinkRegIn, WriteRegAddrIn, RegWriteIn, b_flagIn, j_flagIn,RegJmpIn,
        ALUSelOut, ForwardsOut,//Execute control
        ALUSelIn, ForwardsIn,
        MemEnableOut, MemWrOut, HaltOut, // Memory control
        MemEnableIn, MemWrIn, HaltIn,
        Val2RegOut, // Writeback control
        Val2RegIn,
        branchTaken

);
    output wire[15:0] InstrOut, ImmExtOut, PcOut;
    
    input wire[15:0] InstrIn, ImmExtIn, PcIn;

    input wire[1:0] LinkRegIn;
    input wire[2:0] WriteRegAddrIn;
    input wire[5:0] ForwardsIn;
    input wire RegWriteIn, b_flagIn, j_flagIn, RegJmpIn;                          //DECODE
    input wire ALUSelIn;                            //EXECUTE
    input wire MemEnableIn, MemWrIn, HaltIn;        //MEMORY
    input wire Val2RegIn;                           //Writeback

    input wire branchTaken;                         //Branch Pred

    output wire[1:0] LinkRegOut;
    output wire[2:0] WriteRegAddrOut;
    output wire[5:0] ForwardsOut;
    output wire  RegWriteOut, b_flagOut, j_flagOut, RegJmpOut; //Decode control
    output wire ALUSelOut; //Execute control
    output wire MemEnableOut, MemWrOut, HaltOut; // Memory control
    output wire Val2RegOut; // Writeback control


    input wire clk, rst;
    wire[15:0] Instrc;
    dff_16 Instruction(.q(Instrc), .err(), .d(InstrIn), .clk(clk), .rst(rst));
    dff_16 Immediate(.q(ImmExtOut), .err(), .d(ImmExtIn), .clk(clk), .rst(rst));
    dff_16 ProgCnt(.q(PcOut), .err(), .d(PcIn), .clk(clk), .rst(rst));
    
    assign InstrOut = branchTaken ? 16'h0800 : Instrc; // Culls Instruction if branch taken 

    dff ID_cntrl[8:0](.q({LinkRegOut, WriteRegAddrOut, RegWriteOut, b_flagOut, j_flagOut, RegJmpOut}),  .d({LinkRegIn, WriteRegAddrIn, RegWriteIn, b_flagIn, j_flagIn, RegJmpIn}), .clk(clk) , .rst(rst));
    dff EX_cntrl[6:0](.q({ALUSelOut, ForwardsOut}),  .d({ALUSelIn, ForwardsIn}), .clk(clk), .rst(rst));
    dff MEM_cntrl[2:0](.q({MemEnableOut, MemWrOut, HaltOut}),  .d({MemEnableIn, MemWrIn, HaltIn}), .clk(clk), .rst(rst));
    dff WB_cntrl(.q(Val2RegOut),  .d(Val2RegIn), .clk(clk), .rst(rst));

    // (.q(),  .d(), .clk(clk), .rst(rst));

endmodule