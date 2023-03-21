/*
    CS/ECE 552 Spring '23
    Homework #1, Problem 1

    Overflow detector for signed CLA inputs/outputs
*/
`default_nettype none
module OFL_Signed (out, inOR, inAND, sum);
    output wire out;
    input wire inOR, inAND, sum;
    
    wire not_OR, not_Sum, OFL_N, OFL_P;
    not1 notOR  (.out(not_OR), .in1(inOR));
    not1 notSum (.out(not_Sum), .in1(sum));

    and2 AndN   (.out(OFL_N), .in1(inAND), .in2(not_Sum));
    and2 AndP   (.out(OFL_P), .in1(not_OR), .in2(sum));

    or2  OrOFL  (.out(out), .in1(OFL_N), .in2(OFL_P));


endmodule
`default_nettype wire
