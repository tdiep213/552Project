/*
    CS/ECE 552 Spring '23
    Homework #1, Problem 1

    a 16-bit (quad) 4-1 Mux
*/
`default_nettype none
module mux4_1_16b(out, inputA, inputB, inputC, inputD, sel);

    // parameter N for length of inputs and outputs (to use with larger inputs/outputs)
    parameter N = 16;

    output wire [N-1:0]  out;
    input wire [N-1:0]   inputA, inputB, inputC, inputD;
    input wire [1:0]     sel;

    // YOUR CODE HERE
    mux4_1_4b Mux [3:0] (.out(out[15:0]), .inputA(inputA[15:0]), .inputB(inputB[15:0]), .inputC(inputC[15:0]), .inputD(inputD[15:0]), .sel(sel[1:0]));


endmodule
`default_nettype wire
