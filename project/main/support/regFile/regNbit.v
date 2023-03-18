/*
   CS/ECE 552, Spring '23
   Homework #3, Problem #1
  
   This module creates a 8*B bits size register
*/
`default_nettype none
module regNbit(writeData, readData, err, writeEn, clk, rst);
   parameter B = 2;      // Number of Bytes
   parameter N = 8 * B;  // Number of bits

   output wire  [N-1:0] readData;
   output wire  err;

   input wire [N-1:0] writeData;
   input wire writeEn, clk, rst;
             

   wire [N-1:0] enabledIn;
   
   // Q from D-flip-flop is routed back to input of a mux whose select bit is WriteEn, and the other input is write data
   mux2_1 WriteEnable [N-1:0] (.out(enabledIn), .inputA(readData[N-1:0]), .inputB(writeData[N-1:0]), .sel(writeEn));
   //  connect signals from all D Flip-Flops into N-bit buslines that act as the I/o.
   dff DFF [N-1:0] (.q(readData[N-1:0]), .d(enabledIn[N-1:0]), .clk(clk), .rst(rst));
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
   always @(writeData[15:12])
      case(writeData[15:12])
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
   always @(writeData[11:8])
      case(writeData[11:8])
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
   always @(writeData[7:4])
      case(writeData[7:4])
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
   always @(writeData[3:0])
      case(writeData[3:0])
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
