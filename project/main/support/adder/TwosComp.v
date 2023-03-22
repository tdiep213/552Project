`default_nettype none
module TwosComp(out, in);
    output wire[15:0] out;
    input wire[15:0] in;

    wire[15:0] inv;
    wire zero;

    assign zero = 0;
    assign inv = ~in;

    cla16b inc(.sum(out), .cOut(), .inA(inv), .inB(1), .cIn(zero));

endmodule
`default_nettype wire
