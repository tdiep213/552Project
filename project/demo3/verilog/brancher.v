/*
   CS/ECE 552 Spring '22

   Filename        : fetch.v
   Description     : This is the module where new PC addresses are calculated.
*/
`default_nettype none
    //Branch + Jump calculation
module brancher(nextPC, Inc2, currentPC, 
                PCSel, RegJmp, BrancherFWDs,
                Imm, RsValue, EXtoID_Rs, MEMtoID_Rs, 
                rst, clk,
                Halt, SIIC);
    
    // Outputs
    output wire[15:0] Inc2;
    output wire[15:0]  nextPC;
    // Inputs
    input wire PCSel, RegJmp, Halt, SIIC;
    input wire[15:0]  currentPC, Imm, RsValue, EXtoID_Rs, MEMtoID_Rs; //(one for mem and one for ex to id fwding)
    input wire [1:0] BrancherFWDs;

    input wire rst, clk;
    wire [15:0] PcImm, RsImm;
    wire zero;
    assign zero = 0;
    reg [15:0] Rs, preNextPC; 
    
    always@* begin
        case(BrancherFWDs)
            2'b00: Rs = RsValue;
            2'b01: Rs = MEMtoID_Rs;
            2'b10: Rs = EXtoID_Rs;
            default: Rs = RsValue;
        endcase
    end
    
    cla16b PcInc(.sum(Inc2),  .cOut(), .inA(nextPC), .inB(16'h0002), .cIn(1'b0));
    cla16b PCIMM(.sum(PcImm), .cOut(), .inA(Inc2),      .inB(Imm),      .cIn(1'b0));
    cla16b RSIMM(.sum(RsImm), .cOut(), .inA(Rs),      .inB(Imm),      .cIn(1'b0));

    always@* begin
        casex({RegJmp, PCSel, Halt, rst})
            4'b0000: preNextPC = Inc2;
            4'b0100: preNextPC = PcImm;
            4'b1100: preNextPC = RsImm;
            4'b???1: preNextPC = 0;
            default: preNextPC = currentPC;     // Default to Halt
        endcase
    end

    dff_16 NPCDFF(.q(nextPC), .err(), .d(preNextPC), .clk(clk), .rst(rst));
endmodule
`default_nettype wire