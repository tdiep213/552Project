module id_ex(
    /*-----PIPELINE OUT-----*/
    InstrOut, ImmExtOut, PcOut,RsOut, RtOut,    //Data out
    ALUSelOut,                                  //Control out (Execute)
    MemEnableOut, MemWrOut, HaltOut,            //Control out (Memory)
    Val2RegOut,                                 //Control out (Writeback)

    /*-----PIPELINE IN-----*/
    InstrIn, ImmExtIn, PcIn,RsIn, RtIn, //Data in
    ALUSelIn,                           //Control out (Execute)
    MemEnableIn, MemWrIn, HaltIn,       //Control out (Memory)
    Val2RegIn,                          //Control out (Writeback)

    clk, rst);

    dff_16 DAT[4:0]A(.q({InstrOut, ImmExtOut, PcOut,RsOut, RtOut}), .err(), .d({InstrIn, ImmExtIn, PcIn,RsIn, RtIn}), .clk(clk), .rst(rst));

    dff_16 EX_cntrl(.q(ALUSelOut), .err(), .d(ALUSelIn), .clk(clk), .rst(rst));
    dff_16 MEM_cntrl[2:0](.q({MemEnableOut, MemWrOut, HaltOut}), .err(), .d({MemEnableIn, MemWrIn, HaltIns}), .clk(clk), .rst(rst));
    dff_16 WB_cntrl(.q(Val2RegOut), .err(), .d(Val2RegIn), .clk(clk), .rst(rst))

    // (.q(), .err(), .d(), .clk(clk), .rst(rst));

endmodule