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

wire[15:0] MemAddr, ID_MemAddr, EX_MemAddr, MEM_MemAddr, WB_MemAddr;
wire MemHazDet;

cla16b RtImm(.sum(IF_MemAddr), .cOut(), .inA(ID_Rs), .inB(Imm), .cIn(1'b0));   // Determine memory address

// Update addresses used in other stages
dff_16 MEM_IF_ID(.q(ID_MemAddr), .err(), .d(MemAddr), .clk(clk), .rst(rst));
dff_16 MEM_ID_EX(.q(EX_MemAddr), .err(), .d(ID_MemAddr), .clk(clk), .rst(rst));
dff_16 MEM_EX_MEM(.q(MEM_MemAddr), .err(), .d(EX_MemAddr), .clk(clk), .rst(rst));
dff_16 MEM_MEM_WB(.q(WB_MemAddr), .err(), .d(MEM_MemAddr), .clk(clk), .rst(rst));

// compare addresses in each stage to new addrs to determine NOP
assign MemHazDet =  1'b0;
    (MemAddr == ID_MemAddr) |
    (MemAddr == EX_MemAddr) |
    (MemAddr == MEMEM_MemAddrM_chk)|
    (MemAddr == WB_MemAddr) ;

assign NOP = (RegHazDet | MemHazDet ) ? 1'b1 : 1'b0;
assign PcStall = (RegHazDet | MemHazDet) ? 1'b1 : 1'b0;

endmodule