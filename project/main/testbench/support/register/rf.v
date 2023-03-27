/*
   CS/ECE 552, Spring '23
   Homework #3, Problem #1
  
   This module creates a 16-bit register.  It has 1 write port, 2 read
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

   parameter REG_WIDTH = 16;
   parameter REG_DEPTH = 8;

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

   wire  [REG_WIDTH - 1: 0] q [REG_DEPTH - 1: 0];
   wire [REG_WIDTH - 1: 0] d [REG_DEPTH - 1: 0];
   wire  [REG_WIDTH - 1: 0] in [REG_DEPTH - 1: 0];
   wire [REG_DEPTH - 1 : 0] err_array ;

   //
   assign in[0] = writeRegSel == 0 ? writeInData : q[0];
   assign in[1] = writeRegSel == 1 ? writeInData : q[1];
   assign in[2] = writeRegSel == 2 ? writeInData : q[2];
   assign in[3] = writeRegSel == 3 ? writeInData : q[3];
   assign in[4] = writeRegSel == 4 ? writeInData : q[4];
   assign in[5] = writeRegSel == 5 ? writeInData : q[5];
   assign in[6] = writeRegSel == 6 ? writeInData : q[6];
   assign in[7] = writeRegSel == 7 ? writeInData : q[7];

   // Loop q back into FF if write isn't enabled
   assign d[0] = writeEn ? in[0] : q[0];
   assign d[1] = writeEn ? in[1] : q[1];
   assign d[2] = writeEn ? in[2] : q[2];
   assign d[3] = writeEn ? in[3] : q[3];
   assign d[4] = writeEn ? in[4] : q[4];
   assign d[5] = writeEn ? in[5] : q[5];
   assign d[6] = writeEn ? in[6] : q[6];
   assign d[7] = writeEn ? in[7] : q[7];

   //FF array 
   dff_16 reg0 (.q(q[0]), .err(err_array[0]), .d(d[0]), .clk(clk), .rst(rst));
   dff_16 reg1 (.q(q[1]), .err(err_array[1]), .d(d[1]), .clk(clk), .rst(rst));
   dff_16 reg2 (.q(q[2]), .err(err_array[2]), .d(d[2]), .clk(clk), .rst(rst));
   dff_16 reg3 (.q(q[3]), .err(err_array[3]), .d(d[3]), .clk(clk), .rst(rst));
   dff_16 reg4 (.q(q[4]), .err(err_array[4]), .d(d[4]), .clk(clk), .rst(rst));
   dff_16 reg5 (.q(q[5]), .err(err_array[5]), .d(d[5]), .clk(clk), .rst(rst));
   dff_16 reg6 (.q(q[6]), .err(err_array[6]), .d(d[6]), .clk(clk), .rst(rst));
   dff_16 reg7 (.q(q[7]), .err(err_array[7]), .d(d[7]), .clk(clk), .rst(rst));

   //assign outputs
  assign read1OutData = q[read1RegSel];
  assign read2OutData = q[read2RegSel];

   assign err = |err_array;
   endmodule
`default_nettype wire
