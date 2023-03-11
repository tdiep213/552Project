// 65,536 word by 8 bit memory
module mem_mod(
    //Output(s)
    data_out,
    //Input(s)
    data_in,
    addr,
    enable,
    wr,
    clk,
    rst,
    createdump
);
    parameter MEM_DEPTH 65536;
    parameter MEM_WIDTH 8;
    parameter DATA_WIDTH 16;

    input wire[DATA_WIDTH - 1:0] data_in, addr;
    input wire enable, wr, clk, rst, createdump;
    output reg[DATA_WIDTH - 1:0] data_out;

    wire [MEM_DEPTH - 1:0] depth [MEM_WIDTH - 1:0];

    

endmodule