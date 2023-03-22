module sign_ext_tb();
    logic[15:0] out, in;
    logic[4:0] in5b;
    logic[7:0] in8b;
    logic[10:0] in11b;
    logic[1:0] cntrl, cntr;

    sign_ext iDUT(.out(out), .in(in), .zero_ext(cntr));
    reg clk;
    
    always @(cntrl) begin
        case(cntrl)
            1: in = in5b;
            2: in = in8b;
            3: in = in11b;
        endcase
    end

    initial begin
        clk = 2;

        in5b = 5'b10000;
        in8b = 2;
        in11b = 3;

        //Checks zero extend with multiple input lengths
        cntr = 0;

        cntrl = 1;
        @(negedge clk);
        if(out != {{11{1'b0}}, in5b}) begin
            $display("5 bit zero extend incorrect");
            $stop();
        end

        cntrl = 2;
        @(negedge clk);
        if(out != {{8{1'b0}}, in8b}) begin
            $display("11 bit zero extend incorrect");
            $stop();
        end

        cntrl = 3;
        @(negedge clk);
        if(out != {{5{1'b0}}, in11b}) begin
            $display("11 bit zero extend incorrect");
            $stop();
        end

        //Checks sign extends
        cntr = 1;
        cntrl = 1;
        @(negedge clk);
        if(out != {{11{in5b[4]}}, in5b}) begin
            $display("5 bit sign extend incorrect");
            $stop();
        end

        cntr = 2;
        cntrl = 2;
        @(negedge clk);
        if(out != {{8{in8b[7]}}, in8b}) begin
            $display("11 bit sign extend incorrect");
            $stop();
        end

        cntr = 3;
        cntrl = 3;
        @(negedge clk);
        if(out != {{5{in11b[10]}}, in11b}) begin
            $display("11 bit sign extend incorrect");
            $stop();
        end
        $display("YAHOO! All tests passed!");
        $stop();
    end

    always 
        #5 clk = ~clk;


endmodule