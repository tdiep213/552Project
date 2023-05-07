module ex_mem(
    /*-----PIPELINE OUT-----*/
    RtOut, ALUoutOut, ImmExtOut, PcOut,    //Data out
    MemEnableOut, MemWrOut, HaltOut ,WriteRegAddrOut,            //Control out (Memory)
    Val2RegOut,RegWriteOut, LinkRegOut,                                 //Control out (Writeback)

    /*-----PIPELINE IN-----*/
    RtIn, ALUoutIn,  WriteRegAddrIn, ImmExtIn, PcIn, //Data in
    MemEnableIn, MemWrIn, HaltIn,       //Control in (Memory)
    Val2RegIn, RegWriteIn, LinkRegIn,                          //Control in (Writeback)

    mem_stall,
    clk, rst);

    /*-----PIPELINE OUT-----*/
    output wire[15:0] RtOut, ALUoutOut, ImmExtOut, PcOut;    //Data out
    output wire[2:0] WriteRegAddrOut;
    output wire MemEnableOut, MemWrOut, HaltOut;            //Control out (Memory)
    output wire[1:0] LinkRegOut;
    output wire Val2RegOut, RegWriteOut;                                 //Control out (Writeback)

    /*-----PIPELINE IN-----*/
    input wire[15:0] RtIn, ALUoutIn, ImmExtIn, PcIn; //Data in
    input wire[2:0] WriteRegAddrIn;
    input wire MemEnableIn, MemWrIn, HaltIn;       //Control in (Memory)
    input wire[1:0] LinkRegIn;
    input wire Val2RegIn, RegWriteIn;                          //Control in (Writeback)

    input mem_stall;
    input wire clk, rst;

    wire clk_en, clk_cntrl;
    dff CLK_CNTRL(.q(clk_cntrl), .d(mem_stall), .clk(clk), .rst(rst));
    assign clk_en = clk & ~clk_cntrl;


    dff_16 DATA[3:0](.q({RtOut, ALUoutOut,PcOut, ImmExtOut}), .err(),  .d({RtIn, ALUoutIn,PcIn, ImmExtIn}), .clk(clk), .rst(rst));
    dff WB_data[2:0](.q(WriteRegAddrOut),  .d(WriteRegAddrIn), .clk(en), .rst(rst));

    dff MEM_cntrl[2:0](.q({MemEnableOut, MemWrOut, HaltOut}),  .d({MemEnableIn, MemWrIn, HaltIn}), .clk(clk), .rst(rst));
    dff WB_cntrl[3:0](.q({Val2RegOut, RegWriteOut, LinkRegOut}),  .d({Val2RegIn, RegWriteIn, LinkRegIn}), .clk(clk), .rst(rst));

    // (.q(),  .d(), .clk(clk), .rst(rst));

endmodule