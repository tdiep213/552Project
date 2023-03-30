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

    wire[15:0] Instr, PC, ImmExt, Rs;
    wire[15:0] Rt, Writeback;

    wire[15:0] ALUout;
    wire[15:0] MEMout;

    wire zero, sign;

    //Control signals
    wire[4:0] ALUcntrl;
    wire RegJmp, Halt, PcSel;  //FETCH
    wire RegWrite;   //DECODE
    wire[1:0] LinkReg, DestRegSel;
    wire SIIC;

    wire[15:0] EPC, EPC_D;

    wire ALUSel;               //EXECUTE
    wire MemEnable, MemWr;     //MEMORY
    wire Val2Reg;              //WRITEBACK
    wire ctrlErr, ext_err;     //ERRORs

    /*-----FETCH-----*/
    wire[15:0] IF_Instr, IF_PC, IF_ImmExt; 
    fetch F(.Instr(IF_Instr), .PC(IF_PC), .Imm(ImmExt), .Rs(Rs), .RegJmp(RegJmp), .Halt(Halt), .PcSel(PcSel), .SIIC(SIIC), .clk(clk), .rst(rst));


    /*---------------*/

    /*-----IF/ID-----*/
    wire[15:0] ID_Instr, ID_PC, ID_ImmExt;
    wire ID_LinkReg, ID_DestRegSel, ID_RegWrite;

    if_id IF_ID_PIPE(
        /*-----PIPELINE OUT-----*/
        .InstrOut(ID_Instr), .ImmExtOut(ID_ImmExt), .PcOut(ID_PC),              //Data out
        .LinkRegOut(ID_LinkReg), .DestRegSelOut(ID_DestRegSel),                 //Control out (Decode)
                .RegWriteOut(ID_RegWrite),                        
        .ALUSelOut(ID_ALUSel),                                                  //Control out (Execute)
        .MemEnableOut(ID_MemEnable), .MemWrOut(ID_MemWr), .HaltOut(ID_Halt), //Control out (Memory)
        .Val2RegOut(ID_Val2Reg),                                                //Control out (Writeback)

        /*-----PIPELINE IN-----*/
        .InstrIn(IF_Instr), .ImmExtIn(IF_ImmExt), .PcIn(IF_PC),                 //Data in 
        .LinkRegIn(LinkReg), .DestRegSelIn(DestRegSel), .RegWriteIn(RegWrite),  //Execute control//Control in (Decode)
        .ALUSelIn(ALUSel),                                                      //Control in (Execute)
        .MemEnableIn(MemEnable), .MemWrIn(MemWr), .HaltIn(Halt),                //Control in (Memory)
        .Val2RegIn(Val2Reg),                                                    //Control in (Writeback)

        .clk(clk), .rst(rst)
    );

    /*---------------*/


    /*-----DECODE-----*/
    
    decode D( .Reg1Data(Rs), .Reg2Data(Rt), .Instr(ID_Instr), .Imm(ID_ImmExt), .Writeback(Writeback),
                .PC(ID_PC), .LBI(LinkReg[0]), .Link(LinkReg[1]), .DestRegSel(DestRegSel), .en(RegWrite), .clk(clk), .rst(rst) );
    /*---------------*/

    /*-----ID/EX-----*/

    id_ex ID_EX_PIPE(
        /*-----PIPELINE OUT-----*/
        .InstrOut(EX_Instr), .ImmExtOut(EX_ImmExt), .PcOut(EX_PC),          //Data out
            .RsOut(EX_Rs), .RtOut(EX_Rt)               
        .ALUSelOut(EX_ALUSel),                                              //Control out (Execute)
        .MemEnableOut(EX_MemEnable), .MemWrOut(EX_MemWr), .HaltOut(EX_Halt),//Control out (Memory)
        .Val2RegOut(EX_Val2Reg),                                            //Control out (Writeback)

        /*-----PIPELINE IN-----*/
        .InstrIn(ID_Instr), .ImmExtIn(ID_ImmExt), .PcIn(ID_PC),             //Data in
            .RsIn(ID_Rs), .RtIn(ID_Rt),     
        .ALUSelIn(ID_ALUSel),                                               //Control in (Execute)
        .MemEnableIn(ID_MemEnable), .MemWrIn(ID_MemWr), .HaltIn(ID_Halt),   //Control in (Memory)
        .Val2RegIn(ID_Val2Reg),                                             //Control in (Writeback)

        .clk(clk), .rst(rst)
    );

    /*---------------*/

    /*-----EXECUTE-----*/
    execute X(.out(ALUout), .RsVal(Rs), .RtVal(Rt), .Imm(ImmExt), .ALUSel(ALUSel), .opcode(Instr[15:11]), .funct(Instr[1:0]));
    /*---------------*/

    /*-----EX/MEM-----*/
    ex_mem EX_MEM_PIPE(
        /*-----PIPELINE OUT-----*/
        .RtOut(MEM_RtOut), .ALUoutOut(MEM_ALUout),                              //Data out
        .MemEnableOut(MEM_MemEnable), .MemWrOut(MEM_MemWr), .HaltOut(MEM_Halt), //Control out (Memory)
        .Val2RegOut(MEM_Val2Reg),                                               //Control out (Writeback)

        /*-----PIPELINE IN-----*/
        .RtIn(EX_Rt), .ALUoutIn(EX_ALUout),                                     //Data in
        .MemEnableIn(EX_MemEnable), .MemWrIn(EX_MemWr), .HaltIn(EX_Halt),       //Control in (Memory)
        .Val2RegIn(EX_Val2Reg),                                                 //Control in (Writeback)

        .clk(clk), .rst(rst)
    );
    /*---------------*/

    /*-----MEMORY-----*/
    memory M (.data_out(MEMout), .data_in(Rt), .addr(ALUout), .enable(MemEnable), .wr(MemWr), .createdump(), .Halt(Halt), .clk(clk), .rst(rst));
    /*---------------*/

    /*-----MEM/WB-----*/

    /*---------------*/

    /*-----WRITEBACK-----*/
    wb W(.Writeback(Writeback), .ALUout(ALUout), .MEMout(MEMout), .Val2Reg(Val2Reg));
    /*---------------*/

    /*-----CONTROL-----*/
    sign_ext EXT(.out(IF_ImmExt), .err(ext_err), .in(Instr), .zero_ext(ImmSel));

    assign sign = Rs[15];
    assign zero = &(Rs == 16'h0000);

    control CNTRL(
    //Output(s)
    .RegWrite(RegWrite), .DestRegSel(DestRegSel), .PcSel(PcSel), .RegJmp(RegJmp), .MemEnable(MemEnable), .MemWr(MemWr),
    .ALUcntrl(ALUcntrl), .Val2Reg(Val2Reg), .ALUSel(ALUSel), .ImmSel(ImmSel), .Halt(Halt), .LinkReg(LinkReg), .ctrlErr(ctrlErr),
    .SIIC(SIIC),   
    //Input(s)
    .Instr(Instr[15:11]), .Zflag(zero), .Sflag(sign));

    always@* begin
        case({ctrlErr, ext_err})
        default: err =0; //ctrlErr | ext_err;
        endcase
    end

    assign EPC_D = SIIC ? PC : EPC;
    dff_16 EPC_REG(.q(EPC), .err(), .d(EPC_D), .clk(clk), .rst(rst));

endmodule // proc
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :0:
