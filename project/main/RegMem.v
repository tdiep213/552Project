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
    LBI, Link, //Control Signals  // clarify or rename 
                //LBI-load byte immediate
                //Link - Jal/Jalr
    PcAddr
);
    parameter REG_WIDTH = 16;
    parameter REG_DEPTH = 8;
    parameter REG_LENGTH = 128; // = 16 * 8

    input wire clk, rst;
    input wire LBI, Link;
    input wire[15:0] PcAddr, Imm;
    input wire[2:0] ReadReg1, ReadReg2, WriteReg ;
    output wire[15:0] Reg1Data, Reg2Data, WriteData;

    //Write Register address logic  <-- Currently only 3 inputs/options, need 4 (2 bit sel) b/c two Rd's
    // (Input, LinkReg[1:0]): (Instr[10:8] (Rs), 00) , (Instr[7:5] (Rd I1-form), 01) , and (R7, 10) , (Instr[4:2] (Rd R-form), 11)
    // These are the default values I am setting for control, feel free to change
    wire [2:0] loadImm, LinkReg;
    assign loadImm = LBI ? ReadReg1 : WriteReg; 
    assign LinkReg = Link ? 3'h7 : loadImm;

    //Write Register Data logic
    wire [15:0] data, PcSum2, ImmSel;
    wire zero;
    assign zero = 0;
    // perhaps replace cla with PcAddr from pc.v module as passed in value since you don't need to recalculate it. 
    // lmk if notes getting out of hand 

    /*Made recomended changes*/
    // cla16b Pc2(.sum(PcSum2), .cOut(), .inA(PC), .inB(2), .cIn(zero));
    assign ImmSel = LBI ? Imm : WriteData;
    assign data = Link ? PcAddr : ImmSel ;      

    wire[15:0] out1, out2;
    rf_bypass RegFile(.read1OutData(out1), .read2OutData(out2), .err(),
                  .clk(clk), .rst(rst), .read1RegSel(ReadReg1), .read2RegSel(ReadReg2),
                  .writeRegSel(LinkReg), .writeInData(data), .writeEn(1'b1));
endmodule