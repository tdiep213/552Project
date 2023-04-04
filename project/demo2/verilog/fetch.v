/*
   CS/ECE 552 Spring '22
  
   Filename        : fetch.v
   Description     : This is the module for the overall fetch stage of the processor.
*/
`default_nettype none
//PC + Instruction Memory
module fetch (
   // outputs
   Instr_C, 
   PC, 
   Imm, 
   Rs, 
   RegWrite, 
   DestRegSel,
   MemEnable, 
   MemWr,
   Val2Reg, 
   ALUSel, 
   ImmSel,
   LinkReg, 
   ctrlErr, 
   // inputs
   RegJmp, 
   Halt, 
   PcSel, 
   SIIC, 
   clk, 
   rst);
   // TODO: Your code here
   output wire[15:0] Instr_C, PC; 
   output wire RegWrite, MemEnable, 
               MemWr, Val2Reg, ctrlErr, ALUSel;

   output wire [1:0] LinkReg, DestRegSel;
   output wire [2:0] ImmSel;
   input wire[15:0] Imm, Rs;
   input wire RegJmp, Halt, PcSel, SIIC;
   
   input wire clk, rst;

   wire[15:0] PcAddr, Instr;
   
   
   pc ProgCnt(.PcAddr(PcAddr),.PC(PC), .Imm(Imm),.Rs(Rs),.PcSel(PcSel),.RegJmp(RegJmp),.Halt(Halt), .SIIC(SIIC), .clk(clk), .rst(rst));
   memory2c InstrMem(.data_out(Instr), .data_in(), .addr(PC), .enable(1'b1), .wr(1'b0), 
                     .createdump(), .clk(clk), .rst(rst));

   assign sign = Rs[15];
   assign zero = &(Rs == 16'h0000);

    control CNTRL(
//Output(s)
    .RegWrite(RegWrite), 
    .DestRegSel(DestRegSel),
    .PcSel(PcSel), 
    .RegJmp(RegJmp), 
    .MemEnable(MemEnable), 
    .MemWr(MemWr),
    .ALUcntrl(Instr_C[15:11]),
    .Val2Reg(Val2Reg), 
    .ALUSel(ALUSel), 
    .ImmSel(ImmSel), 
    .Halt(Halt), 
    .LinkReg(LinkReg), 
    .ctrlErr(ctrlErr),
    .SIIC(SIIC),   
//Input(s)
    .Instr(Instr[15:11]), 
    .Zflag(zero), 
    .Sflag(sign));

    assign Instr_C[10:0] = Instr[10:0];

endmodule
`default_nettype wire
