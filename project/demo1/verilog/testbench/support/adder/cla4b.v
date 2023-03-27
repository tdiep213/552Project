/*
    CS/ECE 552 Spring '23
    Homework #1, Problem 2
    
    a 4-bit CLA module
*/
`default_nettype none
module cla4b(sum, cOut, inA, inB, cIn);

    // declare constant for size of inputs, outputs (N)
    parameter   N = 4;

    output wire [N-1:0] sum;
    output wire         cOut;
    input wire [N-1: 0] inA, inB;
    input wire          cIn;

    // YOUR CODE HERE
	wire[N-1:0] cout4, cin4, g, p, c;
	
    assign g = inA & inB;
    assign p = inA | inB;
    //and2 U1[N-1:0](g, inA, inB);
	//or2 U2[N-1:0](p, inA, inB);


/******** ReWrite so it only depends on cin[0] *********/
	assign cin4[0] = cIn;
	assign cin4[1] = g[0] | (cin4[0] & p[0]);


	assign cin4[2] = g[1] | (cin4[1] & p[1]);


	assign cin4[3] = g[2] | (cin4[2] & p[2]);

	assign cOut = g[3] | (cin4[3] & p[3]);



	fullAdder1b fA1b[N-1:0](sum, cout4, inA, inB, cin4);

endmodule
`default_nettype wire
