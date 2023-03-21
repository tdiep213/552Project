/*
    CS/ECE 552 Spring '23
    Homework #1, Problem 2

    5 input AND
*/
`default_nettype none
module and5 (out,in1,in2, in3, in4, in5);
    output wire out;
    input wire in1,in2, in3, in4, in5;
    wire sub;
    and3 a0 (.out(sub), .in1(in1), .in2(in2), .in3(in3));
    and3 a1 (.out(out), .in1(in4), .in2(in5), .in3(sub));

endmodule
`default_nettype wire
