module  mem_wb(
        /*-----PIPELINE OUT-----*/
        MemOutOut, ALUoutOut,WriteRegAddrOut,                         //Data out
        Val2RegOut, RegWriteOut,                                  //Control out (Writeback)

        /*-----PIPELINE IN-----*/
        MemOutIn, ALUoutIn,WriteRegAddrIn,                           //Data in
        Val2RegIn,RegWriteIn,                                    //Control in (Writeback)

        clk, rst
    );

        /*-----PIPELINE OUT-----*/
        output wire[15:0] MemOutOut, ALUoutOut;              //Data out
        output wire[2:0] WriteRegAddrOut;
        output wire Val2RegOut, RegWriteOut;                        //Control out (Writeback)

        /*-----PIPELINE IN-----*/
        input wire[15:0] MemOutIn, ALUoutIn;                //Data in
        input wire[2:0] WriteRegAddrIn;
        input wire Val2RegIn, RegWriteIn;                         //Control in (Writeback)

        input wire clk, rst;

    dff_16 DATA[1:0](.q({ MemOutOut, ALUoutOut}), .err(), .d({MemOutIn, ALUoutIn}), .clk(clk), .rst(rst));
    dff WB_data[2:0](.q(WriteRegAddrOut),  .d(WriteRegAddrIn), .clk(clk), .rst(rst));

    dff WB_cntrl[1:0](.q({Val2RegOut, RegWriteOut}),  .d({Val2RegIn, RegWriteIn}), .clk(clk), .rst(rst));

    endmodule