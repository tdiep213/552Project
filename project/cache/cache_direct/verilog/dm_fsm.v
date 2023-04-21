module dm_fsm(  // Outputs
            mem_addr, mem_wr, mem_rd, cache_en, cache_tag, cache_index,
            offset, cache_data_wr, cache_wr, comp, valid_in, sel,
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
                       cache_data_wr;
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
    //  assign offset = addr[2:0]; 

    /* TODO 
        I don't know if ararys of vectors like this work 
        in verilog 2003, but it'll be an easy fix if it doesn't
    */
    wire [15:0] mem_addr_offset[4];

    assign mem_addr_offset[0] = {cache_tag, cache_index, 3'b000}; 
    assign mem_addr_offset[1] = {cache_tag, cache_index, 3'b010};
    assign mem_addr_offset[2] = {cache_tag, cache_index, 3'b100};
    assign mem_addr_offset[3] = {cache_tag, cache_index, 3'b110};

    assign mem_addr_offset[4] = {cache_tag, cache_index, addr[2:0]};

    /*
    offset
    110 100 010 000 

    */
    reg [3:0] state, nxt_state;
    /* State list
    0x0/default = rst/idle state
    0x1 = Check cache
    0x2 = Cache hit


    */
    always @* begin 

        //Default outputs 
        cache_en = 1'b0;        // Cache disabled
        cache_wr = 1'b0;        // Don't write to cache
        comp = 1'b0;            // Don't do cache tag comparison
        offset = addr[2:0];     // Default read offset
         

        mem_rd = 1'b0;          // Don't read from memory
        mem_wr = 1'b0;          // Don't write to memory
        mem_addr = mem_addr_offset[4];  //Default memory read/write address

        sel = 1'b0;             // Output from cache 
        
        case(state)
            default: begin // Default/Idle case
                nxt_state = rd  ?  4'h1 : (wr ? 4'h0/*TODO write stage */: 4'h0);
            end
            
            /* CACHE READ FSM */
                4'h1: begin // Check cache  
                    cache_en = 1'b1;
                    comp = 1'b1;
                    

                    nxt_state = hit ? 4'h2 : /* miss case*/;
                end

                4'h2: begin // Cache hit
                   nxt_state = 4'h0;    //Reset FSM
                end

                4'h3 : begin // Cache Miss, read index, work 
                    mem_rd = 1'b1;
                    mem_addr = mem_addr_offset[0];
                    offset = 3'b000;

                    nxt_state = 4'h4;
                end
                4'h4: begin // Miss Stall 0 cycle 1
                    offset = 3'b000;
                    nxt_state= 4'h5;
                end

                4'h5: begin // Miss Stall 0 cycle 1
                    offset = 3'b000;
                end

            /* CACHE WRITE SM*/

        endcase 
    end 

    dff stateReg(.q(state), d(nxt_state), clk(clk), rst(rst));
endmodule