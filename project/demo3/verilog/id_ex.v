module id_ex(
    /*-----PIPELINE OUT-----*/
    InstrOut, ImmExtOut, PcOut,RsOut, RtOut, WriteRegAddrOut,    //Data out
    ALUSelOut, ForwardsOut,                     //Control out (Execute)
    MemEnableOut, MemWrOut, HaltOut,            //Control out (Memory)
    Val2RegOut, RegWriteOut, LinkRegOut,                                 //Control out (Writeback)

    /*-----PIPELINE IN-----*/
    InstrIn, ImmExtIn, PcIn,RsIn, RtIn, WriteRegAddrIn, //Data in
    ALUSelIn, ForwardsIn,               //Control in (Execute)
    MemEnableIn, MemWrIn, HaltIn,       //Control in (Memory)
    Val2RegIn, RegWriteIn, LinkRegIn,                       //Control in (Writeback)

    mem_stall,
    clk, rst);
    

    /*-----PIPELINE OUT-----*/
    output wire[15:0] InstrOut, ImmExtOut, PcOut,RsOut, RtOut;    //Data out
    output wire[2:0] WriteRegAddrOut;
    output wire[1:0] LinkRegOut;
    output wire[5:0] ForwardsOut;
    output wire ALUSelOut;                                  //Control out (Execute)
    output wire MemEnableOut, MemWrOut, HaltOut;            //Control out (Memory)
    output wire Val2RegOut, RegWriteOut;                                 //Control out (Writeback)

    /*-----PIPELINE IN-----*/
    input wire[15:0] InstrIn, ImmExtIn, PcIn,RsIn, RtIn; //Data in
    input wire[2:0] WriteRegAddrIn;
    input wire[1:0] LinkRegIn;
    input wire[5:0] ForwardsIn;
    input wire ALUSelIn;                           //Control in (Execute)
    input wire MemEnableIn, MemWrIn, HaltIn;       //Control in (Memory)
    input wire Val2RegIn, RegWriteIn;                          //Control in (Writeback)

    input wire mem_stall;
    input wire clk, rst;

    wire clk_en, clk_cntrl;
    dff CLK_CNTRL(.q(clk_cntrl), .d(mem_stall), .clk(clk), .rst(rst));
    assign clk_en = clk & ~clk_cntrl;


    dff_16 DATA[4:0](.q({InstrOut, ImmExtOut, PcOut,RsOut, RtOut}), .err(), .d({InstrIn, ImmExtIn, PcIn,RsIn, RtIn}), .clk(clk_en), .rst(rst));
    dff WB_data[2:0](.q(WriteRegAddrOut),  .d(WriteRegAddrIn), .clk(clk_en), .rst(rst));

    dff EX_cntrl[6:0](.q({ALUSelOut, ForwardsOut}), .d({ALUSelIn, ForwardsIn}), .clk(clk_en), .rst(rst));
    dff MEM_cntrl[2:0](.q({MemEnableOut, MemWrOut, HaltOut}),  .d({MemEnableIn, MemWrIn, HaltIn}), .clk(clk_en), .rst(rst));
    dff WB_cntrl[3:0](.q({Val2RegOut, RegWriteOut, LinkRegOut}),  .d({Val2RegIn, RegWriteIn, LinkRegIn}), .clk(clk_en), .rst(rst));

    // (.q(),  .d(), .clk(clk), .rst(rst));

endmodule