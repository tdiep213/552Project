module lt1b(out, Ain, Bin);
    output wire out;
    input wire Ain, Bin;

    assign out = ~Ain & Bin;
endmodule