/*
   CS/ECE 552, Spring '23
   Homework #3, Problem #1
  
   This module creates a 16-bit register file.  It has 1 write port, 2 read
   ports, 3 register select inputs, a write enable, a reset, and a clock
   input.  All register state changes occur on the rising edge of the
   clock. 
*/
`default_nettype none
module rf (
           // Outputs
           read1OutData, read2OutData, err,
           // Inputs
           clk, rst, read1RegSel, read2RegSel, writeRegSel, writeInData, writeEn
           );
   parameter B = 2;     // Number of Bytes per reg
   parameter N = 8*B;   // Number of bits per reg
   // parameter FD = 8;    // File-Depth (number of registers)
   input wire         clk, rst;
   input wire  [2:0]  read1RegSel;
   input wire  [2:0]  read2RegSel;
   input wire  [2:0]  writeRegSel;
   input wire  [15:0] writeInData;
   input wire         writeEn;

   output wire [15:0] read1OutData;
   output wire [15:0] read2OutData;
   output wire        err;

   /* YOUR CODE HERE */
   wire [7:0] writeEnR;
   decode D0 (.pOut(writeEnR[7:0]), .pIn(writeRegSel[2:0]), .en(writeEn));

   // Register instantiation
   wire [N-1:0] R0Read, R1Read, R2Read, R3Read, R4Read, R5Read, R6Read, R7Read;  // Extend for number of registers
   regNbit R [7:0] (.writeData({8{writeInData[N-1:0]}}), 
                     .readData({R7Read[N-1:0], R6Read[N-1:0], R5Read[N-1:0], R4Read[N-1:0], R3Read[N-1:0], R2Read[N-1:0], R1Read[N-1:0], R0Read[N-1:0]}), 
                     .err(err),
                     .writeEn(writeEnR[7:0]), 
                     .clk(clk), 
                     .rst(rst));

   // Read Register Selector
   wire [N-1:0] read1Lower, read1Upper;
   mux4_1 read1SelLower [N-1:0] (.out(read1Lower[N-1:0]), .inputA(R0Read[N-1:0]), .inputB(R1Read[N-1:0]), .inputC(R2Read[N-1:0]), .inputD(R3Read[N-1:0]), .sel(read1RegSel[1:0]));
   mux4_1 read1SelUpper [N-1:0] (.out(read1Upper[N-1:0]), .inputA(R4Read[N-1:0]), .inputB(R5Read[N-1:0]), .inputC(R6Read[N-1:0]), .inputD(R7Read[N-1:0]), .sel(read1RegSel[1:0]));
   mux2_1 read1Mux      [N-1:0] (.out(read1OutData[N-1:0]), .inputA(read1Lower[N-1:0]), .inputB(read1Upper[N-1:0]), .sel(read1RegSel[2]));
   
   wire [N-1:0] read2Lower, read2Upper;
   mux4_1 read2SelLower [N-1:0] (.out(read2Lower[N-1:0]), .inputA(R0Read[N-1:0]), .inputB(R1Read[N-1:0]), .inputC(R2Read[N-1:0]), .inputD(R3Read[N-1:0]), .sel(read2RegSel[1:0]));
   mux4_1 read2SelUpper [N-1:0] (.out(read2Upper[N-1:0]), .inputA(R4Read[N-1:0]), .inputB(R5Read[N-1:0]), .inputC(R6Read[N-1:0]), .inputD(R7Read[N-1:0]), .sel(read2RegSel[1:0]));
   mux2_1 read2Mux      [N-1:0] (.out(read2OutData[N-1:0]), .inputA(read2Lower[N-1:0]), .inputB(read2Upper[N-1:0]), .sel(read2RegSel[2]));

   reg errCheck;
   assign err = errCheck;
// case statement as seen in: https://pages.cs.wisc.edu/~sinclair/courses/cs552/spring2023/handouts/misc/Verilog_cheat.pdf
// this is rough, I will look at better ways of doing this in the future.
   always @(writeEn)
      case(writeEn)
         1'b0: errCheck = 1'b0;
         1'b1: errCheck = 1'b0;   
         default: errCheck = 1'b1;
      endcase
   always @(writeInData[15:12])
      case(writeInData[15:12])
         4'h0: errCheck = 1'b0;
         4'h1: errCheck = 1'b0;
         4'h2: errCheck = 1'b0;
         4'h3: errCheck = 1'b0;
         4'h4: errCheck = 1'b0;
         4'h5: errCheck = 1'b0;
         4'h6: errCheck = 1'b0;
         4'h7: errCheck = 1'b0;
         4'h8: errCheck = 1'b0;
         4'h9: errCheck = 1'b0;
         4'ha: errCheck = 1'b0;
         4'hb: errCheck = 1'b0;
         4'hc: errCheck = 1'b0;
         4'hd: errCheck = 1'b0;
         4'he: errCheck = 1'b0;
         4'hf: errCheck = 1'b0;
         default: errCheck = 1'b1;
      endcase
   always @(writeInData[11:8])
      case(writeInData[11:8])
         4'h0: errCheck = 1'b0;
         4'h1: errCheck = 1'b0;
         4'h2: errCheck = 1'b0;
         4'h3: errCheck = 1'b0;
         4'h4: errCheck = 1'b0;
         4'h5: errCheck = 1'b0;
         4'h6: errCheck = 1'b0;
         4'h7: errCheck = 1'b0;
         4'h8: errCheck = 1'b0;
         4'h9: errCheck = 1'b0;
         4'ha: errCheck = 1'b0;
         4'hb: errCheck = 1'b0;
         4'hc: errCheck = 1'b0;
         4'hd: errCheck = 1'b0;
         4'he: errCheck = 1'b0;
         4'hf: errCheck = 1'b0;
         default: errCheck = 1'b1;
      endcase
   always @(writeInData[7:4])
      case(writeInData[7:4])
         4'h0: errCheck = 1'b0;
         4'h1: errCheck = 1'b0;
         4'h2: errCheck = 1'b0;
         4'h3: errCheck = 1'b0;
         4'h4: errCheck = 1'b0;
         4'h5: errCheck = 1'b0;
         4'h6: errCheck = 1'b0;
         4'h7: errCheck = 1'b0;
         4'h8: errCheck = 1'b0;
         4'h9: errCheck = 1'b0;
         4'ha: errCheck = 1'b0;
         4'hb: errCheck = 1'b0;
         4'hc: errCheck = 1'b0;
         4'hd: errCheck = 1'b0;
         4'he: errCheck = 1'b0;
         4'hf: errCheck = 1'b0;
         default: errCheck = 1'b1;
      endcase
   always @(writeInData[3:0])
      case(writeInData[3:0])
         4'h0: errCheck = 1'b0;
         4'h1: errCheck = 1'b0;
         4'h2: errCheck = 1'b0;
         4'h3: errCheck = 1'b0;
         4'h4: errCheck = 1'b0;
         4'h5: errCheck = 1'b0;
         4'h6: errCheck = 1'b0;
         4'h7: errCheck = 1'b0;
         4'h8: errCheck = 1'b0;
         4'h9: errCheck = 1'b0;
         4'ha: errCheck = 1'b0;
         4'hb: errCheck = 1'b0;
         4'hc: errCheck = 1'b0;
         4'hd: errCheck = 1'b0;
         4'he: errCheck = 1'b0;
         4'hf: errCheck = 1'b0;
         default: errCheck = 1'b1;
      endcase

endmodule
`default_nettype wire
