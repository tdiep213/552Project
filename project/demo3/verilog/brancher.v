/*
   CS/ECE 552 Spring '22

   Filename        : fetch.v
   Description     : This is the module where new PC addresses are calculated.
*/
`default_nettype none
    //Branch + Jump calculation
module brancher(nextPC, Inc2, currentPC, 
                PCSel, RegJmp, BrancherFWDs,
                Imm, RsValue, EXtoID_Rs, MEMtoID_Rs, RsWrAddr, 
                Halt, SIIC);
    
    // Outputs
    output wire[15:0] Inc2;
    output reg[15:0]  nextPC;
    // Inputs
    input wire PCSel, RegJmp, Halt, SIIC;
    input wire [2:0] RsWrAddr;
    input wire[15:0] currentPC, Imm, RsValue, EXtoID_Rs, MEMtoID_Rs; //(one for mem and one for ex to id fwding)
    input wire [1:0] BrancherFWDs;

    wire [15:0] PcImm, RsImm;
    wire zero;
    assign zero = 0;
    reg [15:0] Rs; 
    
    always@* begin
        case(BrancherFWDs)
            2'b00: Rs = RsValue;
            2'b01: Rs = MEMtoID_Rs;
            2'b10: Rs = EXtoID_Rs;
            default: Rs = RsValue;
        endcase
    end
    
    cla16b PcInc(.sum(Inc2),  .cOut(), .inA(currentPC), .inB(16'h0002), .cIn(zero));
    cla16b PCIMM(.sum(PcImm), .cOut(), .inA(Inc2),      .inB(Imm),      .cIn(zero));
    cla16b RSIMM(.sum(RsImm), .cOut(), .inA(Inc2),      .inB(Imm),      .cIn(zero));

    always@* begin
        casex({RegJmp, PCSel, Halt, SIIC})
            4'b0000: nextPC = Inc2;
            4'b0100: nextPC = PcImm;
            4'b1100: nextPC = RsImm;
            4'b???1: nextPC = 2;
            default: nextPC = currentPC;     // Default to Halt
        endcase
    end

    // Stall logic stays in PC
    // always @* begin 
    //     casex({PCSel, RegJmp, Halt, SIIC})
    //         4'b0000: PcAddr = PcStall ? PcQ : Inc2 ; //PC+2
    //         4'b?100: PcAddr = PcStall ? PcQ : jalrImm;//JR JALR        
    //         4'b1000: PcAddr = PcImm;//J JAL Branch
    //         4'b???1: PcAddr = 2;    //Exception Handler
    //         default: PcAddr = PcQ; //Halt
    //     endcase
    // end

endmodule
`default_nettype wire