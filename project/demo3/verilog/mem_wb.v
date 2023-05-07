module  mem_wb(
        /*-----PIPELINE OUT-----*/
        MemOutOut, ALUoutOut,WriteRegAddrOut, ImmExtOut, PcOut,                         //Data out
        Val2RegOut, RegWriteOut, LinkRegOut,                                  //Control out (Writeback)

        /*-----PIPELINE IN-----*/
        MemOutIn, ALUoutIn,WriteRegAddrIn, ImmExtIn, PcIn,                          //Data in
        Val2RegIn,RegWriteIn, LinkRegIn,                                    //Control in (Writeback)

        mem_stall,
        clk, rst
    );

        /*-----PIPELINE OUT-----*/
        output wire[15:0] MemOutOut, ALUoutOut, ImmExtOut, PcOut;             //Data out
        output wire[2:0] WriteRegAddrOut;
        output wire[1:0] LinkRegOut;
        output wire Val2RegOut, RegWriteOut;                        //Control out (Writeback)

        /*-----PIPELINE IN-----*/
        input wire[15:0] MemOutIn, ALUoutIn, ImmExtIn, PcIn;                //Data in
        input wire[2:0] WriteRegAddrIn;
        input wire[1:0] LinkRegIn;
        input wire Val2RegIn, RegWriteIn;                         //Control in (Writeback)

    input mem_stall;
    input wire clk, rst;
    wire clk_en, clk_cntrl;
    dff CLK_CNTRL(.q(clk_cntrl), .d(mem_stall), .clk(clk), .rst(rst));
    assign clk_en = clk & ~clk_cntrl;

    dff_16 DATA[3:0](.q({ MemOutOut, ALUoutOut, PcOut, ImmExtOut}), .err(), .d({MemOutIn, ALUoutIn, PcIn, ImmExtIn}), .clk(clk_en), .rst(rst));
    dff WB_data[2:0](.q(WriteRegAddrOut),  .d(WriteRegAddrIn), .clk(clk_en), .rst(rst));

    dff WB_cntrl[3:0](.q({Val2RegOut, RegWriteOut, LinkRegOut}),  .d({Val2RegIn, RegWriteIn, LinkRegIn}), .clk(clk_en), .rst(rst));

    endmodule