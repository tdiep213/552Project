module pc_tb();
    wire[15:0] PcAddr;
    reg[15:0] Imm, Rs;
    reg PcSel, RegJmp, Halt;
    reg clk, rst;

    pc iDUT(.PcAddr(PcAddr),.Imm(Imm),.Rs(Rs),.PcSel(PcSel),.RegJmp(RegJmp),.Halt(Halt), .clk(clk), .rst(rst));

    reg[15:0] chk;
    initial begin
        //instantiate dut inputs
        clk = 0;
        Imm = 0;
        Rs = 0;

        PcSel = 0;
        RegJmp = 0;
        Halt = 0;     
        rst = 1;

        //wait 2 clock cycles
        repeat (2) @ (negedge clk);
        rst = 0;
        @(negedge clk);//PC = 0
        //Sets Rs and Imm to random values, PC should keep incrementing as normal
        Rs = 10;
        Imm = 50;

        //checks that pc incremented correctly over several cycles
        repeat (4) @ (posedge clk);
        if(PcAddr != 10) begin
            $display("Incorrect PC increment");
            $stop();
        end
        // chk = PcAddr; 
        //Checks that incrementing by an immediate works
        @(negedge clk);
        chk = PcAddr; 
        PcSel = 1;
        @(negedge clk);
        PcSel = 0;

        @(posedge clk);
        if((chk + Imm +2) != PcAddr)begin
            $display("Incorrect Immediate increment");
            $stop();
        end

        //Checks that a register jump works
        @(negedge clk); 
        RegJmp = 1;
        @(negedge clk);
        RegJmp = 0;
        
        @(posedge clk); 
        if((Rs+Imm + 2 ) != PcAddr) begin
            $display("Incorrect Register jump address");
            $stop();
        end

        $display("YAHOO! All tests passed!");
        $stop();
    end


    //10-unit period clk
    always 
        #5 clk = ~clk;

endmodule