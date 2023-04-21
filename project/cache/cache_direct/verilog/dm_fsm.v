module dm_fsm(  // Outputs
            mem_addr, mem_wr, mem_rd, cache_en, cache_tag, cache_index,
            offset, cache_data, cache_wr, comp, valid_in, sel,
            // Inputs
               //PROC
            addr,
            data,
            rd,
            wr,
               //MEM
            stall,
            busy,
               //CACHE
            hit,
            dirty,
            valid
            );


    output wire [15:0] mem_addr, 
                       cache_data;
    output wire [7:0]  cache_index;
    output wire [4:0] cache_tag;
    output wire [2:0] offset;
    output wire cache_wr, 
                comp, 
                valid_in, 
                sel, 
                cache_en, 
                mem_wr, 
                mem_rd, 
                cache_en;

    input wire [15:0] addr,
                      data;
    input wire rd, 
               wr, 
               stall, 
               busy,
               hit,
               dirty,
               valid;


    assign cache_tag = addr[15:11];
    assign cache_index = addr[10:3];
    assign cache_tag = addr[2:0]; 

    reg [3:0] state, nxt_state;
    /* State list
    0x0/default = rst/idle state
    0x1 = Check cache
    0x2 = Cache hit


    */
    always @* begin 
        cache_wr = 1'b0;
        mem_rd = 1'b0;
        mem_wr = 1'b0;
        cache_en = 1'b0;
        comp = 1'b0;
        case(state)
            default: begin // Default/Idle case
                nxt_state = rd | wr ?  4'h1 : 4'h0;
            end
            
            4'h1: begin // Check cache  
                cache_en = 1'b1;
                comp = 1'b1;

                nxt_state = hit ? /*hit case*/ : /* miss case*/;
            end

            4'h2: begin // Cache hit
                nxt_state = rd ? 4'h3 : (wr ? /*Write case*/ : 4'h0); 
            end

            4'h3: begin // Read Cache

            end
        endcase 
    end 

    dff stateReg(.q(state), d(nxt_state), clk(clk), rst(rst));
endmodule