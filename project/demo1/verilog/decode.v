/*
   CS/ECE 552 Spring '22
  
   Filename        : decode.v
   Description     : This is the module for the overall decode stage of the processor.
*/
`default_nettype none
module decode (Reg1Data, Reg2Data, Instr, Imm, LBI, Link, PcAddr, clk, rst );
   // TODO: Your code here
   output[15:0] Reg1Data, Reg2Data; 

   input wire[15:0] Instr, Imm, PcAddr;
   input wire LBI, Link;
   input wire clk, rst;

   wire[2:0] WriteRegAddr; 
   wire[15:0] WriteDataIn;
   assign WriteRegAddr = Imm ? Instruction[7:5] : Instruction[4:2]; // Unsure if necessary, see RegMem.
   assign WriteDataIn = WriteDataSel ? PcAddr :  OperOutput; 

   RegMem RegisterMem(.Reg1Data(Reg1Data),.Reg2Data(Reg2Data),
                     .ReadReg1(Instr[10:8]), .ReadReg2(Instr[7:5]),.WriteReg(WriteRegAddr), .WriteData(WriteDataIn), 
   //                 //Rs                    //Rd                 //Rt
                     .Imm(Imm), .LBI(LBI), .Link(Link), .PC(PC), .clk(clk), .rst(rst));
    


endmodule
`default_nettype wire
