module RegMem_tb();
    logic[15:0] Reg1Data, Reg2Data; 
    logic[2:0] ReadReg1, ReadReg2, WriteReg;
    logic[15:0] WriteData, Imm, PC;
    logic LBI, Link;
    logic clk, rst; 

    RegMem iDUT(
        //Output(s)
        .Reg1Data(Reg1Data),
        .Reg2Data(Reg2Data),
        //Input(s)
        .ReadReg1(ReadReg1), //Rs
        .ReadReg2(ReadReg2), //Rt
        .WriteReg(WriteReg), //Rd
        .WriteData(WriteData),
        .PC(PC), .Link(Link),
        .clk(clk),.rst(rst),
        .Imm(Imm), .LBI(LBI) //Control Signals  
    );

  


    initial begin
        clk = 0;
        rst = 1;

        ReadReg1 = 0;
        ReadReg2 = 0;

        WriteReg = 0;
        WriteData = 0;
        Imm = 0;

        LBI = 0;
        Link = 0;

        repeat (2) @(negedge clk);
        rst = 0;
        //Initialize File Register wher Ri = i
        for(int i=0; i < 8; i++) begin 
            @(negedge clk);
            WriteReg = i;
            WriteData = i;
            @(negedge clk);
        end
        
        WriteReg = 0;
        WriteData = 0;
        
        //Checks that all registers were initialized correctly
        for(int i=0; i < 7; i=i+2) begin 
            ReadReg1 = i;
            ReadReg2 = i + 1;
            @(negedge clk);
 
            if(Reg1Data != i | Reg2Data != i+1) begin
                $display("R/W error in register: %h", i);
                $stop();
            end
            if(Reg2Data != i+1) begin
                $display("R/W error in register: %h", i+1);
                $stop();
            end
            @(negedge clk);
        end


    //Test LBI  
    ReadReg2 = 0;
    Imm = 1;
    LBI = 1;
    @(negedge clk)

    if(Reg1Data != 1) begin
        $display("Immediate write error");
        $stop();
    end


    //Test Jump and Link

    ReadReg1 = 7;
    Link = 1;
    PC = 10;
    @(negedge clk)

    if(Reg1Data != 12) begin
        $display("PC link error");
        $stop();
    end


    $display("YAHOO! All tests passed!");
    $stop();
    end



    always
        #5 clk = ~clk;
endmodule