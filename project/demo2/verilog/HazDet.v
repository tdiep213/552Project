module HazDet(NOP, PcStall, Instr, valid_n, Rd, Imm, rst, clk);
output wire NOP, PcStall; 


input wire[15:0] Instr, Imm;
input wire[2:0] Rd;
input wire valid_n;
input wire rst, clk;

wire[2:0] IF_Rs, IF_Rt;

assign IF_Rs = Instr[10:8];
assign IF_Rt = Instr[7:5];


/*------Branch/Jump NOP-----*/
reg JBNOP;
always @* begin
    case(Instr[15:11])
        5'b111??: JBNOP = 1'b1; //JUMP
        5'b011??: JBNOP = 1'b1; //BRANCH
        default: JBNOP = 1'b0;
    endcase
end
/*------REG RAW Hazard Check-----*/
wire[2:0] ID_Rd;
wire ID_valid_n;
wire[2:0] EX_Rd;
wire EX_valid_n;
wire[2:0]MEM_Rd;
wire MEM_valid_n;
wire[2:0] WB_Rd;
wire WB_valid_n;
wire RegHazDet; 

dff REG_IF_ID [3:0](.q({ID_Rd, ID_valid_n}), .d({Rd, valid_n}), .clk(clk), .rst(rst));
dff REG_ID_EX [3:0](.q({EX_Rd, EX_valid_n}), .d({ID_Rd, ID_valid_n}), .clk(clk), .rst(rst));
dff REG_EX_MEM[3:0](.q({MEM_Rd, MEM_valid_n}), .d({EX_Rd, EX_valid_n}), .clk(clk), .rst(rst));
dff REG_MEM_WB[3:0](.q({WB_Rd, WB_valid_n}), .d({MEM_Rd, MEM_valid_n}), .clk(clk), .rst(rst));

assign RegHazDet = 
    ((ID_Rd == IF_Rs) & ID_valid_n) |
    ((EX_Rd == IF_Rs) & EX_valid_n) |
    ((MEM_Rd== IF_Rs) & MEM_valid_n) |
    ((WB_Rd == IF_Rs) & WB_valid_n) | 

    ((ID_Rd == IF_Rt) & ID_valid_n) |
    ((EX_Rd == IF_Rt) & EX_valid_n) | 
    ((MEM_Rd== IF_Rt) & MEM_valid_n) | 
    ((WB_Rd == IF_Rt) & WB_valid_n) ;


/*-----MEM RAW Hazard Check-----*/

wire[15:0] ID_Imm, EX_Imm, MEM_Imm, WB_Imm;
wire[2:0]  ID_Rs, EX_Rs, MEM_Rs, WB_Rs;
wire MemHazDet;

// not possible to determine true memaddr without value from Rs. Need to be passed this from fetch, or move into proc.
// cla16b RtImm(.sum(MemAddr), .cOut(), .inA(), .inB(Imm), .cIn(1'b0));   

// Update addresses used in other stages
dff_16 MEM_IF_ID( .q(ID_Imm),  .err(), .d(Imm),     .clk(clk), .rst(rst));
dff_16 MEM_ID_EX( .q(EX_Imm),  .err(), .d(ID_Imm),  .clk(clk), .rst(rst));
dff_16 MEM_EX_MEM(.q(MEM_Imm), .err(), .d(EX_Imm),  .clk(clk), .rst(rst));
dff_16 MEM_MEM_WB(.q(WB_Imm),  .err(), .d(MEM_Imm), .clk(clk), .rst(rst));

dff_16 MEM_IF_ID( .q(ID_Rs),  .err(), .d(IF_Rs),  .clk(clk), .rst(rst));
dff_16 MEM_ID_EX( .q(EX_Rs),  .err(), .d(ID_Rs),  .clk(clk), .rst(rst));
dff_16 MEM_EX_MEM(.q(MEM_Rs), .err(), .d(EX_Rs),  .clk(clk), .rst(rst));
dff_16 MEM_MEM_WB(.q(WB_Rs),  .err(), .d(MEM_Rs), .clk(clk), .rst(rst));
// might be overkill on number of cases, but better safe than sorry
// compare "addresses" in each stage to new addrs to determine NOP
assign MemHazDet =
 (((Imm == ID_Imm)  & (ID_Rs == IF_Rs))  & ID_valid_n)  |
 (((Imm == EX_Imm)  & (EX_Rs == IF_Rs))  & EX_valid_n)  |
 (((Imm == MEM_Imm) & (MEM_Rs == IF_Rs)) & MEM_valid_n) |
 (((Imm == WB_Imm)  & (WB_Rs == IF_Rs))  & WB_valid_n);
// if the Imm and Register are the same the memaddr may be the same
// currenlty can't read the data from Rs, so only have address to work with.

assign NOP = (RegHazDet | MemHazDet ) ? 1'b1 : 1'b0;
assign PcStall = (RegHazDet | MemHazDet) ? 1'b1 : 1'b0;

endmodule