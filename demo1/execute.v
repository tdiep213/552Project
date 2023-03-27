/*
   CS/ECE 552 Spring '22
  
   Filename        : execute.v
   Description     : This is the overall module for the execute stage of the processor.
*/
`default_nettype none
module execute (out, RsVal, RtVal, Imm, ALUSel, opcode, funct);
   // TODO: Your code here
   output wire[15:0] out;
   input wire[15:0] RsVal, RtVal, Imm;
   input wire ALUSel;
   input wire[4:0] opcode;
   input wire[1:0] funct;

   wire [15:0]RdVal;
   assign RdVal = ALUSel ? Imm : RtVal;

   alu ArithLogUnit(.out(out), .opcode(opcode), .funct(funct), .Ain(RsVal), .Bin(RdVal));
   
endmodule
`default_nettype wire
