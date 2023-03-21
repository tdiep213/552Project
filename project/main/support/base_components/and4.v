/*
    CS/ECE 552 Spring '23
    Homework #1, Problem 2

    4 input AND
*/
`default_nettype none
module and4 (out,in1,in2, in3, in4);
    output wire out;
    input wire in1,in2, in3, in4;
    wire sub;
    and3 a0 (.out(sub), .in1(in1), .in2(in2), .in3(in3));
    and2 a1 (.out(out), .in1(in4), .in2(sub));

endmodule
`default_nettype wire