module if_id(InstrOut, ImmExtOut, PcOut, InstrIn, ImmExtIn, PcIn, clk, rst,
        LinkRegOut, WriteRegAddrOut, RegWriteOut, b_flagOut, j_flagOut,RegJmpOut, //Decode control
        LinkRegIn, WriteRegAddrIn, RegWriteIn, b_flagIn, j_flagIn,RegJmpIn,
        ALUSelOut, ForwardsOut,//Execute control
        ALUSelIn, ForwardsIn,
        MemEnableOut, MemWrOut, HaltOut, // Memory control
        MemEnableIn, MemWrIn, HaltIn,
        Val2RegOut, // Writeback control
        Val2RegIn,
        branchTaken, instr_stall, mem_stall, fetch_done

);
    output wire[15:0] InstrOut, ImmExtOut, PcOut;
    
    input wire[15:0] InstrIn, ImmExtIn, PcIn;

    input wire[1:0] LinkRegIn;
    input wire[2:0] WriteRegAddrIn;
    input wire[5:0] ForwardsIn;
    input wire RegWriteIn, b_flagIn, j_flagIn, RegJmpIn;                          //DECODE
    input wire ALUSelIn;                            //EXECUTE
    input wire MemEnableIn, MemWrIn, HaltIn;        //MEMORY
    input wire Val2RegIn;                           //Writeback

    input wire branchTaken;                         //Branch Pred
    input wire instr_stall, mem_stall;
    input wire fetch_done;

    output wire[1:0] LinkRegOut;
    output wire[2:0] WriteRegAddrOut;
    output wire[5:0] ForwardsOut;
    output wire  RegWriteOut, b_flagOut, j_flagOut, RegJmpOut; //Decode control
    output wire ALUSelOut; //Execute control
    output wire MemEnableOut, MemWrOut, HaltOut; // Memory control
    output wire Val2RegOut; // Writeback control


    input wire clk, rst;
    wire[15:0] Instrc;
    wire en;
    assign en = ~((instr_stall | mem_stall));
    // wire clk_en, clk_cntrl;
    // dff CLK_CNTRL(.q(clk_cntrl), .d((instr_stall | mem_stall) & ~fetch_done), .clk(clk), .rst(rst));
    // assign clk_en = clk & ~clk_cntrl;


    dff_16en Instruction(.q(Instrc), .en(en), .err(), .d(InstrIn), .clk(clk), .rst(rst));
    dff_16en Immediate(.q(ImmExtOut), .en(en), .err(), .d(ImmExtIn), .clk(clk), .rst(rst));
    dff_16en ProgCnt(.q(PcOut),.en(en), .err(), .d(PcIn), .clk(clk), .rst(rst));
    
    assign InstrOut = (branchTaken|instr_stall) ? 16'h0800 : Instrc; // Culls Instruction if branch taken 

    wire[8:0] ID_cntrl_array;
    wire[6:0] EX_cntrl_array;
    wire[2:0] MEM_cntrl_array;

    //LMAO, Wasn't expecting that to work at 1:48am 
    assign {LinkRegOut, WriteRegAddrOut, RegWriteOut, b_flagOut, j_flagOut, RegJmpOut} = branchTaken ? 9'h00 : ID_cntrl_array;
    assign {ALUSelOut, ForwardsOut} = branchTaken ? 7'h00 : EX_cntrl_array;
    assign {MemEnableOut, MemWrOut, HaltOut} = branchTaken ? 3'h0 : MEM_cntrl_array;
    
    dff_en ID_cntrl[8:0](.q(ID_cntrl_array),.en(en),
                      .d({LinkRegIn, WriteRegAddrIn, RegWriteIn, b_flagIn, j_flagIn, RegJmpIn}), .clk(clk) , .rst(rst));
    
    dff_en EX_cntrl[6:0](.q(EX_cntrl_array),.en(en),  .d({ALUSelIn, ForwardsIn}), .clk(clk), .rst(rst));
    
    dff_en MEM_cntrl[2:0](.q(MEM_cntrl_array),.en(en),  .d({MemEnableIn, MemWrIn, HaltIn}), .clk(clk), .rst(rst));
    
    dff_en WB_cntrl(.q(Val2RegOut),.en(en),  .d(Val2RegIn), .clk(clk), .rst(rst));

    // (.q(),  .d(), .clk(clk_en), .rst(rst));

endmodule