module reg8b(q, d, clk, rst);
    parameter REG_WIDTH = 8;
    input wire[REG_WIDTH - 1 : 0]  d;
    input wire clk, rst;
    output reg[REG_WIDTH - 1 : 0]  q;

    dff ff8[REG_WIDTH - 1 : 0](.q(q), .d(d), .clk(clk), .rst(rst));

endmodule