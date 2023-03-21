/*
    CS/ECE 552 Spring '23
    Homework #1, Problem 2
    
    a 4-bit CLA module
*/
`default_nettype none
module cla4b(sum, cOut, P_out, G_out, inA, inB, cIn);

    // declare constant for size of inputs, outputs (N)
    parameter   N = 4;

    output wire [N-1:0] sum;
    output wire         cOut, P_out, G_out;
    input wire [N-1: 0] inA, inB;
    input wire          cIn;

    // YOUR CODE HERE
    wire [3:0] p_inner, g_inner, Cdump;
    wire [2:0] carries;
    
    genProp4b GP0 (.p(p_inner[3:0]), .g(g_inner[3:0]), .inA(inA[3:0]), .inB(inB[3:0]));
    carrycalc_4b CC0 (.cOut({cOut,carries[2:0]}), .P_out(P_out), .G_out(G_out), .cIn(cIn), .pIn(p_inner[3:0]), .gIn(g_inner[3:0]));

    fullAdder1b FA [3:0] (.s(sum[3:0]), .cOut(Cdump[3:0]), .inA(inA[3:0]), .inB(inB[3:0]), .cIn({carries[2:0],cIn}));


endmodule
`default_nettype wire
