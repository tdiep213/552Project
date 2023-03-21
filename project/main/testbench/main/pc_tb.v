module pc_tb()
    wire[15:0] PcAddr;
    wire[15:0] Imm, Rs;
    wire PcSel, RegJmp, Halt;
    wire clk, rst;

    pc iDUT(.PcAddr(PcAddr),.Imm(Imm),Rs(Rs),.PcSel(PcSel),.RegJmp(RegJmp),.Halt(Halt), .clk(clk), .rst(rst));

    initial(@posedge clk) begin
        //instantiate dut inputs
        clk = 0;
        Imm = 0;
        Rs = 0;

        RegJmp = 0;
        Halt = 0;     
        rst = 1;

        //wait 2 clock cycles
        repeat (2) @ (posedge clk);
        rst = 0;
        @(posedge clk);//PC = 0
        //Sets Rs and Imm to random values, PC should keep incrementing as normal
        Rs = $random;
        Imm = $random;

        //checks that pc incremented correctly over several cycles
        repeat (5) @ (posedge clk);
        if(PC != 10) begin
            $display("Incorrect PC increment");
            $stop();
        end



    end


    //10-unit period clk
    always 
        #5 clk = ~clk;

endmodule