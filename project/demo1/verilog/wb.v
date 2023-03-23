/*
   CS/ECE 552 Spring '22
  
   Filename        : wb.v
   Description     : This is the module for the overall Write Back stage of the processor.
*/
`default_nettype none
module wb (Writeback, ALUout, MEMout, Val2Reg);
   // TODO: Your code here
   output wire[15:0] Writeback;
   input wire[15:0] ALUout, MEMout;
   input wire Val2Reg;

   assign Writeback = Val2Reg ? MEMout : ALUout; 
   
endmodule
`default_nettype wire
