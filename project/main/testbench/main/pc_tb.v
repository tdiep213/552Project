module pc_tb()
    wire[15:0] PcAddr;
    wire[15:0] Imm, Rs;
    wire PcSel, RegJmp, Halt;
    wire clk, rst;

    pc iDUT(.PcAddr(PcAddr),.Imm(Imm),Rs(Rs),.PcSel(PcSel),.RegJmp(RegJmp),.Halt(Halt), .clk(clk), .rst(rst));

    wire[15:0] chk;
    initial(@posedge clk) begin
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
        Rs = $random;
        Imm = $random;

        //checks that pc incremented correctly over several cycles
        repeat (5) @ (posedge clk);
        if(PcAddr != 10) begin
            $display("Incorrect PC increment");
            $stop();
        end
        //Checks that incrementing by an immediate works
        @(negedge clk);
        chk = PcAddr; 
        PcSel = 1;
        @(negedge clk);
        PcSel = 0;

        @(posedge clk);
        if((chk + Imm) != PcAddr)begin
            $display("Incorrect Immediate increment");
            $stop();
        end

        //Checks that a register jump works
        @(negedge clk); 
        RegJmp = 1;
        @(negedge clk);
        RegJmp = 0;
        
        @(posedge clk); 
        if((Rs+Imm) != PcAddr) begin
            $display("Incorrect Register jump address");
            $stop();
        end
    end


    //10-unit period clk
    always 
        #5 clk = ~clk;

endmodule