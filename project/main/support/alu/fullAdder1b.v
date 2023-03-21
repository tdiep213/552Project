/*
    CS/ECE 552 Spring '23
    Homework #1, Problem 2
    
    a 1-bit full adder
*/
`default_nettype none
module fullAdder1b(s, cOut, inA, inB, cIn);
    output wire s;
    output wire cOut;
    input  wire inA, inB;
    input  wire cIn;

    // YOUR CODE HERE
    wire And_out0, And_out1, Xor_out0;

    // Level 1
    and2 a0 (.out(And_out0), .in1(inA), .in2(inB));
    xor2 x0 (.out(Xor_out0), .in1(inA), .in2(inB));

    // Level 2
    and2 a1 (.out(And_out1), .in1(cIn), .in2(Xor_out0));
    xor2 x1 (.out(s), .in1(cIn), .in2(Xor_out0));

    // Level 3
    or2 or0 (.out(cOut), .in1(And_out0), .in2(And_out1));
endmodule
`default_nettype wire
