/*
    CS/ECE 552 Spring '23
    Homework #1, Problem 2
    
    a 4-bit Carry Calculator for CLAs
*/
`default_nettype none
module carrycalc_4b(cOut, P_out, G_out, cIn, pIn, gIn);

    // declare constant for size of inputs, outputs (N)
    parameter   N = 4;

    output wire [N-1:0] cOut;
    output wire P_out, G_out;
    input wire  [N-1:0] pIn, gIn;
    input wire          cIn;

    // Calculate c1
    wire p0c0;
    
    and2 a4 (.out(p0c0),    .in1(pIn[0]), .in2(cIn));
    or2  o4 (.out(cOut[0]), .in1(p0c0), .in2(gIn[0]));

    // Calculate c2
    wire p1p0c0, p1g0;
    and3 a5 (.out(p1p0c0),  .in1(pIn[1]), .in2(pIn[0]),   .in3(cIn));
    and2 a6 (.out(p1g0),    .in1(pIn[1]), .in2(gIn[0]));
    or3  o5 (.out(cOut[1]), .in1(gIn[1]), .in2(p1g0), .in3(p1p0c0));
    
    // Calculate c3
    wire p2p1p0c0, p2p1g0, p2g1;
    and4 a8 (.out(p2p1p0c0), .in1(pIn[2]), .in2(pIn[1]), .in3(pIn[0]), .in4(cIn));
    and3 a9 (.out(p2p1g0),   .in1(pIn[2]), .in2(pIn[1]), .in3(gIn[0]));
    and2 a10(.out(p2g1),     .in1(pIn[2]), .in2(gIn[1]));
    or4  o6 (.out(cOut[2]),  .in1(gIn[2]), .in2(p2g1), .in3(p2p1g0), .in4(p2p1p0c0));
    
    // Calculate c4
    wire p3p2p1p0c0, p3p2p1g0, p3p2g1, p3g2;
    and5 a11 (.out(p3p2p1p0c0), .in1(pIn[3]), .in2(pIn[2]), .in3(pIn[1]), .in4(pIn[0]), .in5(cIn));
    and4 a13 (.out(p3p2p1g0),   .in1(pIn[3]), .in2(pIn[2]), .in3(pIn[1]), .in4(gIn[0]));
    and3 a15 (.out(p3p2g1),     .in1(pIn[3]), .in2(pIn[2]), .in3(gIn[1]));
    and2 a16 (.out(p3g2),       .in1(pIn[3]), .in2(gIn[2]));
    or5  o8  (.out(cOut[3]),    .in1(gIn[3]), .in2(p3g2), .in3(p3p2g1), .in4(p3p2p1g0), .in5(p3p2p1p0c0));

    // Calculate overall P and G
    or4  o10 (.out(G_out), .in1(gIn[3]), .in2(p3g2), .in3(p3p2g1), .in4(p3p2p1g0));
    and4 a17 (.out(P_out), .in1(pIn[3]), .in2(pIn[2]), .in3(pIn[1]), .in4(pIn[0]));

endmodule
`default_nettype wire
