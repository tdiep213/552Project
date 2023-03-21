`default_nettype none
module TwosComp(comp, in);
    output wire[15:0] comp;
    input wire[15:0] in;

    wire[15:0] inv;

    assign inv = ~in;
    cla16b inc(.sum(comp), .cOut(), .inA(inv), .inB(1), .cIn());

endmodule
`default_nettype wire
