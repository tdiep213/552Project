/*
    CS/ECE 552 Spring '23
    Homework #1, Problem 1

    a 16-bit (quad) 2-1 Mux
*/
`default_nettype none
module mux2_1_16b(out, inputA, inputB, sel);

    // parameter N for length of inputs and outputs (to use with larger inputs/outputs)
    parameter N = 16;

    output wire [N-1:0]  out;
    input wire [N-1:0]   inputA, inputB;
    input wire           sel;

    // YOUR CODE HERE
    mux2_1 Mux [15:0] (.out(out[15:0]), .inputA(inputA[15:0]), .inputB(inputB[15:0]), .sel(sel));


endmodule
`default_nettype wire