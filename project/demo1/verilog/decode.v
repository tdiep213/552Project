/*
   CS/ECE 552 Spring '22
  
   Filename        : decode.v
   Description     : This is the module for the overall decode stage of the processor.
*/
`default_nettype none
module decode (Reg1Data, Reg2Data, Instr, Imm, PC, LBI, Link, Iformat, clk, rst );
   // TODO: Your code here
   output[15:0] Reg1Data, Reg2Data; 

   input wire[15:0] Instr, Imm, PC;
   input wire LBI, Link, Iformat;
   input wire clk, rst;

   wire[2:0] WriteRegAddr; 
   wire[2:0] Rs, Rt, Rd;
   wire[15:0] WriteDataIn;
   assign Rs = Instr[10:8];
   assign Rt = Instr[7:5];
   assign Rd = Iformat ? Instr[7:5] : Instr[4:2]; // Unsure if necessary, see RegMem.


   RegMem RegisterMem(.Reg1Data(Reg1Data),.Reg2Data(Reg2Data),
                     .ReadReg1(Rs), .ReadReg2(Rt),.WriteReg(Rd), .WriteData(WriteDataIn), 
   //                 //Rs                    //Rd                 //Rt
                     .Imm(Imm), .LBI(LBI), .Link(Link), .PcAddr(PC), .clk(clk), .rst(rst));
    


endmodule
`default_nettype wire
