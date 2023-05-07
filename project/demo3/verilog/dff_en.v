`default_nettype none
module dff_en(q, d, en, clk, rst);

    output wire        q;
    input wire         d, en;
    input wire         clk;
    input wire         rst;

  wire wr;
  assign wr = en ? d : q;
  dff FF(.q(q), .d(wr), .clk(clk), .rst(rst));
endmodule
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :0:
