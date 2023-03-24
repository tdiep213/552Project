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


   wire[2:0] ImmSel;
   
   wire[15:0] Instr, PC, ImmExt, Rs;
   wire[15:0] Rt, Writeback;

   wire[15:0] ALUout;
   wire[15:0] MEMout;

   wire Ofl, zero, sign;

   //Control signals
   
   wire RegJmp, Halt, PcSel;  //FETCH
   wire LBI, Link, Iformat, RegWrite;   //DECODE
   wire ALUSel;               //EXECUTE
   wire MemEnable, MemWr;     //MEMORY
   wire Val2Reg;              //WRITEBACK

   /*-----FETCH-----*/

   fetch F(.Instr(Instr), .PC(PC), .Imm(ImmExt), .Rs(Rs), .RegJmp(RegJmp), .Halt(Halt), .PcSel(PcSel), .clk(clk), .rst(rst));

   /*-----DECODE-----*/

   decode D( .Reg1Data(Rs), .Reg2Data(Rt), .Instr(Instr), .Imm(ImmExt), .Writeback(Writeback),
             .PC(PC), .LBI(LBI), .Link(Link), .Iformat(Iformat), .en(RegWrite), .clk(clk), .rst(rst) );

   /*-----EXECUTE-----*/

   execute X(.out(ALUout), .Ofl(alu_ofl), .zero(alu_zero), .sign(alu_sign), .RsVal(Rs), .RtVal(Rt), .Imm(ImmExt), .ALUSel(ALUSel), .opcode(Instr[15:11]), .funct(Instr[1:0]));

   /*-----MEMORY-----*/
   
   memory M (.data_out(MEMout), .data_in(Rt), .addr(ALUout), .enable(MemEnable), .wr(MemWr), .createdump(), .clk(clk), .rst(rst));

   /*-----WRITEBACK-----*/
   wb W(.Writeback(Writeback), .ALUout(ALUout), .MEMout(MEMout), .Val2Reg(Val2Reg));


   /*-----CONTROL-----*/
   sign_ext EXT(.out(ImmExt), .err(), .in(Instr), .zero_ext(ImmSel));

   control CNTRL(
    //Output(s)
    .RegWrite(RegWrite), .Iformat(Iformat), .PcSel(PcSel), .RegJmp(RegJmp), .MemEnable(MemEnable), .MemWr(MemWr),
    .ALUcntrl(), .Val2Reg(Val2Reg), .ALUSel(ALUSel), .ImmSel(ImmSel), .Halt(Halt), .LinkReg(Link), .ctrlErr(ctrlErr),   
    //Input(s)
    .Instr(Instr[15:11]), .Zflag(alu_zero), .Sflag(alu_sign) );

endmodule // proc
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :0:
