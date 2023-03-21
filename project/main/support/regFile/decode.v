/*
   CS/ECE 552, Spring '23
   Homework #3, Problem #1
  
   This module creates a 16-bit register file.  It has 1 write port, 2 read
   ports, 3 register select inputs, a write enable, a reset, and a clock
   input.  All register state changes occur on the rising edge of the
   clock. 
*/
`default_nettype none
module decode(pOut, pIn, en);

   output wire [7:0] pOut;
   input  wire [2:0] pIn;
   input  wire       en;

   wire [2:0] n_pIn;
   not1 nGates [2:0] (.out(n_pIn[2:0]), .in1(pIn[2:0]));
   /* 000  nnn
      001  nnp
      010  npn
      011  npp
      100  pnn
      101  pnp
      110  ppn
      111  ppp
      Need vectors for each column, which represent a combination of pIn[2:0] and n_pIn[2:0].
      each column is an input to the and gate that controls its base 10 pOut.
   */
   // routing wires for each of the and gates to make vectorizing easier
   wire [7:0] logStr0, logStr1, logStr2;
   assign logStr2 = {pIn[2],pIn[2],pIn[2],pIn[2],n_pIn[2],n_pIn[2],n_pIn[2],n_pIn[2]};
   assign logStr1 = {pIn[1],pIn[1],n_pIn[1],n_pIn[1],pIn[1],pIn[1],n_pIn[1],n_pIn[1]};
   assign logStr0 = {pIn[0],n_pIn[0],pIn[0],n_pIn[0],pIn[0],n_pIn[0],pIn[0],n_pIn[0]};

   and4 outGates [7:0] (.out(pOut[7:0]), .in1(en), .in2(logStr0[7:0]), .in3(logStr1[7:0]), .in4(logStr2[7:0]));

endmodule
`default_nettype wire