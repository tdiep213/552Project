/*
   CS/ECE 552 Spring '22
  
   Filename        : decode.v
   Description     : This is the module for the overall decode stage of the processor.
*/
`default_nettype none
module decode (Reg1Data, Reg2Data, PcSel, Instr, Imm, Writeback, PC, LBI, Link, b_flag, Halt,  WriteRegAddr, en, clk, rst );
   // TODO: Your code here
   output wire[15:0] Reg1Data, Reg2Data; 
   output wire PcSel;

   input wire[15:0] Instr, Imm, PC;
   input wire[15:0] Writeback;
   input wire[2:0] WriteRegAddr;
   input wire LBI, Link, en, b_flag, Halt;
   input wire clk, rst;

   
   wire[2:0] Rs, Rt;
   reg branch; 
   
  
   assign Rs = Instr[10:8];
   assign Rt = Instr[7:5];


    //Write Register Data logic
    wire [15:0] WriteData, PcSum2, ImmSel;
    wire Zflag, Sflag, branch_flag;

    cla16b Pc2(.sum(PcSum2), .cOut(), .inA(PC), .inB(16'h0002), .cIn(1'b0));
    assign ImmSel = LBI ? Imm : Writeback;
    assign WriteData = Link ? PcSum2 : ImmSel;      

   RegMem RegisterMem(.Reg1Data(Reg1Data),.Reg2Data(Reg2Data),
                     .ReadReg1(Rs), .ReadReg2(Rt),.WriteReg(WriteRegAddr), .WriteData(WriteData), 
   //                 //Rs                    //Rd                 //Rt
                     .en(en), .clk(clk), .rst(rst));
    
    assign Sflag = Reg1Data[15];
    assign Zflag = &(Reg1Data == 16'h0000);

   assign PcSel = (branch_flag & ~Halt) ? branch : 1'b0; 

   assign branch_flag = ((Instr[15:13] == 3'b011) | b_flag) ? 1'b1 : 1'b0;

   always @* begin
      case(Instr[12:11])
         2'b00: branch = Zflag;    // BEQZ Rs, immediate if (Rs == 0) then PC <- PC + 2 + I(sign ext.)    
         2'b01: branch = ~Zflag;   // BNEZ Rs, immediate if (Rs != 0) then PC <- PC + 2 + I(sign ext.)
         2'b10: branch = Sflag;    // BLTZ Rs, immediate if (Rs < 0) then PC <- PC + 2 + I(sign ext.)
         2'b11: branch = ~Sflag;   // BGEZ Rs, immediate if (Rs >= 0) then PC <- PC + 2 + I(sign ext.)
      endcase
   end

endmodule
`default_nettype wire
