//program counter, increments by 2, Jump/branch logic
module pc(
    //Outputs
    PcAddr,
    PC,
    //Inputs
    Imm,BrnchImm,
    Rs, jmpPC, RsAddr,
    PcSel,RegJmp,Halt,SIIC, PcStall,//Control Signals
    clk, rst
);
    input wire PcSel, RegJmp, Halt, SIIC, PcStall;
    input wire clk, rst;
    input wire [2:0] RsAddr;
    input wire[15:0] Imm, Rs, BrnchImm, jmpPC, jalrImm;
    output reg[15:0] PcAddr; //Next Instruction 
    output wire[15:0]  PC;   // PC used on the outside
    
    wire [15:0] Inc2, PcImm, RsImm, PcQ;
    wire zero;
    assign zero = 0;
    
    cla16b PcInc(.sum(Inc2), .cOut(), .inA(PcQ), .inB(16'h0002), .cIn(zero));
    cla16b PImm(.sum(PcImm), .cOut(), .inA(PcQ), .inB(BrnchImm), .cIn(zero));
    cla16b RImm(.sum(R7Imm), .cOut(), .inA(jmpPC), .inB(Imm), .cIn(zero));
    cla16b RImm(.sum(RsImm), .cOut(), .inA(Rs), .inB(Imm), .cIn(zero));
    
    assign PC = PcQ;
    dff_16 PcReg(.q(PcQ), .err(), .d(PcAddr), .clk(clk), .rst(rst));

    assign jalrImm = (RsAddr != 3'b111) ? RsImm : R7Imm;

    always @* begin 
        casex({PcSel, RegJmp, Halt, SIIC})
            4'b0000: PcAddr = PcStall ? PcQ : Inc2 ; //PC+2
            4'b?100: PcAddr = PcStall ? PcQ : jalrImm;//JR JALR        
            4'b1000: PcAddr = PcImm;//J JAL Branch
            4'b???1: PcAddr = 2;    //Exception Handler
            default: PcAddr = PcQ; //Halt
        endcase
    end

endmodule