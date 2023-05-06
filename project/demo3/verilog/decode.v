/*
   CS/ECE 552 Spring '22
  
   Filename        : decode.v
   Description     : This is the module for the overall decode stage of the processor.
*/
`default_nettype none
module decode (Reg1Data, Reg2Data, JmpData, PcSel, branchTaken, nextPC, Instr, Imm,
               Writeback, PC, PCNOW, LBI, Link, b_flag, j_flag,RegJmp, 
               Halt,  WriteRegAddr, Forwards, en, clk, rst );
   // TODO: Your code here
   output wire[15:0] Reg1Data, Reg2Data, JmpData; 
   output wire PcSel, branchTaken;
   output wire[15:0] nextPC;

   input wire[15:0] Instr, Imm, PC, PCNOW;
   input wire[15:0] Writeback;
   input wire[2:0] WriteRegAddr;
   input wire[1:0] Forwards;
   input wire LBI, Link, en, b_flag, j_flag,RegJmp, Halt;
   input wire clk, rst;

   
   wire[2:0] Rs, Rt, WrAddr, read1RegSel;
   reg branch, jl_flag;
   wire EX_JL, MEM_JL, WB_JL; 
   wire [15:0] PcSum2, ImmSel, PC_instr, WriteData, JmpDataIn;

   wire EXtoID_FDRs, MEMtoID_FDRs;

   // reg[15:0] TrueData;

   assign EXtoID_FDRs  = Forwards[1];
   assign MEMtoID_FDRs = Forwards[0];
   /* NOTES FOR TIMO'S FORWARD CHANGES
   forward values actually come from the pipeline registers not where you were pulling them from 
   you can't have Rs/Rt forwards since you're only forwarding the results of the ALU/MEM read
   the individual signals are good though
   */
   // always@* begin
   //    case({EXtoID_FDRs, MEMtoID_FDRs})
   //       2'b00: TrueData = Writeback;
   //       2'b01: TrueData = MEM_FD_Rs;
   //       2'b10: TrueData = EX_FD_Rs;
   //       default: TrueData = Writeback;
   //    endcase
   // end
   //wire NOP_det;
   //assign NOP_det = (Instr[15:11] == 5'b00001) ? 1'b1 : 1'b0;
   always @* begin
      case(Instr[15:11])
         5'b00110: jl_flag = 1'b1;
         5'b00111: jl_flag = 1'b1;
         default jl_flag = 1'b0;
      endcase
   end
   assign JmpDataIn = (~jl_flag) ? JmpData : WriteData;
   dff_16 JMPDFF(.q(JmpData), .err(), .d(JmpDataIn), .clk(clk), .rst(rst));

   dff EX_JRDFF (.q(EX_JL),  .d(jl_flag), .clk(clk), .rst(rst));
   dff MEM_JRDFF(.q(MEM_JL), .d(EX_JL),   .clk(clk), .rst(rst));
   dff WB_JRDFF (.q(WB_JL),  .d(MEM_JL),  .clk(clk), .rst(rst));
   assign Rs = Instr[10:8];
   assign Rt = Instr[7:5];


   assign read1RegSel = (Instr[15:11] == 5'b00110 & (jl_flag | EX_JL)) ? 3'b111 : Rs;

    //Write Register Data logic
    
    wire Zflag, Sflag, branch_flag;

   /* bad
   // PC_instr is the PC value of the instruction currently in Decode (earlier than current PC because stages)
   //dff_16 PCDFF(.q(PC_instr), .err(), .d(PC), .clk(clk), .rst(rst));
   */
    cla16b Pc2(.sum(PcSum2), .cOut(), .inA(PCNOW), .inB(16'h0002), .cIn(1'b0));
    assign ImmSel = LBI ? Imm : Writeback;
    assign WriteData = (Link | jl_flag | EX_JL) ? PcSum2 : ImmSel;      

   assign WrAddr = jl_flag ? 3'b111 : WriteRegAddr;
   // popssibly add another output to decode that contains WriteData,
   // so we can forward that to fetch and use the data one stage earlier if we need to (like for JALR and JR)
   // by passing it into the jmpPC port on fetch!!
   RegMem RegisterMem(.Reg1Data(Reg1Data),.Reg2Data(Reg2Data),
                     .ReadReg1(read1RegSel), .ReadReg2(Rt),.WriteReg(WrAddr), .WriteData(WriteData), 
   //                 //Rs                    //Rd                 //Rt
                     .en((en & ~WB_JL & ~EX_JL & ~MEM_JL) | jl_flag), .clk(clk), .rst(rst));
   /* enable priorities: 
      jr_flag: write jump and link info ASAP
      en/~WB_JR: if the wb instr requires a write reg, do so, unless that wb instr was a jump and link
   */
    assign Sflag = Reg1Data[15];
    assign Zflag = &(Reg1Data == 16'h0000);
   
   assign branch_flag = ((Instr[15:13] == 3'b011) | b_flag) ? 1'b1 : 1'b0;
   assign PcSel = (branch_flag & ~Halt) ? (branch) : 1'b0; 
   
   //Tells the IF/ID pipeline register to flush the next instruction 
   //Due to a branch being taken
   dff InstrFlush(.q(branchTaken), .d(PcSel), .clk(clk), .rst(rst)); 
   
   always @* begin
      case(Instr[12:11])
         2'b00: branch = Zflag;    // BEQZ Rs, immediate if (Rs == 0) then PC <- PC + 2 + I(sign ext.)    
         2'b01: branch = ~Zflag;   // BNEZ Rs, immediate if (Rs != 0) then PC <- PC + 2 + I(sign ext.)
         2'b10: branch = Sflag;    // BLTZ Rs, immediate if (Rs < 0) then PC <- PC + 2 + I(sign ext.)
         2'b11: branch = ~Sflag;   // BGEZ Rs, immediate if (Rs >= 0) then PC <- PC + 2 + I(sign ext.)
      endcase
   end


   // brancher branchCntrl(
   //             .nextPC(nextPC), 
   //             .Inc2(), 
   //             .currentPC(PCNOW), 
   //             .PCSel(PcSel), 
   //             .RegJmp(RegJmp), 
   //             .BrancherFWDs(Forwards[1:0]),
   //             .Imm(Imm),
   //             .RsValue(Reg1Data), 
   //             .EXtoID_Rs(EX_FD_Rs), 
   //             .MEMtoID_Rs(MEM_FD_Rs), 
   //             .Halt(Halt),
   //             .rst(rst), .clk(clk),
   //              .SIIC()//Unused
   //              );

endmodule
`default_nettype wire
