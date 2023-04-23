/*
   CS/ECE 552, Spring '23
   Homework #3, Problem #1
  
   This module creates a 16-bit Register.

*/
`default_nettype none
module dff_16 (
            // Output
            q, err,
            // Inputs
            d, clk, rst
            );
    parameter REG_WIDTH = 16;

    output wire[REG_WIDTH - 1 : 0]    q;
    output wire err;

    input wire [REG_WIDTH - 1 : 0]     d;
    input wire     clk;
    input wire     rst;

    dff ff16[REG_WIDTH - 1 : 0](.q(q), .d(d), .clk(clk), .rst(rst));

   assign err = |(q === 1'bx) ;
endmodule
`default_nettype wire
