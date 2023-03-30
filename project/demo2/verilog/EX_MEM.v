module ex_mem(
    /*-----PIPELINE OUT-----*/
    RtOut, ALUoutOut,    //Data out
    ALUSelOut,                                  //Control out (Execute)
    MemEnableOut, MemWrOut, HaltOut,            //Control out (Memory)
    Val2RegOut,                                 //Control out (Writeback)

    /*-----PIPELINE IN-----*/
    RtIn, ALUoutIn, //Data in
    ALUSelIn,                           //Control in (Execute)
    MemEnableIn, MemWrIn, HaltIn,       //Control in (Memory)
    Val2RegIn,                          //Control in (Writeback)

    clk, rst);

    dff_16 DATA[1:0]A(.q({RtOut, ALUoutOut}), .err(), .d({RtIn, ALUoutIn}), .clk(clk), .rst(rst));

    dff_16 EX_cntrl(.q(ALUSelOut), .err(), .d(ALUSelIn), .clk(clk), .rst(rst));
    dff_16 MEM_cntrl[2:0](.q({MemEnableOut, MemWrOut, HaltOut}), .err(), .d({MemEnableIn, MemWrIn, HaltIns}), .clk(clk), .rst(rst));
    dff_16 WB_cntrl(.q(Val2RegOut), .err(), .d(Val2RegIn), .clk(clk), .rst(rst))

    // (.q(), .err(), .d(), .clk(clk), .rst(rst));

endmodule