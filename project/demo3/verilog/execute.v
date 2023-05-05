/*
   CS/ECE 552 Spring '22
  
   Filename        : execute.v
   Description     : This is the overall module for the execute stage of the processor.
*/
`default_nettype none
module execute (out, RsVal, RtVal, Imm, EX_FD_Rs, MEM_FD_Rs, EX_FD_Rt, MEM_FD_Rt, ALUSel, opcode, funct, Forwards);
   // TODO: Your code here
   output wire[15:0] out;
   input wire[15:0] RsVal, RtVal, Imm, EX_FD_Rs, MEM_FD_Rs, EX_FD_Rt, MEM_FD_Rt;
   input wire ALUSel;
   input wire[4:0] opcode;
   input wire[1:0] funct;
   input wire[3:0] Forwards;

   wire EXtoEX_FDRs, MEMtoEX_FDRs, EXtoEX_FDRt, MEMtoEX_FDRt;
   assign EXtoEX_FDRs  = Forwards[3];
   assign MEMtoEX_FDRs = Forwards[2];
   assign EXtoEX_FDRt  = Forwards[1];
   assign MEMtoEX_FDRt = Forwards[0];

   reg[15:0] RtTrue, RsTrue;

   always@* begin
      case({EXtoEX_FDRt, MEMtoEX_FDRt})
         2'b00: RtTrue = RtVal;
         2'b01: RtTrue = MEM_FD_Rt;
         2'b10: RtTrue = EX_FD_Rt;
         default: RtTrue = RtVal;
      endcase
   end

   wire [15:0]RdVal;
   assign RdVal = ALUSel ? Imm : RtTrue;   // Select Bin


   always@* begin
      case({EXtoEX_FDRs, MEMtoEX_FDRs})
         2'b00: RsTrue = RsVal;
         2'b01: RsTrue = MEM_FD_Rs;
         2'b10: RsTrue = EX_FD_Rs;
         default: RsTrue = RsVal;
      endcase
   end

   alu ArithLogUnit(.out(out), .opcode(opcode), .funct(funct), .Ain(RsTrue), .Bin(RdVal));
   
endmodule
`default_nettype wire
