//program counter, increments by 2, Jump/branch logic
module pc(
    //Outputs
    PcAddr,
    PC,
    //Inputs
    Imm,BrnchImm,
    Rs,
    PcSel,RegJmp,Halt,SIIC, //Control Signals
    clk, rst
);
    input wire PcSel, RegJmp, Halt, SIIC;
    input wire clk, rst;
    input wire[15:0] Imm, Rs, BrnchImm;
    output reg[15:0] PcAddr; //Next Instruction 
    output wire[15:0]  PC;     //Previous Instruction + 2
    
    wire [15:0] Inc2, AddrDisp, stage1, stage2, PcImm, RsImm, PcQ;
    wire zero;
    assign zero = 0;

    cla16b PcInc(.sum(Inc2), .cOut(), .inA(PcQ), .inB(16'h0002), .cIn(zero));
    cla16b PImm(.sum(PcImm), .cOut(), .inA(Inc2), .inB(BrnchImm), .cIn(zero));
    cla16b RImm(.sum(RsImm), .cOut(), .inA(Rs), .inB(Imm), .cIn(zero));
    
    // assign stage1 = PcSel ? PcImm : Inc2;    // PC + 2 + Imm : PC + 2
    // assign stage2 = RegJmp ? RsImm : stage1; // Rs + Imm : ^

    // assign PcAddr = rst ? 0 : stage2;

    // assign PcAddr = PcQ+2;
    assign PC = PcQ;
    dff_16 PcReg(.q(PcQ), .err(), .d(PcAddr), .clk(clk), .rst(rst));


    always @* begin 
        casex({PcSel, RegJmp, Halt, SIIC})
            4'b0000: PcAddr = Inc2;
            4'b?100: PcAddr = RsImm;        
            4'b1000: PcAddr = PcImm;
            4'b???1: PcAddr = 2;
            default: PcAddr = PcQ; //Halt
        endcase
    end

endmodule