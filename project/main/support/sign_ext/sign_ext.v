module sign_ext_(out, in, zero_ext);
    output wire[15:0] out;
    input wire[15:0] in;
    input wire[1:0] zero_ext;

    always @* begin;
        case(zero_ext)
            2'b00: begin // Zero-extend; zero extends are built into verilog when 
                         //the input length doesn't match the module length
                out = in;
            end     
            2'b01: begin // 5 bit input 
                out = {{11{in[4]}},in[4:0]};
            end        
            2'b10: begin // 8 bit input
                out = {{8{in[7]}},in[7:0]};
            end
            2'b11: begin //11 bit input
                out = {{5{in[10]}},in[10:0]};
            end
            default: begin 
                /*HOW?*/
            end
        endcase;
    end

endmodule