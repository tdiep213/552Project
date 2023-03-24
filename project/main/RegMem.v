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
    LBI, Link, en,   //Control Signals  // clarify or rename 
                    //LBI-load byte immediate (True: use Rs, False: Else)
                    //Link - Jal/Jalr (True: use R7)
    PC
);
    parameter REG_WIDTH = 16;
    parameter REG_DEPTH = 8;
    parameter REG_LENGTH = 128; // = 16 * 8

    input wire clk, rst;
    input wire LBI, Link, en;
    input wire[15:0] PcAddr, Imm;
    input wire[2:0] ReadReg1, ReadReg2, WriteReg ;
    output wire[15:0] Reg1Data, Reg2Data, WriteData;

    //Write Register Logic
    // WriteReg: Rd
    // LBI True: Pass Rs
    // LBI False: Rd
    // Link True: Pass R7
    // Link False: Rd or Rs
    wire [2:0] loadImm, LinkReg;
    assign loadImm = LBI ? ReadReg1 : WriteReg; 
    assign LinkReg = Link ? 3'h7 : loadImm;

    //Write Register Data logic
    wire [15:0] data, PcSum2, ImmSel;
    wire zero;
    assign zero = 0; 

    // PC_1 -> Jump Instr: set Rs to PC_1 + 2 (next instr), set PC_addr to PC_1 + 2 + Imm, currently we output PC_1+2
    // PC_2 +2 -> ...
    // So, we can cut out cla16b again (sorry) and just use PC in place of PcSum2, unless cylce shenanigans occur.
    
    // cla16b Pc2(.sum(PcSum2), .cOut(), .inA(PC), .inB(2), .cIn(zero));   
    assign ImmSel = LBI ? Imm : WriteData;
    assign data = Link ? PC : ImmSel ;      

    wire[15:0] out1, out2;
    rf RegFile(.read1OutData(out1), .read2OutData(out2), .err(),
                  .clk(clk), .rst(rst), .read1RegSel(ReadReg1), .read2RegSel(ReadReg2),
                  .writeRegSel(LinkReg), .writeInData(data), .writeEn(en));
endmodule