module ex_mem(
    /*-----PIPELINE OUT-----*/
    RtOut, ALUoutOut,    //Data out
    MemEnableOut, MemWrOut, HaltOut ,WriteRegAddrOut,            //Control out (Memory)
    Val2RegOut,RegWriteOut,                                 //Control out (Writeback)

    /*-----PIPELINE IN-----*/
    RtIn, ALUoutIn,  WriteRegAddrIn, //Data in
    MemEnableIn, MemWrIn, HaltIn,       //Control in (Memory)
    Val2RegIn, RegWriteIn,                          //Control in (Writeback)

    clk, rst);

    /*-----PIPELINE OUT-----*/
    output wire[15:0] RtOut, ALUoutOut;    //Data out
    output wire[2:0] WriteRegAddrOut;
    output wire MemEnableOut, MemWrOut, HaltOut;            //Control out (Memory)
    output wire Val2RegOut, RegWriteOut;                                 //Control out (Writeback)

    /*-----PIPELINE IN-----*/
    input wire[15:0] RtIn, ALUoutIn; //Data in
    input wire[2:0] WriteRegAddrIn;
    input wire MemEnableIn, MemWrIn, HaltIn;       //Control in (Memory)
    input wire Val2RegIn, RegWriteIn;                          //Control in (Writeback)

    input wire clk, rst;

    dff_16 DATA[1:0](.q({RtOut, ALUoutOut}), .err(),  .d({RtIn, ALUoutIn}), .clk(clk), .rst(rst));
    dff WB_data[2:0](.q(WriteRegAddrOut),  .d(WriteRegAddrIn), .clk(clk), .rst(rst));

    dff MEM_cntrl[2:0](.q({MemEnableOut, MemWrOut, HaltOut}),  .d({MemEnableIn, MemWrIn, HaltIn}), .clk(clk), .rst(rst));
    dff WB_cntrl[1:0](.q({Val2RegOut, RegWriteOut}),  .d({Val2RegIn, RegWriteIn}), .clk(clk), .rst(rst));

    // (.q(),  .d(), .clk(clk), .rst(rst));

endmodule