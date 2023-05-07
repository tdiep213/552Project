    /*
    CS/ECE 552 Spring '22

    Filename        : fetch.v
    Description     : This is the module for the overall fetch stage of the processor.
    */
`default_nettype none
    //PC + Instruction Memory
module fetch (
   // outputs
   Instr_C, PC, 
   WriteRegAddr,
   RegWrite, Val2Reg, Link, LBI, // Register Ctrl signals
   ALUSel, ImmSel,               // Execute ctrl signals
   MemEnable, MemWr,             // mem ctrl signals
   b_flag, j_flag, RegJmp,       // branch ctrl signals
   Halt, ctrlErr, Forwards,       // Special ctrl signals
   instr_stall,
   // inputs
   mem_stall,
   BrnchAddr,
   nextPC,
   Imm, 
   Rs,     jmpPC,
   SIIC,
   PcSel, branchTaken, ID_RegJmp,
   clk, 
   rst);
   // TODO: Your code here
   output wire[15:0] Instr_C, PC; 
   output wire RegWrite, MemEnable, 
               MemWr, Val2Reg, ctrlErr, ALUSel, b_flag, j_flag;

   output reg [2:0] WriteRegAddr;
   output wire [2:0] ImmSel;
   output wire [5:0] Forwards;
   output wire RegJmp, Link, LBI, Halt, SIIC;

   output wire instr_stall;

   input wire[15:0] Imm, Rs, jmpPC, nextPC;
   input wire[15:0] BrnchAddr;
   input wire PcSel, branchTaken, ID_RegJmp;
   input wire mem_stall;
   input wire clk, rst;

   wire[15:0] PcAddr, Instr;
   wire [15:0] EX_Rs, MEM_Rs, WB_Rs;
   wire[15:0] Instr_B;
   wire[1:0] DestRegSel;
   wire HazNOP, PCStall, valid_n, PCStall_prev, PCStall_now, HazNOP_prev;

   wire [1:0] ChkRegSel;
   reg [2:0] ChkRegAddr;
   wire[15:0] prevPC;
   

   // pc ProgCnt(.PC(PC), .prevPC(prevPC), .newAddr(nextPC), .PcStall(PCStall), .clk(clk), .rst(rst));
   pc ProgCnt(.PC(PC), .Rs(Rs), .Imm(Imm), .PcStall(PCStall), .RegJmp(RegJmp), .PCSel(PcSel), .Halt(Halt), .clk(clk), .rst(rst));
   // NOTE! Replaced ID_RegJmp with RegJmp resolved 10 jump errors, so I'm leaving it alone for now. Jump bug resolution is still underway.

   memory2c InstrMem(.data_out(Instr), 
                     .data_in(), 
                     .addr(PC), 
                     .enable(1'b1), .wr(1'b0), 
                     .createdump(), .clk(clk), .rst(rst));

   
   wire cacheRD;

   assign instr_stall = 1'b0;

   // dff CACHE_RD(.q(cacheRD), .d(1'd1), .clk(clk), .rst(rst));
   // mem_system InstrMemCache(
   //                   // Outputs
   //                   .DataOut(Instr), 
   //                   .Done(), 
   //                   .Stall(instr_stall), 
   //                   .CacheHit(),
   //                   .err(),
   //                   // Inputs
   //                   .Addr(PC), 
   //                   .DataIn(), 
   //                   .Rd(1'b1;), 
   //                   .Wr(1'b0), 
   //                   .createdump(), 
   //                   .clk(clk), .rst(rst)
   // );

   always@* begin
      case(DestRegSel)
         2'b00: WriteRegAddr = Instr_C[10:8];   // Rs
         2'b01: WriteRegAddr = Instr_C[4:2];    // Rd-R
         2'b10: WriteRegAddr = 3'b111;           // R7
         2'b11: WriteRegAddr = Instr_C[7:5];    // Rd-I
         default: WriteRegAddr = Instr_C[4:2];
      endcase
   end

   //assign HazDet_Instr = PCStall_prev ? 16'h0800 : Instr;
   HazDet HDU( .NOP(HazNOP), .PcStall(PCStall), .Forwards(Forwards), 
               .valid_n(valid_n), .MemEnable(MemEnable), 
               .Rd(ChkRegAddr), .Imm(Imm), .Reg1Data(Rs), 
               .Instr(Instr), 
               .branchTaken(branchTaken),
               .clk(clk), .rst(rst));

   // This is the stuff that got things moving again, your crying dff was a good lead//
   assign Instr_B = (HazNOP|instr_stall) ? 16'h0800 : Instr;
   assign PCStall_now = (HazNOP & PCStall);
    
   dff StallDFF(.q(PCStall_prev), .d(PCStall_now), .clk(clk), .rst(rst));
   dff NOPDFF(.q(HazNOP_prev),  .d(HazNOP),      .clk(clk), .rst(rst));
    
   //===============================================================//
   
   dff_16 EX_RS( .q(EX_Rs),  .err(), .d(Rs),     .clk(clk), .rst(rst));
   dff_16 MEM_RS(.q(MEM_Rs), .err(), .d(EX_Rs),  .clk(clk), .rst(rst));
   dff_16 WB_RS( .q(WB_Rs),  .err(), .d(MEM_Rs), .clk(clk), .rst(rst));


   control CNTRL(
   //Output(s)
   .RegWrite(RegWrite), 
   .DestRegSel(DestRegSel),
   .PcSel(), 
   .RegJmp(RegJmp), 
   .MemEnable(MemEnable), 
   .MemWr(MemWr),
   .ALUcntrl(Instr_C[15:11]),
   .Val2Reg(Val2Reg), 
   .ALUSel(ALUSel), 
   .ImmSel(ImmSel), 
   .Halt(Halt), 
   .Link(Link), 
   .LBI(LBI),
   .ctrlErr(ctrlErr),
   .SIIC(SIIC),
   .b_flag(b_flag),
   .valid_n(valid_n),
   .j_flag(j_flag),   
   //Input(s)
   .Instr(Instr_B[15:11]));

   assign Instr_C[10:0] = Instr_B[10:0];
   

   always@* begin
      case(ChkRegSel)
         2'b00: ChkRegAddr = Instr[10:8];   // Rs
         2'b01: ChkRegAddr = Instr[4:2];    // Rd-R
         2'b10: ChkRegAddr = 3'b111;           // R7
         2'b11: ChkRegAddr = Instr[7:5];    // Rd-I
         default: ChkRegAddr = Instr[4:2];
      endcase
    end

   wire valid;
   control chk(
    //Output(s)
    .RegWrite(), 
    .DestRegSel(ChkRegSel),
    .PcSel(), 
    .RegJmp(), 
    .MemEnable(), 
    .MemWr(),
    .ALUcntrl(),
    .Val2Reg(), 
    .ALUSel(), 
    .ImmSel(), 
    .Halt(), 
    .Link(), 
    .ctrlErr(),
    .LBI(),
    .SIIC(),
    .b_flag(),
    .valid_n(valid),
    .j_flag(),   
    //Input(s)
    .Instr(Instr[15:11]));
   // assign valid_n = valid & ~HazNOP;

endmodule
`default_nettype wire
