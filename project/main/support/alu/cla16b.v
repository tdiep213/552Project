/*
    CS/ECE 552 Spring '23
    Homework #1, Problem 2
    
    a 16-bit CLA module
*/
`default_nettype none
module cla16b(sum, cOut, inA, inB, cIn);

    // declare constant for size of inputs, outputs (N)
    parameter   N = 16;

    output wire [N-1:0] sum;
    output wire         cOut;
    input wire [N-1: 0] inA, inB;
    input wire          cIn;

    // YOUR CODE HERE
    wire [3:0] P_out, G_out;
    wire [2:0] carries;
    // Dummy wires
    wire P16out, G16out;
    
    cla4b cla0 (.sum(sum[3:0]), .cOut(carries[0]), .P_out(P_out[0]), .G_out(G_out[0]), .inA(inA[3:0]), .inB(inB[3:0]), .cIn({cIn}));
    carrycalc_4b CC (.cOut({cOut,carries[2:0]}), .P_out(P16out), .G_out(G16out), .cIn({cIn}), .pIn(P_out[3:0]), .gIn(G_out[3:0]));


    cla4b cla [2:0] (.sum(sum[15:4]), .cOut({cOut,carries[2:1]}), .P_out(P_out[3:1]), .G_out(G_out[3:1]), .inA(inA[15:4]), .inB(inB[15:4]), .cIn({carries[2:0]}));
endmodule
`default_nettype wire
