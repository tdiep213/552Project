module if_id(InstrOut, ImmExtOut, PcOut, InstrIn, ImmExtIn, PcIn, clk, rst,
        LinkRegOut, DestRegSelOut, RegWriteOut, //Decode control
        LinkRegIn, DestRegSelIn, RegWriteIn,
        ALUSelOut, //Execute control
        ALUSelIn,
        MemEnableOut, MemWrOut, HaltOut, // Memory control
        MemEnableIn, MemWrIn, HaltIn,
        Val2RegOut, // Writeback control
        Val2RegIn

);
    output wire[15:0] InstrOut, ImmExtOut, PcOut;
    
    input wire[15:0] InstrIn, ImmExtIn, PcIn;

    input wire[1:0] LinkRegIn, DestRegSelIn;
    input wire RegWriteIn;                          //DECODE
    input wire ALUSelIn;                            //EXECUTE
    input wire MemEnableIn, MemWrIn, HaltIn;        //MEMORY
    input wire Val2RegIn;                           //Writeback

    output wire[1:0] LinkRegOut, DestRegSelOut;
    output wire  RegWriteOut; //Decode control
    output wire ALUSelOut; //Execute control
    output wire MemEnableOut, MemWrOut, HaltOut; // Memory control
    output wire Val2RegOut; // Writeback control


    input wire clk, rst;
    
    dff_16 Instruction(.q(InstrOut), .err(), .d(InstrIn), .clk(clk), .rst(rst));
    dff_16 Immediate(.q(ImmExtOut), .err(), .d(ImmExtIn), .clk(clk), .rst(rst));
    dff_16 ProgCnt(.q(PcOut), .err(), .d(PcIn), .clk(clk), .rst(rst));
    
    dff ID_cntrl[4:0](.q({LinkRegOut, DestRegSelOut, RegWriteOut}),  .d({LinkRegIn, DestRegSelIn, RegWriteIn}), .clk(clk) , .rst(rst));
    dff EX_cntrl(.q(ALUSelOut),  .d(ALUSelIn), .clk(clk), .rst(rst));
    dff MEM_cntrl[2:0](.q({MemEnableOut, MemWrOut, HaltOut}),  .d({MemEnableIn, MemWrIn, HaltIn}), .clk(clk), .rst(rst));
    dff WB_cntrl(.q(Val2RegOut),  .d(Val2RegIn), .clk(clk), .rst(rst));

    // (.q(),  .d(), .clk(clk), .rst(rst));

endmodule