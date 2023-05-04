/*
    CS/ECE 552 Spring '23
    Homework #1, Problem 2
    
    a 1-bit full adder
*/
`default_nettype none
module fullAdder1b(s, cOut, inA, inB, cIn);
    output wire s;
    output wire cOut;
    input  wire inA, inB;
    input  wire cIn;

    // YOUR CODE HERE
	wire x1, a1, a2;

	assign x1 = inA^inB;
    assign a1 = inA&inB;
    assign a2 = x1&cIn;

    assign cOut = a1|a2;
    assign s = x1^cIn;
	
	
endmodule
`default_nettype wire
