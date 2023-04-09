module HazDet(NOP, PcStall, Instr, valid_n, MemEnable, Rd, Imm, Reg1Data, rst, clk);
output wire NOP, PcStall; 


input wire[15:0] Instr, Imm, Reg1Data;
input wire[2:0] Rd;
input wire valid_n, MemEnable;
input wire rst, clk;

wire[2:0] IF_Rs, IF_Rt;

assign IF_Rs = Instr[10:8];
assign IF_Rt = Instr[7:5];


/*------Branch/Jump NOP-----*/
reg JBNOP;
wire prevJBNOP;
always @* begin
    case(Instr[15:13])
        3'b001: JBNOP = 1'b1; //JUMP
        3'b011: JBNOP = 1'b1; //BRANCH
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

wire[15:0] MemAddr, ID_MemAddr, EX_MemAddr, MEM_MemAddr, WB_MemAddr;
wire ID_MemEnable, EX_MemEnable, MEM_MemEnable, WB_MemEnable;
wire MemHazDet;

cla16b RtImm(.sum(MemAddr), .cOut(), .inA(Reg1Data), .inB(Imm), .cIn(1'b0));   

// Update addresses used in other stages
dff_16 MEM_IF_ID( .q(ID_MemAddr),  .err(), .d(MemAddr),     .clk(clk), .rst(rst));
dff_16 MEM_ID_EX( .q(EX_MemAddr),  .err(), .d(ID_MemAddr),  .clk(clk), .rst(rst));
dff_16 MEM_EX_MEM(.q(MEM_MemAddr), .err(), .d(EX_MemAddr),  .clk(clk), .rst(rst));
dff_16 MEM_MEM_WB(.q(WB_MemAddr),  .err(), .d(WB_MemAddr), .clk(clk), .rst(rst));

dff En_IF_ID (.q(ID_MemEnable),  .d(MemEnable),     .clk(clk), .rst(rst));
dff En_ID_EX (.q(EX_MemEnable),  .d(ID_MemEnable),  .clk(clk), .rst(rst));
dff En_EX_MEM(.q(MEM_MemEnable), .d(EX_MemEnable),  .clk(clk), .rst(rst));
dff En_MEM_WB(.q(WB_MemEnable),  .d(MEM_MemEnable), .clk(clk), .rst(rst));
// might be overkill on number of cases, but better safe than sorry
// compare addresses in each stage to new addrs to determine NOP
assign MemHazDet = 
// If Mem is being accessed in this instruction, and mem was accessed in one of these previous instructions
((MemEnable == 1 ) &
 (ID_MemEnable  == MemEnable) |
 (EX_MemEnable  == MemEnable) |
 (MEM_MemEnable == MemEnable) |
 (WB_MemEnable  == MemEnable))
&
// AND the Memory accessed is the same memory accessed before
(((ID_MemAddr  == MemAddr)  & ID_valid_n)  |
 ((EX_MemAddr  == MemAddr)  & EX_valid_n)  |
 ((MEM_MemAddr == MemAddr)  & MEM_valid_n) |
 ((WB_MemAddr  == MemAddr)  & WB_valid_n));

wire JBNOP_n;
assign NOP = (RegHazDet | MemHazDet | prevJBNOP) ? 1'b1 : 1'b0;
assign PcStall = (RegHazDet | MemHazDet | JBNOP) ? 1'b1 : 1'b0;

dff BrnchJmp(.q(prevJBNOP), .d(JBNOP), .clk(clk), .rst(rst));

endmodule