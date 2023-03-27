/*
   CS/ECE 552 Spring '22
  
   Filename        : fetch.v
   Description     : This is the module for the overall fetch stage of the processor.
*/
`default_nettype none
//PC + Instruction Memory
module fetch (Instr, PC, Imm, Rs, RegJmp, Halt, PcSel, clk, rst);
   // TODO: Your code here
   output wire[15:0] Instr, PC; 
   
   input wire[15:0] Imm, Rs;
   input wire RegJmp, Halt, PcSel;
   
   input wire clk, rst;

   wire[15:0] PcAddr;
   
   
   pc ProgCnt(.PcAddr(PcAddr),.PC(PC), .Imm(Imm),.Rs(Rs),.PcSel(PcSel),.RegJmp(RegJmp),.Halt(Halt),.clk(clk), .rst(rst));
   memory2c InstrMem(.data_out(Instr), .data_in(), .addr(PC), .enable(1'b1), .wr(1'b0), 
                     .createdump(), .clk(clk), .rst(rst));

endmodule
`default_nettype wire
