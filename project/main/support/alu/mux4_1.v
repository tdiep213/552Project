/*
    CS/ECE 552 Spring '23
    Homework #1, Problem 1

    4-1 mux template
*/
`default_nettype none
module mux4_1(out, inputA, inputB, inputC, inputD, sel);
    output wire      out;
    input wire       inputA, inputB, inputC, inputD;
    input wire [1:0] sel;

    // YOUR CODE HERE
    wire m_out0, m_out1;
    wire and_m0, and_m1, not_sel1;

    mux2_1 m0 ( .out(m_out0), .inputA(inputA), .inputB(inputB), .sel(sel[0]) );
    mux2_1 m1 ( .out(m_out1), .inputA(inputC), .inputB(inputD), .sel(sel[0]) );

    not1 n0 ( .out(not_sel1), .in1(sel[1]));

    and2 a0  ( .out(and_m0), .in1(m_out0), .in2(not_sel1));
    and2 a1  ( .out(and_m1), .in1(m_out1), .in2(sel[1]));

    or2  or0 ( .out(out), .in1(and_m0), .in2(and_m1));
endmodule
`default_nettype wire
