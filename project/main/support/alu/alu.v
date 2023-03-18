/*
    CS/ECE 552 Spring '23
    Homework #2, Problem 2

    A multi-bit ALU module (defaults to 16-bit). It is designed to choose
    the correct operation to perform on 2 multi-bit numbers from rotate
    left, shift left, shift right arithmetic, shift right logical, add,
    or, xor, & and.  Upon doing this, it should output the multi-bit result
    of the operation, as well as drive the output signals Zero and Overflow
    (OFL).
*/
`default_nettype none
module alu (Out, Ofl, Zero, InA, InB, Cin, Oper, invA, invB, sign);

    parameter OPERAND_WIDTH = 16;    
    parameter NUM_OPERATIONS = 3;
       
    input wire  [OPERAND_WIDTH -1:0] InA ; // Input wire operand A
    input wire  [OPERAND_WIDTH -1:0] InB ; // Input wire operand B
    input wire                       Cin ; // Carry in
    input wire  [NUM_OPERATIONS-1:0] Oper; // Operation type
    input wire                       invA; // Signal to invert A
    input wire                       invB; // Signal to invert B
    input wire                       sign; // Signal for signed operation
    output wire [OPERAND_WIDTH -1:0] Out ; // Result of comput wireation
    output wire                      Ofl ; // Signal if overflow occured
    output wire                      Zero; // Signal if Out is 0

    /* YOUR CODE HERE */
    wire [15:0] Ainv, Binv, TruA, TruB, outAND, outOR, outXOR, CLA_sum, shift_out, arith_out;
    wire Cout, ofl_checkout;

    // Input inversions
    not1 NotA [15:0] (.out(Ainv[15:0]), .in1(InA[15:0]));
    not1 NotB [15:0] (.out(Binv[15:0]), .in1(InB[15:0]));
    
    // Choose inverted or non-inverted inputs
    mux2_1_16b MuxInvA (.out(TruA[15:0]), .inputA(InA[15:0]), .inputB(Ainv[15:0]), .sel(invA));
    mux2_1_16b MuxInvB (.out(TruB[15:0]), .inputA(InB[15:0]), .inputB(Binv[15:0]), .sel(invB));
    
    // Bit logic operations
    and2 AndOp [15:0] (.out(outAND[15:0]), .in1(TruA[15:0]), .in2(TruB[15:0]));
    or2  OrOp  [15:0] (.out(outOR[15:0]), .in1(TruA[15:0]), .in2(TruB[15:0]));
    xor2 XorOp [15:0] (.out(outXOR[15:0]), .in1(TruA[15:0]), .in2(TruB[15:0]));
    
    // Addition operation
    cla16b CLA (.sum(CLA_sum[15:0]), .cOut(Cout), .inA(TruA[15:0]), .inB(TruB[15:0]), .cIn(Cin));
    
    // Shift ops
    shifter_hier ShiftOps (.In(TruA[15:0]), .ShAmt(TruB[3:0]), .Oper(Oper[1:0]), .Out(shift_out[15:0]));

    // Overflow and Zero detection
    OFL_Signed signed_OFL  (.out(ofl_checkout), .inOR(outOR[15]), .inAND(outAND[15]), .sum(CLA_sum[15]));
    ZeroDetectOR ZeroCheck (.out(Zero), .in1(Out[15:0]));
    
    // Choose ofl indicator based on signed-ness
    mux2_1 MuxSigned  (.out(Ofl), .inputA(Cout), .inputB(ofl_checkout), .sel(sign));

    // Output of standard Arthimetic operations, w/o shifter
    mux4_1_16b MuxArithmeticOut (.out(arith_out[15:0]), .inputA(CLA_sum[15:0]), .inputB(outAND[15:0]), .inputC(outOR[15:0]), .inputD(outXOR[15:0]), .sel(Oper[1:0]));
    
    // Choose final output from arthimetic or shifter modules
    mux2_1_16b MuxOut (.out(Out[15:0]), .inputA(shift_out[15:0]), .inputB(arith_out[15:0]), .sel(Oper[2]));

endmodule
`default_nettype wire
