//Stores instruction memeory
module InstrMem(
    //Output(s)
    Instr,
    //Input(s)
    ReadAddr
);
    input wire[15:0] ReadAddr;
    output reg[15:0] Instr; 
endmodule