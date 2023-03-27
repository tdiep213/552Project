module alu_tb();
   
    logic[15:0] out; 
    logic[4:0] opcode;
    logic[1:0] funct;
    logic[15:0] Ain, Bin;
    logic clk;

    alu iDUT(.out(out), .opcode(opcode), .funct(funct), .Ain(Ain), .Bin(Bin));

    initial begin
    clk = 0;
    opcode = 0;
    funct = 0;

    Ain = 2;
    Bin = 3;

    @(negedge clk);
    Ain = 16'h00aa;
    opcode = 11001;

    @(negedge clk);
    if(out != 16'h5500)
        $display("Incorrect bit reversal");
    $stop();
    
    /*-----------Arithmetic Immediate-----------*/
    opcode = 5'b01000;
    
    //Add
 
    @(negedge clk);
    if(out != (Ain+Bin)) begin
        $display("Incorrect Immediate addition");
        $stop();
    end
    @(negedge clk);
    
    //Sub
    opcode += 1;
    @(negedge clk);
    if(out != (Bin-Ain)) begin
        $display("Incorrect Immediate subtraction");
        $stop();
    end
    @(negedge clk);

    //XOR
    @(negedge clk);
    opcode += 1;
    if(out != (Ain^Bin)) begin
        $display("Incorrect Immediate XOR");
        $stop();
    end
    @(negedge clk);

    //NAND
    opcode += 1;
    @(negedge clk);
    if(out != Ain&~(Bin)) begin
        $display("Incorrect Immediate NAND");
        $stop();
    end
    @(negedge clk);

    /*-----------Immediate Shift-----------*/
    
    //ROL
    opcode = 5'b10100;
    // if(out != ~(Ain&Bin)) begin
    //     $display("Incorrect Reg rotate left");
    //     $stop();
    // end
    $display("ROL not automatically tested");

    @(negedge clk);
    //LLS
    opcode += 1;
    @(negedge clk);
    if(out != (Ain<<Bin[3:0])) begin
        $display("Incorrect Immediate Logical left shift");
        $stop();
    end
    @(negedge clk);

    //ROR
    opcode += 1;
    // if(out != (Ain^Bin)) begin
    //     $display("Incorrect Reg rotate right");
    //     $stop();
    // end
    $display("ROR not automatically tested");
    @(negedge clk);

    //LRS
    opcode += 1;
    @(negedge clk);
    if(out != (Ain>>Bin)) begin
        $display("Incorrect Immediate Logical right shift");
        $stop();
    end
    @(negedge clk);  


    /*-----------Register Shift------------*/ 
    opcode = 5'b11010;
    
    //LLS
    funct = 2'b00;
    @(negedge clk);
    if(out != (Ain<<Bin[3:0])) begin
        $display("Incorrect Reg Logical left shift");
        $stop();
    end
    @(negedge clk);
    
    //LRS
    funct = 2'b01; 
    @(negedge clk);
    if(out != (Ain>>Bin[3:0])) begin
        $display("Incorrect Reg Logical right shift");
        $stop();
    end
    @(negedge clk);

    //ROR
    funct = 2'b10;
    // if(out != (Ain^Bin)) begin
    //     $display("Incorrect Reg rotate right");
    //     $stop();
    // end
    $display("ROR not automatically tested");
    @(negedge clk);

    //ROL
    funct = 2'b11;
    // if(out != ~(Ain&Bin)) begin
    //     $display("Incorrect Reg rotate left");
    //     $stop();
    // end
    $display("ROL not automatically tested");
    @(negedge clk);





    /*-----------Arithmetic Register-----------*/
    opcode = 5'b11011;
    
    //Add
    funct = 2'b00;
    @(negedge clk);
    if(out != (Ain+Bin)) begin
        $display("Incorrect Reg addition");
        $stop();
    end
    @(negedge clk);
    
    //Sub
    funct = 2'b01; 
    @(negedge clk);
    if(out != (Bin-Ain)) begin
        $display("Incorrect Reg subtraction");
        $stop();
    end
    @(negedge clk);

    //XOR
    funct = 2'b10;
    if(out != (Ain^Bin)) begin
        $display("Incorrect Reg XOR");
        $stop();
    end
    @(negedge clk);

    //NAND
    funct = 2'b11;
    if(out != Ain& (~Bin)) begin
        $display("Incorrect Reg NAND");
        $stop();
    end
    
    @(negedge clk);


    $display("YAHOO! All tests passed");
    $stop();
    end


    always 
        #5 clk = ~clk;

endmodule