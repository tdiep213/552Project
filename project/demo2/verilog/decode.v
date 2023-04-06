/*
   CS/ECE 552 Spring '22
  
   Filename        : decode.v
   Description     : This is the module for the overall decode stage of the processor.
*/
`default_nettype none
module decode (Reg1Data, Reg2Data, Instr, Imm, Writeback, PC, LBI, Link, WriteRegAddr, en, clk, rst );
   // TODO: Your code here
   output wire[15:0] Reg1Data, Reg2Data; 

   input wire[15:0] Instr, Imm, PC;
   input wire[15:0] Writeback;
   input wire[2:0] WriteRegAddr;
   input wire LBI, Link, en;
   input wire clk, rst;

   
   wire[2:0] Rs, Rt;
   
  
   assign Rs = Instr[10:8];
   assign Rt = Instr[7:5];


    //Write Register Data logic
    wire [15:0] WriteData, PcSum2, ImmSel;
    wire zero;
    assign zero = 0; 

    cla16b Pc2(.sum(PcSum2), .cOut(), .inA(PC), .inB(16'h0002), .cIn(zero));
    assign ImmSel = LBI ? Imm : Writeback;
    assign WriteData = Link ? PcSum2 : ImmSel;      

   RegMem RegisterMem(.Reg1Data(Reg1Data),.Reg2Data(Reg2Data),
                     .ReadReg1(Rs), .ReadReg2(Rt),.WriteReg(WriteRegAddr), .WriteData(WriteData), 
   //                 //Rs                    //Rd                 //Rt
                     .en(en), .clk(clk), .rst(rst));
    


endmodule
`default_nettype wire