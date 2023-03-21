/*
    CS/ECE 552 Spring '23
    Homework #1, Problem 2
    
    4 bit generate and propogate bit calculator
*/
`default_nettype none
module genProp4b(p, g, inA, inB);

    parameter N = 4;

    output wire [N-1:0] p, g;
    input wire [N-1: 0] inA, inB;

    // Calculate individual p's and g's

    and2 a0 (.out(g[0]), .in1(inA[0]), .in2(inB[0]));
    and2 a1 (.out(g[1]), .in1(inA[1]), .in2(inB[1]));
    and2 a2 (.out(g[2]), .in1(inA[2]), .in2(inB[2]));
    and2 a3 (.out(g[3]), .in1(inA[3]), .in2(inB[3]));
    or2  o0 (.out(p[0]), .in1(inA[0]), .in2(inB[0]));
    or2  o1 (.out(p[1]), .in1(inA[1]), .in2(inB[1]));
    or2  o2 (.out(p[2]), .in1(inA[2]), .in2(inB[2]));
    or2  o3 (.out(p[3]), .in1(inA[3]), .in2(inB[3]));
    
endmodule
`default_nettype wire
