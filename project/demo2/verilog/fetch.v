    /*
    CS/ECE 552 Spring '22

    Filename        : fetch.v
    Description     : This is the module for the overall fetch stage of the processor.
    */
    `default_nettype none
    //PC + Instruction Memory
    module fetch (
    // outputs
    Instr_C, 
    PC, 
    RegWrite, 
    WriteRegAddr,
    MemEnable, 
    MemWr,
    Val2Reg, 
    ALUSel, 
    ImmSel,
    LinkReg, 
    ctrlErr, 
    b_flag,
    Halt,
    // inputs
    BrnchAddr,
    Imm, 
    Rs,     RegJmp, 
    SIIC,
    PcSel,
    clk, 
    rst);
    // TODO: Your code here
    output wire[15:0] Instr_C, PC; 
    output wire RegWrite, MemEnable, 
                MemWr, Val2Reg, ctrlErr, ALUSel, b_flag;

    output wire [1:0] LinkReg;
    output reg [2:0] WriteRegAddr;
    output wire [2:0] ImmSel;
    output wire RegJmp, Halt, SIIC;

    input wire[15:0] Imm, Rs;
    input wire[15:0] BrnchAddr;
    input wire PcSel;

    input wire clk, rst;

    wire[15:0] PcAddr, Instr;
    wire [15:0] Instr_A;
    wire[15:0] Instr_B;
    wire[1:0] DestRegSel;
    wire HazNOP, PCStall, valid_n;

    pc ProgCnt(.PcAddr(PcAddr),.PC(PC), .Imm(Imm), .BrnchImm(BrnchAddr) , .Rs(Rs),.PcSel(PcSel),.RegJmp(RegJmp),.Halt(Halt|PCStall), .SIIC(SIIC), .clk(clk), .rst(rst));
    memory2c InstrMem(.data_out(Instr), .data_in(), .addr(PC), .enable(1'b1), .wr(1'b0), 
                        .createdump(), .clk(clk), .rst(rst));

    always@* begin
      case(DestRegSel)
         2'b00: WriteRegAddr = Instr[10:8];   // Rs
         2'b01: WriteRegAddr = Instr[4:2];    // Rd-R
         2'b10: WriteRegAddr = 3'b111;           // R7
         2'b11: WriteRegAddr = Instr[7:5];    // Rd-I
         default: WriteRegAddr = Instr[4:2];
      endcase
   end

    HazDet HDU(.NOP(HazNOP), .PcStall(PCStall), .Instr(Instr_B), .valid_n(valid_n), .MemEnable(MemEnable), .Rd(WriteRegAddr), .Imm(Imm), .Reg1Data(Rs), .clk(clk), .rst(rst));
    assign Instr_B = HazNOP ? 16'h0800 : Instr;
    // dff_16 crying(.q(Instr_B), .err(), .d(Instr_A), .clk(clk), .rst(rst));


    control CNTRL(
    //Output(s)
    .RegWrite(RegWrite), 
    .DestRegSel(DestRegSel),
    .PcSel(), 
    .RegJmp(RegJmp), 
    .MemEnable(MemEnable), 
    .MemWr(MemWr),
    .ALUcntrl(Instr_C[15:11]),
    .Val2Reg(Val2Reg), 
    .ALUSel(ALUSel), 
    .ImmSel(ImmSel), 
    .Halt(Halt), 
    .LinkReg(LinkReg), 
    .ctrlErr(ctrlErr),
    .SIIC(SIIC),
    .b_flag(b_flag),
    .valid_n(valid_n),   
    //Input(s)
    .Instr(Instr_B[15:11]));

    //assign Instr_C[10:0] = Instr_B[10:0];
    
    endmodule
    `default_nettype wire
