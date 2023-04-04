module id_ex(
    /*-----PIPELINE OUT-----*/
    InstrOut, ImmExtOut, PcOut,RsOut, RtOut,    //Data out
    ALUSelOut,                                  //Control out (Execute)
    MemEnableOut, MemWrOut, HaltOut,            //Control out (Memory)
    Val2RegOut,                                 //Control out (Writeback)

    /*-----PIPELINE IN-----*/
    InstrIn, ImmExtIn, PcIn,RsIn, RtIn, //Data in
    ALUSelIn,                           //Control in (Execute)
    MemEnableIn, MemWrIn, HaltIn,       //Control in (Memory)
    Val2RegIn,                          //Control in (Writeback)

    clk, rst);

    /*-----PIPELINE OUT-----*/
    output wire[15:0] InstrOut, ImmExtOut, PcOut,RsOut, RtOut;    //Data out
    output wire ALUSelOut;                                  //Control out (Execute)
    output wire MemEnableOut, MemWrOut, HaltOut;            //Control out (Memory)
    output wire Val2RegOut;                                 //Control out (Writeback)

    /*-----PIPELINE IN-----*/
    input wire[15:0] InstrIn, ImmExtIn, PcIn,RsIn, RtIn; //Data in
    input wire ALUSelIn;                           //Control in (Execute)
    input wire MemEnableIn, MemWrIn, HaltIn;       //Control in (Memory)
    input wire Val2RegIn;                          //Control in (Writeback)

    input wire clk, rst;


    dff_16 DATA[4:0](.q({InstrOut, ImmExtOut, PcOut,RsOut, RtOut}), .err(), .d({InstrIn, ImmExtIn, PcIn,RsIn, RtIn}), .clk(clk), .rst(rst));

    dff EX_cntrl(.q(ALUSelOut), .d(ALUSelIn), .clk(clk), .rst(rst));
    dff MEM_cntrl[2:0](.q({MemEnableOut, MemWrOut, HaltOut}),  .d({MemEnableIn, MemWrIn, HaltIns}), .clk(clk), .rst(rst));
    dff WB_cntrl(.q(Val2RegOut),  .d(Val2RegIn), .clk(clk), .rst(rst));

    // (.q(),  .d(), .clk(clk), .rst(rst));

endmodule