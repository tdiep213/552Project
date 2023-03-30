module  mem_wb(
        /*-----PIPELINE OUT-----*/
        MemOutOut, ALUoutOut,                         //Data out
        Val2RegOut,                                   //Control out (Writeback)

        /*-----PIPELINE IN-----*/
        MemOutIn, ALUoutIn,                           //Data in
        Val2RegIn,                                    //Control in (Writeback)

        clk, rst
    );
        /*-----PIPELINE OUT-----*/
        output wire MemOutOut, ALUoutOut;              //Data out
        output wire Val2RegOut;                        //Control out (Writeback)

        /*-----PIPELINE IN-----*/
        input wire MemOutIn, ALUoutIn;                //Data in
        input wire Val2RegIn;                         //Control in (Writeback)

        input wire clk, rst;

    dff_16 DATA[1:0](.q({ MemOutOut, ALUoutOut}), .err(), .d({MemOutIn, ALUoutIn}), .clk(clk), .rst(rst));

    dff_16 WB_cntrl(.q(Val2RegOut), .err(), .d(Val2RegIn), .clk(clk), .rst(rst));

    endmodule