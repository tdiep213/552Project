/*
   CS/ECE 552, Spring '23
   Homework #3, Problem #2
  
   This module creates a wrapper around the 8x16b register file, to do
   do the bypassing logic for RF bypassing.
*/
`default_nettype none
module rf_bypass (
                  // Outputs
                  read1OutData, read2OutData, err,
                  // Inputs
                  clk, rst, read1RegSel, read2RegSel, writeRegSel, writeInData, writeEn
                  );

   input wire       clk, rst;
   input wire [2:0] read1RegSel;
   input wire [2:0] read2RegSel;
   input wire [2:0] writeRegSel;
   input wire [15:0] writeInData;
   input wire        writeEn;

   output wire [15:0] read1OutData;
   output wire [15:0] read2OutData;
   output wire        err;

   /* YOUR CODE HERE */

   wire [15:0] out1, out2;

   rf rf0(  .read1OutData(out1), .read2OutData(out2), .err(err), .clk(clk), .rst(rst), 
         .read1RegSel(read1RegSel), .read2RegSel(read2RegSel), .writeRegSel(writeRegSel), 
         .writeInData(writeInData), .writeEn(writeEn) );


   assign read1OutData = (read1RegSel == writeRegSel) & writeEn ? writeInData : out1;
   assign read2OutData = (read2RegSel == writeRegSel) & writeEn ? writeInData : out2;
   

endmodule
`default_nettype wire
