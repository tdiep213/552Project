//Register memory block
module RegMem(
    //Output(s)
    Reg1Data,
    Reg2Data,
    //Input(s)
    ReadReg1, //Rs
    ReadReg2, //Rt
    WriteReg, //Rd
    WriteData,
    Imm, 
    clk,
    rst,
    LBI, Link, //Control Signals  
    PC
);
    parameter REG_WIDTH = 16;
    parameter REG_DEPTH = 8;
    parameter REG_LENGTH = 128; // = 16 * 8

    input wire clk, rst;
    input wire LBI, Link;
    input wire[15:0] PC, Imm;
    input wire[2:0] ReadReg1, ReadReg2, WriteReg, WriteData;
    output reg[15:0] Reg1Data, Reg2Data;

    //Write Register address logic 
    wire [2:0] loadImm, LinkReg;
    assign loadImm = LBI ? ReadReg1 : WriteReg; 
    assign LinkReg = Link ? 3'h7 : loadImm;

    //Write Register Data logic
    wire [15:0] data, PcSum2, ImmSel;
    cla16b Pc2(.sum(PcSum2), .cOut(), .inA(PC), .inB(2), .cIn());
    assign ImmSel = LBI ? Imm : WriteData;
    assign data = Link ? PcSum2 : ImmSel ;

    rf_bypass RegFile(
                  // Outputs
                  .read1OutData(Reg1Data), .read2OutData(Reg2Data), .err(),
                  // Inputs
                  .clk(clk), .rst(rst), .read1RegSel(ReadReg1), .read2RegSel(ReadReg2),
                  .writeRegSel(LinkReg), .writeInData(WriteData), .writeEn(1)
                  );
endmodule