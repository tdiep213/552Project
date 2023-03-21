/*
    CS/ECE 552 Spring '23
    Homework #2, Problem 1
    
    A barrel shifter module.  It is designed to shift a number via rotate
    left, shift left, shift right arithmetic, or shift right logical based
    on the 'Oper' value that is passed in.  It uses these
    shifts to shift the value any number of bits.
 */
`default_nettype none
module shifter (InBS, ShAmt, ShiftOper, OutBS);

    // declare constant for size of inputs, outputs, and # bits to shift
    parameter OPERAND_WIDTH = 16;
    parameter SHAMT_WIDTH   =  4;
    parameter NUM_OPERATIONS = 2;

    input wire [OPERAND_WIDTH -1:0] InBS;  // Input operand
    input wire [SHAMT_WIDTH   -1:0] ShAmt; // Amount to shift/rotate
    input wire [NUM_OPERATIONS-1:0] ShiftOper;  // Operation type
    output wire [OPERAND_WIDTH -1:0] OutBS;  // Result of shift/rotate

   /* YOUR CODE HERE */
   wire [7:0] zero, signExt;
   assign zero[7:0] = 8'b0000_0000;
   assign signExt[7:0] = {InBS[15],InBS[15],InBS[15],InBS[15],InBS[15],InBS[15],InBS[15],InBS[15]};
   wire [15:0] R0_MuxOut, R1_MuxOut, R2_MuxOut, R0_MuxIn, R1_MuxIn, R2_MuxIn, R3_MuxIn;
   wire [15:0] SL_R0, SRL_R0, RL_R0, SRA_R0, SL_R1, SRL_R1, RL_R1, SRA_R1, SL_R2, SRL_R2, RL_R2, SRA_R2, SL_R3, SRL_R3, RL_R3, SRA_R3;

   // Shift Left
   assign SL_R0[15:0] = {InBS[14:0],      zero[  0]};
   assign SL_R1[15:0] = {R0_MuxOut[13:0], zero[1:0]};
   assign SL_R2[15:0] = {R1_MuxOut[11:0], zero[3:0]};
   assign SL_R3[15:0] = {R2_MuxOut[ 7:0], zero[7:0]};
   // Shift Right Logical
   assign SRL_R0[15:0] = {zero[  0], InBS[15:1]};
   assign SRL_R1[15:0] = {zero[1:0], R0_MuxOut[15:2]};
   assign SRL_R2[15:0] = {zero[3:0], R1_MuxOut[15:4]};
   assign SRL_R3[15:0] = {zero[7:0], R2_MuxOut[15:8]};
   // Rotate Left
   assign RL_R0[15:0] = {InBS[14:0],      InBS[15]};
   assign RL_R1[15:0] = {R0_MuxOut[13:0], R0_MuxOut[15:14]};
   assign RL_R2[15:0] = {R1_MuxOut[11:0], R1_MuxOut[15:12]};
   assign RL_R3[15:0] = {R2_MuxOut[ 7:0], R2_MuxOut[15:8]};
   // Shift Right Arithmetic
   assign SRA_R0[15:0] = {signExt[  0], InBS[15:1]};
   assign SRA_R1[15:0] = {signExt[1:0], R0_MuxOut[15:2]};
   assign SRA_R2[15:0] = {signExt[3:0], R1_MuxOut[15:4]};
   assign SRA_R3[15:0] = {signExt[7:0], R2_MuxOut[15:8]};

   // Rows separated for readability

   // Row 0 Operation Mux
   mux4_1_16b OprM0    (.out(R0_MuxIn[15:0]), .inputA(SL_R0[15:0]), .inputB(SRL_R0[15:0]), .inputC(RL_R0[15:0]), .inputD(SRA_R0[15:0]), .sel(ShiftOper[1:0]));
   // Row 0 Bit Mux
   mux2_1 R0Mux [15:0] (.out(R0_MuxOut[15:0]), .inputA(InBS[15:0]), .inputB(R0_MuxIn[15:0]), .sel(ShAmt[0]));
   // Row 1 Operation Mux
   mux4_1_16b OprM1    (.out(R1_MuxIn[15:0]), .inputA(SL_R1[15:0]), .inputB(SRL_R1[15:0]), .inputC(RL_R1[15:0]), .inputD(SRA_R1[15:0]), .sel(ShiftOper[1:0]));
   // Row 1 Bit  Mux
   mux2_1 R1Mux [15:0] (.out(R1_MuxOut[15:0]), .inputA(R0_MuxOut[15:0]), .inputB(R1_MuxIn[15:0]), .sel(ShAmt[1]));
   // Row 2 Operation Mux
   mux4_1_16b OprM2    (.out(R2_MuxIn[15:0]), .inputA(SL_R2[15:0]), .inputB(SRL_R2[15:0]), .inputC(RL_R2[15:0]), .inputD(SRA_R2[15:0]), .sel(ShiftOper[1:0]));
   // Row 2 Bit Mux
   mux2_1 R2Mux [15:0] (.out(R2_MuxOut[15:0]), .inputA(R1_MuxOut[15:0]), .inputB(R2_MuxIn[15:0]), .sel(ShAmt[2]));
   // Row 3 Operation Mux
   mux4_1_16b OprM3    (.out(R3_MuxIn[15:0]), .inputA(SL_R3[15:0]), .inputB(SRL_R3[15:0]), .inputC(RL_R3[15:0]), .inputD(SRA_R3[15:0]), .sel(ShiftOper[1:0]));
   // Row 3 Bit Mux
   mux2_1 ReMux [15:0] (.out(OutBS[15:0]), .inputA(R2_MuxOut[15:0]), .inputB(R3_MuxIn[15:0]), .sel(ShAmt[3]));

endmodule
`default_nettype wire
