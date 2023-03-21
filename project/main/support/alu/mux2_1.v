/*
    CS/ECE 552 Spring '23
    Homework #1, Problem 1

    2-1 mux template
*/
`default_nettype none
module mux2_1(out, inputA, inputB, sel);
    output wire  out;
    input wire  inputA, inputB;
    input wire  sel;

    // YOUR CODE HERE
    wire not_sel, and_out_A, and_out_B;

    not1 n0 ( .out(not_sel), .in1(sel));

    and2 a0  ( .out(and_out_A), .in1(inputA), .in2(not_sel));
    and2 a1  ( .out(and_out_B), .in1(inputB), .in2(sel));
    // Y = (A*~sel) + (B*sel)
    or2  or0 ( .out(out), .in1(and_out_A), .in2(and_out_B));

endmodule
`default_nettype wire
