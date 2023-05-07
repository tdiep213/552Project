
`default_nettype none
module dff_16en(
            // Output
            q, err, en,
            // Inputs
            d, clk, rst
            );
    parameter REG_WIDTH = 16;
    input wire[15:0]  d;
    input wire en, clk, rst;
    output wire[15:0] q;
    output wire err;
   wire[15:0] wr;
   assign wr = en ? d : q;
   dff_16 FF(.q(q), .err(err), .d(wr), .clk(clk), .rst(rst));
endmodule
`default_nettype wire
