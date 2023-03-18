/*
    CS/ECE 552 Spring '23
    Homework #1, Problem 1

    Calculates whether the input is zero.
*/
`default_nettype none
module ZeroDetectOR (out, in1);
    output wire out;
    input wire [15:0] in1;
    
    wire [7:0] OR_Out1;
    wire [3:0] OR_Out2;
    wire [1:0] OR_Out3;

    or2 OR_1 [7:0] (.out(OR_Out1[7:0]), .in1(in1[15:8]), .in2(in1[7:0]));
    or2 OR_2 [3:0] (.out(OR_Out2[3:0]), .in1(OR_Out1[7:4]), .in2(OR_Out1[3:0]));
    or2 OR_3 [1:0] (.out(OR_Out3), .in1(OR_Out2[3:2]), .in2(OR_Out2[1:0]));
    nor2 ZeroFlip (.out(out), .in1(OR_Out3[1]), .in2(OR_Out3[0]));

endmodule
`default_nettype wire