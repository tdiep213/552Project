module lt16b(out, Ain, Bin);
    output wire out;
    input wire[15:0] Ain, Bin;

    wire[15:0] compLt, compGt, bitEQ, sameSign;

    assign bitEQ = ~(Ain^Bin);
    gt1b gt16b[15:0](.out(compGt), .Ain(Ain), .Bin(Bin));
    lt1b lt16b[15:0](.out(compLt), .Ain(Ain), .Bin(Bin));
    
    assign sameSign = 
    compLt[15] | 
    ( compLt[14] & bitEQ[15]       ) | ( compLt[13] & (&bitEQ[15:14]) ) |
    ( compLt[12] & (&bitEQ[15:13]) ) | ( compLt[11] & (&bitEQ[15:12]) ) |
    ( compLt[10] & (&bitEQ[15:11]) ) | (  compLt[9] & (&bitEQ[15:10]) ) |
    (  compLt[8] & (&bitEQ[15:9])  ) | (  compLt[7] & (&bitEQ[15:8])  ) |
    (  compLt[6] & (&bitEQ[15:7])  ) | (  compLt[5] & (&bitEQ[15:6])  ) | 
    (  compLt[4] & (&bitEQ[15:5])  ) | (  compLt[3] & (&bitEQ[15:4])  ) |
    (  compLt[2] & (&bitEQ[15:3])  ) | (  compLt[1] & (&bitEQ[15:2])  ) |
    (  compLt[0] & (&bitEQ[15:1])  );
    
    assign out = bitEQ[15] ? sameSign : compGt[15];

endmodule