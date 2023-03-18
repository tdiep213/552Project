/*
    CS/ECE 552 Spring '23
    Homework #1, Problem 1

    a 4-bit (quad) 4-1 Mux template
*/
`default_nettype none
module mux4_1_4b(out, inputA, inputB, inputC, inputD, sel);

    // parameter N for length of inputs and outputs (to use with larger inputs/outputs)
    parameter N = 4;

    output wire [N-1:0]  out;
    input wire [N-1:0]   inputA, inputB, inputC, inputD;
    input wire [1:0]     sel;

    // YOUR CODE HERE
    mux4_1 m0 (.out(out[0]), .inputA(inputA[0]), .inputB(inputB[0]), .inputC(inputC[0]), .inputD(inputD[0]), .sel(sel[1:0]));
    mux4_1 m1 (.out(out[1]), .inputA(inputA[1]), .inputB(inputB[1]), .inputC(inputC[1]), .inputD(inputD[1]), .sel(sel[1:0]));
    mux4_1 m2 (.out(out[2]), .inputA(inputA[2]), .inputB(inputB[2]), .inputC(inputC[2]), .inputD(inputD[2]), .sel(sel[1:0]));
    mux4_1 m3 (.out(out[3]), .inputA(inputA[3]), .inputB(inputB[3]), .inputC(inputC[3]), .inputD(inputD[3]), .sel(sel[1:0]));

endmodule
`default_nettype wire
