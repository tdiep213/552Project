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
    input wire  LinkRegOut, DestRegSelOut, RegWriteOut, //Decode control
                LinkRegIn, DestRegSelIn, RegWriteIn,
                ALUSelOut, //Execute control
                ALUSelIn,
                MemEnableOut, MemWrOut, HaltOut, // Memory control
                MemEnableIn, MemWrIn, HaltIn,
                Val2RegOut, // Writeback control
                Val2RegIn;
    input wire clk, rst;


    dff_16 Instruction(.q(InstrOut), .err(), .d(InstrIn), .clk(clk), .rst(rst));
    dff_16 Immediate(.q(ImmExtOut), .err(), .d(ImmExtIn), .clk(clk), .rst(rst));
    dff_16 ProgCnt(.q(PcOut), .err(), .d(PcIn), .clk(clk), .rst(rst));
    
    dff_16 ID_cntrl[2:0](.q({LinkRegOut, DestRegSelOut, RegWriteOut}), .err(), .d({LinkRegIn, DestRegSelIn, RegWriteIn}), .clk(clk) , .rst(rst));
    dff_16 EX_cntrl(.q(ALUSelOut), .err(), .d(ALUSelIn), .clk(clk), .rst(rst));
    dff_16 MEM_cntrl[2:0](.q({MemEnableOut, MemWrOut, HaltOut}), .err(), .d({MemEnableIn, MemWrIn, HaltIns}), .clk(clk), .rst(rst));
    dff_16 WB_cntrl(.q(Val2RegOut), .err(), .d(Val2RegIn), .clk(clk), .rst(rst));

    // (.q(), .err(), .d(), .clk(clk), .rst(rst));

endmodule