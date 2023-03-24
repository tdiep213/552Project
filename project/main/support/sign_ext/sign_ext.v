module sign_ext(out, err, in, zero_ext);
    output reg[15:0] out;
    output reg err;
    input wire[15:0] in; //Takes full 16-bit instruction 
    input wire[1:0] zero_ext;
    // zero_ext[sign_bit, input # [2:0]]
    always @* begin
        case(zero_ext)  // Zero-extend; zero extends are built into verilog when 
                        //the input length doesn't match the module length
            3'b000: begin   // Zero Ext 5 bits
                out = in[4:0];
            end    
            3'b001: begin   // Zero Ext 8 bits
                out = in[7:0];
            end 
            2'b100: begin // Sign Ext 5 bits
                out = {{11{in[4]}},in[4:0]};
            end        
            2'b101: begin // Sign Ext 8 bits
                out = {{8{in[7]}},in[7:0]};
            end
            2'b110: begin // Sign Ext 11 bits
                out = {{5{in[10]}},in[10:0]};
            end
            default: begin
                err = 1'b1;
            end
        endcase
    end

endmodule