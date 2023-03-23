/* $Author: sinclair $ */
/* $LastChangedDate: 2020-02-09 17:03:45 -0600 (Sun, 09 Feb 2020) $ */
/* $Rev: 46 $ */
`default_nettype none
module proc (/*AUTOARG*/
   // Outputs
   err, 
   // Inputs
   clk, rst
   );

   input wire clk;
   input wire rst;

   output reg err;

   // None of the above lines can be modified

   // OR all the err ouputs for every sub-module and assign it as this
   // err output
   
   // As desribed in the homeworks, use the err signal to trap corner
   // cases that you think are illegal in your statemachines
   
   
   /* your code here -- should include instantiations of fetch, decode, execute, mem and wb modules */
   
   wire[15:0] Instr, PC, ImmExt, Rs;
   wire RegJmp, Halt, PcSel;

   fetch (.Instr(Instr), .PC(PC), .Imm(ImmExt), .Rs(Rs), .RegJmp(RegJmp), .Halt(Halt), .PcSel(PcSel), .clk(clk), .rst(rst));

   wire[15:0] Rt, Writeback;
   wire LBI, Link, Iformat; 
   decode ( .Reg1Data(Rs), .Reg2Data(Rt), .Instr(Instr), .Imm(ImmExt), .Writeback(Writeback) .PC(PC), .LBI(LBI), .Link(Link), .Iformat(Iformat), .clk(clk), .rst(rst) );

   wire[15:0] out;
   wire ALUSel;
   execute (.out(out), .RsVal(Rs), .RtVal(Rt), .Imm(ImmExt), .ALUSel(ALUSel), .opcode(Instr[15:11]), .funct(Instr[1:0]));

   execute
endmodule // proc
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :0:
