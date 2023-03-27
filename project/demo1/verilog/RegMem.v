//Register memory block
module RegMem(
    //Output(s)
    Reg1Data,
    Reg2Data,
    //Input(s)
    ReadReg1, //Rs
    ReadReg2, //Rt
    WriteReg, // DestRegister
    WriteData,
    clk,
    rst,
    en,   //Control Signals  // clarify or rename 
                    //LBI-load byte immediate (data selection)
                    //Link - Jal/Jalr (data selection)
);
    parameter REG_WIDTH = 16;
    parameter REG_DEPTH = 8;
    parameter REG_LENGTH = 128; // = 16 * 8

    input wire clk, rst, en;
    input wire[15:0] WriteData;
    input wire[2:0] ReadReg1, ReadReg2, WriteReg;
    output wire[15:0] Reg1Data, Reg2Data;


    wire[15:0] out1, out2;
    rf RegFile(.read1OutData(Reg1Data), .read2OutData(Reg2Data), .err(),
                  .clk(clk), .rst(rst), .read1RegSel(ReadReg1), .read2RegSel(ReadReg2),
                  .writeRegSel(LinkReg), .writeInData(WriteData), .writeEn(en));
endmodule