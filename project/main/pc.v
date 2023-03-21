//program counter, increments by 2, Jump/branch logic
module pc(
    //Outputs
    PcAddr,
    //Inputs
    Imm,
    Rs,
    PcSel,RegJmp,Halt //Control Signals
);
    input wire PcSel, RegJmp, Halt;
    input wire[15:0] Imm, Rs;
    output wire[15:0] PcAddr;
    
    wire [15:0] Inc2, AddrDisp, stage1, AddrRel, PcImm, RsImm;

    cla16b PcInc(.sum(Inc2), .cOut(), .inA(PC), .inB(2), .cIn());
    cla16b PImm(.sum(PcImm), .cOut(), .inA(Inc2), .inB(Imm), .cIn());
    cla16b RImm(.sum(RsImm), .cOut(), .inA(Rs), .inB(Imm), .cIn());
 
    cla16b RsDisp(.sum(AddrRel), .cOut(), .inA(Rs), .inB(Imm), .cIn());
    
    assign stage1 = PcSel ? PcImm : Inc2;
    assign stage2 = RegJmp ? RsImm : stage1;

    assign PC = Halt ? 0 : stage2;

    assign PcAddr = PC;



endmodule