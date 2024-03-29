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

   wire zero, sign;

   //Control signals
   wire[4:0] ALUcntrl;
   wire RegJmp, Halt, PcSel;  //FETCH
   wire RegWrite;   //DECODE
   wire[1:0] LinkReg, DestRegSel;
   wire SIIC;

    wire[15:0] EPC, EPC_D;

   wire ALUSel;               //EXECUTE
   wire MemEnable, MemWr;     //MEMORY
   wire Val2Reg;              //WRITEBACK
   wire ctrlErr, ext_err;     //ERRORs

   /*-----FETCH-----*/

   fetch F(.Instr(Instr), .PC(PC), .Imm(ImmExt), .Rs(Rs), .RegJmp(RegJmp), .Halt(Halt), .PcSel(PcSel), .SIIC(SIIC), .clk(clk), .rst(rst));

   /*-----DECODE-----*/

   decode D( .Reg1Data(Rs), .Reg2Data(Rt), .Instr(Instr), .Imm(ImmExt), .Writeback(Writeback),
             .PC(PC), .LBI(LinkReg[0]), .Link(LinkReg[1]), .DestRegSel(DestRegSel), .en(RegWrite), .clk(clk), .rst(rst) );

   /*-----EXECUTE-----*/

   execute X(.out(ALUout), .RsVal(Rs), .RtVal(Rt), .Imm(ImmExt), .ALUSel(ALUSel), .opcode(Instr[15:11]), .funct(Instr[1:0]));

   /*-----MEMORY-----*/
   
    memory M (.data_out(MEMout), .data_in(Rt), .addr(ALUout), .enable(MemEnable), .wr(MemWr), .createdump(), .Halt(Halt), .clk(clk), .rst(rst));

    /*-----WRITEBACK-----*/
    wb W(.Writeback(Writeback), .ALUout(ALUout), .MEMout(MEMout), .Val2Reg(Val2Reg));


    /*-----CONTROL-----*/
    sign_ext EXT(.out(ImmExt), .err(ext_err), .in(Instr), .zero_ext(ImmSel));

    assign sign = Rs[15];
    assign zero = &(Rs == 16'h0000);

    control CNTRL(
    //Output(s)
    .RegWrite(RegWrite), .DestRegSel(DestRegSel), .PcSel(PcSel), .RegJmp(RegJmp), .MemEnable(MemEnable), .MemWr(MemWr),
    .ALUcntrl(ALUcntrl), .Val2Reg(Val2Reg), .ALUSel(ALUSel), .ImmSel(ImmSel), .Halt(Halt), .LinkReg(LinkReg), .ctrlErr(ctrlErr),
    .SIIC(SIIC),   
    //Input(s)
    .Instr(Instr[15:11]), .Zflag(zero), .Sflag(sign));

    always@* begin
        case({ctrlErr, ext_err})
	    default: err =0; //ctrlErr | ext_err;
        endcase
    end

    assign EPC_D = SIIC ? PC : EPC;
    dff_16 EPC_REG(.q(EPC), .err(), .d(EPC_D), .clk(clk), .rst(rst));

endmodule // proc
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :0:
