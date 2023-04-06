/* $Author: sinclair $ */
/* $LastChangedDate: 2020-02-09 17:03:45 -0600 (Sun, 09 Feb 2020) $ */
/* $Rev: 46 $ */
`default_nettype none
module proc (/*AUTOARG*/
    // Outputs
    err, 
    // Inputs
    clk, rst
    );

    input wire clk;
    input wire rst;

    output reg err;

    // None of the above lines can be modified

    // OR all the err ouputs for every sub-module and assign it as this
    // err output

    // As desribed in the homeworks, use the err signal to trap corner
    // cases that you think are illegal in your statemachines


    /* your code here -- should include instantiations of fetch, decode, execute, mem and wb modules */


    wire[2:0] ImmSel;

    wire[15:0] Writeback;

    wire zero, sign;

    //Control signals
    // deprecated wire[4:0] ALUcntrl;
    wire RegJmp, Halt, PcSel;  //FETCH
    wire RegWrite;   //DECODE
    wire[1:0] LinkReg, DestRegSel;
    wire SIIC;

    wire[15:0] EPC, EPC_D;

    wire ALUSel;               //EXECUTE
    wire MemEnable, MemWr;     //MEMORY
    wire Val2Reg;              //WRITEBACK
    wire ctrlErr, ext_err;     //ERRORs

    /*-----ID WIRES-----*/
    wire[15:0] ID_Instr, ID_PC, ID_ImmExt, ID_Rs, ID_Rt;
    reg[2:0] ID_WriteRegAddr;
    wire[1:0] ID_LinkReg, ID_DestRegSel;
    wire ID_RegWrite;
    wire ID_ALUSel, ID_MemEnable, ID_MemWr, ID_Halt, ID_Val2Reg;     

    /*-----EX WIRES-----*/
    wire[15:0] EX_Instr, EX_ImmExt, EX_PC, EX_Rs, EX_Rt, EX_ALUout;
    wire[2:0] EX_WriteRegAddr;
    wire EX_MemEnable, EX_MemWr, EX_Halt, EX_Val2Reg, EX_ALUSel, EX_RegWrite;
    

    /*-----MEM WIRES-----*/

    wire[15:0] MEM_Rt, MEM_ALUout, MEM_MEMout; 
    wire[2:0] MEM_WriteRegAddr;
    wire MEM_MemEnable, MEM_MemWr, MEM_Halt, MEM_Val2Reg, MEM_RegWrite;        

    /*-----WB WIRES-----*/
    wire[15:0] WB_MEMout, WB_ALUout;
    wire[2:0] WB_WriteRegAddr;
    wire WB_Val2Reg, WB_RegWrite;


    /*-----FETCH-----*/
    wire[15:0] IF_Instr, IF_PC, IF_ImmExt; 

    fetch F(
            .Instr_C(IF_Instr), .PC(IF_PC), 
            .Imm(ID_ImmExt), 
            .Rs(ID_Rs), 
            .RegWrite(RegWrite), 
            .DestRegSel(DestRegSel),
            .MemEnable(MemEnable), 
            .MemWr(MemWr),
            .Val2Reg(Val2Reg), 
            .ALUSel(ALUSel), 
            .ImmSel(ImmSel),
            .LinkReg(LinkReg), 
            .ctrlErr(ctrlErr), 
            .RegJmp(RegJmp), .Halt(Halt), .PcSel(PcSel), .SIIC(SIIC), .clk(clk), .rst(rst));

    /*---------------*/

    /*-----IF/ID-----*/


    if_id IF_ID_PIPE(
        /*-----PIPELINE OUT-----*/
        .InstrOut(ID_Instr), .PcOut(ID_PC),                                     //Data out
        .LinkRegOut(ID_LinkReg), .DestRegSelOut(ID_DestRegSel),                 //Control out (Decode)
        .ALUSelOut(ID_ALUSel),                                                  //Control out (Execute)
        .MemEnableOut(ID_MemEnable), .MemWrOut(ID_MemWr), .HaltOut(ID_Halt), //Control out (Memory)
        .Val2RegOut(ID_Val2Reg), .RegWriteOut(ID_RegWrite),                     //Control out (Writeback)

        /*-----PIPELINE IN-----*/
        .InstrIn(IF_Instr), .PcIn(IF_PC),                                       //Data in 
        .LinkRegIn(LinkReg), .DestRegSelIn(DestRegSel),                         //Execute control//Control in (Decode)
        .ALUSelIn(ALUSel),                                                      //Control in (Execute)
        .MemEnableIn(MemEnable), .MemWrIn(MemWr), .HaltIn(Halt),                //Control in (Memory)
        .Val2RegIn(Val2Reg), .RegWriteIn(RegWrite),                             //Control in (Writeback)

        .clk(clk), .rst(rst)
    );

    /*---------------*/


    /*-----DECODE-----*/
    
   always@* begin
      case(ID_DestRegSel)
         2'b00: ID_WriteRegAddr = ID_Instr[10:8];           // Rs
         2'b01: ID_WriteRegAddr = ID_Instr[4:2];   // Rd-R
         2'b10: ID_WriteRegAddr = 3'b111;       // R7
         2'b11: ID_WriteRegAddr = ID_Instr[7:5];   // Rd-I
         default: ID_WriteRegAddr = ID_Instr[4:2];
      endcase
   end

    decode D( .Reg1Data(ID_Rs), .Reg2Data(ID_Rt), .Imm(ID_ImmExt), .ext_err(ext_err), .Instr(ID_Instr), .Writeback(Writeback),
                .PC(ID_PC), .LBI(ID_LinkReg[0]), .Link(ID_LinkReg[1]), .WriteRegAddr(WB_WriteRegAddr), .ImmSelect(ImmSel), .en(WB_RegWrite), .clk(clk), .rst(rst) );
    /*---------------*/

    /*-----ID/EX-----*/

    id_ex ID_EX_PIPE(
        /*-----PIPELINE OUT-----*/
        .InstrOut(EX_Instr), .ImmExtOut(EX_ImmExt), .PcOut(EX_PC),          //Data out
            .RsOut(EX_Rs), .RtOut(EX_Rt), .WriteRegAddrOut(EX_WriteRegAddr),               
        .ALUSelOut(EX_ALUSel),                                              //Control out (Execute)
        .MemEnableOut(EX_MemEnable), .MemWrOut(EX_MemWr), .HaltOut(EX_Halt),//Control out (Memory)
        .Val2RegOut(EX_Val2Reg), .RegWriteOut(EX_RegWrite),                                            //Control out (Writeback)

        /*-----PIPELINE IN-----*/
        .InstrIn(ID_Instr), .ImmExtIn(ID_ImmExt), .PcIn(ID_PC),             //Data in
            .RsIn(ID_Rs), .RtIn(ID_Rt), .WriteRegAddrIn(ID_WriteRegAddr),     
        .ALUSelIn(ID_ALUSel),                                               //Control in (Execute)
        .MemEnableIn(ID_MemEnable), .MemWrIn(ID_MemWr), .HaltIn(ID_Halt),   //Control in (Memory)
        .Val2RegIn(ID_Val2Reg), .RegWriteIn(ID_RegWrite),                                            //Control in (Writeback)

        .clk(clk), .rst(rst)
    );

    /*---------------*/

    /*-----EXECUTE-----*/
    execute X(.out(EX_ALUout), .RsVal(EX_Rs), .RtVal(EX_Rt), .Imm(EX_ImmExt), .ALUSel(EX_ALUSel), .opcode(EX_Instr[15:11]), .funct(EX_Instr[1:0]));
    /*---------------*/

    /*-----EX/MEM-----*/
    ex_mem EX_MEM_PIPE(
        /*-----PIPELINE OUT-----*/
        .RtOut(MEM_Rt), .ALUoutOut(MEM_ALUout), .WriteRegAddrOut(MEM_WriteRegAddr), //Data out
        .MemEnableOut(MEM_MemEnable), .MemWrOut(MEM_MemWr), .HaltOut(MEM_Halt),     //Control out (Memory)
        .Val2RegOut(MEM_Val2Reg), .RegWriteOut(MEM_RegWrite),                                                   //Control out (Writeback)

        /*-----PIPELINE IN-----*/
        .RtIn(EX_Rt), .ALUoutIn(EX_ALUout), .WriteRegAddrIn(EX_WriteRegAddr),   //Data in
        .MemEnableIn(EX_MemEnable), .MemWrIn(EX_MemWr), .HaltIn(EX_Halt),       //Control in (Memory)
        .Val2RegIn(EX_Val2Reg), .RegWriteIn(EX_RegWrite),                                                 //Control in (Writeback)

        .clk(clk), .rst(rst)
    );
    /*---------------*/

    /*-----MEMORY-----*/
    memory M (.data_out(MEM_MEMout), .data_in(MEM_Rt), .addr(MEM_ALUout), .enable(MEM_MemEnable), .wr(MEM_MemWr), 
              .createdump(), .Halt(MEM_Halt), .clk(clk), .rst(rst));
    /*---------------*/

    /*-----MEM/WB-----*/
        mem_wb MEM_WB_PIPE(
        /*-----PIPELINE OUT-----*/
        .MemOutOut(WB_MEMout), .ALUoutOut(WB_ALUout), .WriteRegAddrOut(WB_WriteRegAddr),                              //Data out
        .Val2RegOut(WB_Val2Reg), .RegWriteOut(WB_RegWrite),                                               //Control out (Writeback)

        /*-----PIPELINE IN-----*/
        .MemOutIn(MEM_MEMout), .ALUoutIn(MEM_ALUout), .WriteRegAddrIn(MEM_WriteRegAddr),    //Data in
        .Val2RegIn(MEM_Val2Reg), .RegWriteIn(MEM_RegWrite),                                                            //Control in (Writeback)

        .clk(clk), .rst(rst)
    );
    /*---------------*/

    /*-----WRITEBACK-----*/
    wb W(.Writeback(Writeback), .ALUout(WB_ALUout), .MEMout(WB_MEMout), .Val2Reg(WB_Val2Reg));
    /*---------------*/

    /*-----CONTROL-----*/

    assign sign = ID_Rs[15];
    assign zero = &(ID_Rs == 16'h0000);

    // control CNTRL(
    // //Output(s)
    // .RegWrite(RegWrite), .DestRegSel(DestRegSel), .PcSel(PcSel), .RegJmp(RegJmp), .MemEnable(MemEnable), .MemWr(MemWr),
    // .ALUcntrl(ALUcntrl), .Val2Reg(Val2Reg), .ALUSel(ALUSel), .ImmSel(ImmSel), .Halt(Halt), .LinkReg(LinkReg), .ctrlErr(ctrlErr),
    // .SIIC(SIIC),   
    // //Input(s)
    // .Instr(IF_Instr[15:11]), .Zflag(zero), .Sflag(sign));

    always@* begin
        case({ctrlErr, ext_err})
        default: err =0; //ctrlErr | ext_err;
        endcase
    end

    assign EPC_D = SIIC ? IF_PC : EPC;
    dff_16 EPC_REG(.q(EPC), .err(), .d(EPC_D), .clk(clk), .rst(rst));

endmodule // proc
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :0:
