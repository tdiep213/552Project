module ex_mem(
    /*-----PIPELINE OUT-----*/
    RtOut, ALUoutOut,    //Data out
    MemEnableOut, MemWrOut, HaltOut,            //Control out (Memory)
    Val2RegOut,                                 //Control out (Writeback)

    /*-----PIPELINE IN-----*/
    RtIn, ALUoutIn, //Data in
    MemEnableIn, MemWrIn, HaltIn,       //Control in (Memory)
    Val2RegIn,                          //Control in (Writeback)

    clk, rst);

    /*-----PIPELINE OUT-----*/
    output wire RtOut, ALUoutOut;    //Data out
    output wire MemEnableOut, MemWrOut, HaltOut;            //Control out (Memory)
    output wire Val2RegOut;                                 //Control out (Writeback)

    /*-----PIPELINE IN-----*/
    input wire RtIn, ALUoutIn; //Data in
    input wire MemEnableIn, MemWrIn, HaltIn;       //Control in (Memory)
    input wire Val2RegIn;                          //Control in (Writeback)

    input wire clk, rst;

    dff_16 DATA[1:0](.q({RtOut, ALUoutOut}), .err(), .d({RtIn, ALUoutIn}), .clk(clk), .rst(rst));

    dff_16 MEM_cntrl[2:0](.q({MemEnableOut, MemWrOut, HaltOut}), .err(), .d({MemEnableIn, MemWrIn, HaltIns}), .clk(clk), .rst(rst));
    dff_16 WB_cntrl(.q(Val2RegOut), .err(), .d(Val2RegIn), .clk(clk), .rst(rst));

    // (.q(), .err(), .d(), .clk(clk), .rst(rst));

endmodule