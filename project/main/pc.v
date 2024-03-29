//program counter, increments by 2, Jump/branch logic
module pc(
    //Outputs
    PcAddr,
    PC,
    //Inputs
    Imm,
    Rs,
    PcSel,RegJmp,Halt, //Control Signals
    clk, rst
);
    input wire PcSel, RegJmp, Halt;
    input wire clk, rst;
    input wire[15:0] Imm, Rs;
    output wire[15:0] PcAddr, //Next Instruction 
                      PC;     //Previous Instruction + 2
    
    wire [15:0] Inc2, AddrDisp, stage1, stage2, AddrRel, PcImm, RsImm, PcQ;
    wire zero;
    assign zero = 0;

    cla16b PcInc(.sum(Inc2), .cOut(), .inA(PcQ), .inB(16'h0002), .cIn(zero));
    cla16b PImm(.sum(PcImm), .cOut(), .inA(Inc2), .inB(Imm), .cIn(zero));
    cla16b RImm(.sum(RsImm), .cOut(), .inA(Rs), .inB(Imm), .cIn(zero));
 
    cla16b RsDisp(.sum(AddrRel), .cOut(), .inA(Rs), .inB(Imm), .cIn(zero));
    
    assign stage1 = PcSel ? PcImm : Inc2;    // PC + 2 + Imm : PC + 2
    assign stage2 = RegJmp ? RsImm : stage1; // Rs + Imm : ^

    assign PcAddr = Halt ? 0 : stage2;
    assign PC = PcQ;
    dff_16 PcReg(.q(PcQ), .err(), .d(PcAddr), .clk(clk), .rst(rst));


endmodule