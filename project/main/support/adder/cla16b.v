/*
    CS/ECE 552 Spring '23
    Homework #1, Problem 2
    
    a 16-bit CLA module
*/
`default_nettype none
module cla16b(sum, cOut, inA, inB, cIn);
    // declare constant for size of inputs, outputs (N)
    parameter   N = 16;

    output wire [15:0] sum;
    output wire         cOut;
    input wire [15:0] inA, inB;
    input wire          cIn;

	// YOUR CODE HERE
    wire[2:0] in;  
    


    /******** ReWrite to only depend on cIn********/
	cla4b U1(sum[3:0], in[0], inA[3:0], inB[3:0], cIn);
	cla4b U2(sum[7:4], in[1], inA[7:4], inB[7:4], in[0]);
	cla4b U3(sum[11:8], in[2], inA[11:8], inB[11:8], in[1]);
	cla4b U4(sum[15:12], cOut, inA[15:12], inB[15:12], in[2]);


endmodule
`default_nettype wire
