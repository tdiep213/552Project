module sign_ext(out, err, in, zero_ext);
    output reg[15:0] out;
    output reg err;
    input wire[15:0] in; //Takes full 16-bit instruction 
    input wire[1:0] zero_ext;

    always @* begin
        case(zero_ext)
            3'b000: begin // Zero-extend; zero extends are built into verilog when 
                         //the input length doesn't match the module length
                out = in[4:0];
            end    
            3'b001: begin 
                out = in[7:0];
            end 
            2'b010: begin // 5 bit input 
                out = {{11{in[4]}},in[4:0]};
            end        
            2'b100: begin // 8 bit input
                out = {{8{in[7]}},in[7:0]};
            end
            2'b110: begin //11 bit input
                out = {{5{in[10]}},in[10:0]};
            end
            default: begin
                err = 1'b1;
            end
        endcase
    end

endmodule