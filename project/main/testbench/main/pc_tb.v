module pc_tb()
    wire[15:0] PcAddr;
    wire[15:0] Imm, Rs;
    wire PcSel, RegJmp, Halt;

    pc iDUT(.PcAddr(PcAddr),.Imm(Imm),Rs(Rs),.PcSel(PcSel),.RegJmp(RegJmp),.Halt(Halt));

    initial begin

    end

endmodule