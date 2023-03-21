/*
    CS/ECE 552 Spring '23
    Homework #1, Problem 2

    5 input OR
*/
`default_nettype none
module or5 (out,in1,in2, in3, in4, in5);
    output wire out;
    input wire in1,in2, in3, in4, in5;
    wire sub;
    or3 o0 (.out(sub), .in1(in1), .in2(in2), .in3(in3));
    or3 o1 (.out(out), .in1(in4), .in2(in5), .in3(sub));

endmodule
`default_nettype wire
