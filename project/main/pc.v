//program counter, increments by 2, jump/branch logic
module pc(
    //Outputs
    PcAddr,
    //Inputs
    Imm,
    Rs
    jump,
    reg_jump,
    halt

);
    input wire jump, reg_jump, halt;
    input wire[15:0] Imm;
    output wire[15:0] PcAddr, ReadAddr;
    
    wire [15:0] Inc2, AddrDisp, stage1, AddrRel;

    cla16b PcInc(.sum(Inc2), .cOut(), .inA(PC), .inB(2), cIn.());
    cla16b Disp(.sum(AddrDisp), .cOut(), .inA(Inc2)), .inB(Imm), cIn.());

    assign stage1 = jump ? AddrDisp : Inc2;

    cla16b RsDisp(.sum(AddrRel), .cOut(), .inA(Rs), .inB(Imm), cIn.());

    assign stage2 = reg_jump ? AddrRel : stage1;

    assign PC = halt ? 0 : stage2;

    assign PcAddr = PC;



endmodule