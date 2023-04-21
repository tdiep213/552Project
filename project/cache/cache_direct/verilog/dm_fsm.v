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
    reg[15:0] state, nxt_state;
    reg[15:0] stalling, stall_inc;
    /* State list

    1 -> 19 Read
    20 ->

    0/default   = rst/idle state

    1           = Check cache
    2           = Cache hit
    3           = Read memory index w/ offset 0
    4           = R/W stall  
    5           = Read memory index w/ offset 1 | Write Cache w/ offset 0
    6           = Read memory index w/ offset 2 | Write Cache w/ offset 1
    7           = Read memory index w/ offset 3 | Write Cache w/ offset 2
    8           = Write Cache w/ offset 3

    9           = Check dirty bit for READ
    10          = DIRTY| Write cache to memory
    11          =    

    20          = Check
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
        stall_inc = 16'h0000;

        nxt_state = 16'd0;      // Loop default state
        case(state)
            default: begin // Default/Idle case
                nxt_state = rd  ?  16'd1 : (wr ? 16'd20: 16'd0);
            end
            
            /* CACHE READ FSM */
                16'd1: begin // Check cache  
                    cache_en = 1'b1;
                    comp = 1'b1;
                    
                    nxt_state = hit ? 16'd2 : 16'd10;
                end

                16'd2: begin // Cache hit
                   nxt_state = 16'd0;    //Reset FSM
                    offset = addr[2:0];
                end


                /* DIRTY BIT MEMORY WRITEBACK */
                16'd9: begin   //Check dirty bit
                    nxt_state = dirty ? 16'd10: 16'd3;
                end

                /*WRITE CACHE LINE TO MEMORY*/
                /* TODO */ 
                /* Also done as part of write to cache*/
                16'd10: begin  
                    cache_en = 1'b1;
                    offset = 3'b000;
                end

                /*PULL CACHE LINE FROM MEMORY*/
                16'd4: begin // Miss stalls
                    offset = 3'b000;

                    nxt_state = stalling; 
                end

                16'd3 : begin // Cache Miss, read index 0 
                    // cache_en = 1'b1;
                    // cache_wr = 1'b1;
                    // offset = 3'b000;

                    mem_rd = 1'b1;
                    mem_addr = mem_addr_offset[0];
                    
                    stall_inc = 16'h0001;
                    nxt_state = 16'd4;
                end

                16'd5: begin // Miss Offset 1
                    //Write to offset 0
                    cache_en = 1'b1;
                    cache_wr = 1'b1;
                    offset = 3'b000;

                    mem_rd = 1'b1;
                    mem_addr = mem_addr_offset[1];
                    

                    stall_inc = 16'h0002;
                    nxt_state = 16'd4;//Stall 
                end

                16'd6: begin // Miss  Offset 2
                    //Write to offset 1
                    cache_en = 1'b1;
                    cache_wr = 1'b1;
                    offset = 3'b010;

                    mem_rd = 1'b1;
                    mem_addr = mem_addr_offset[2];
                    

                    stall_inc = 16'h0003;
                    nxt_state = 16'd4; //Stall 
                end

                16'd7: begin // Miss Offset 3
                    //Write to offset 2
                    cache_en = 1'b1;
                    cache_wr = 1'b1;
                    offset = 3'b100;

                    mem_rd = 1'b1;
                    mem_addr = mem_addr_offset[3];
                    

                    stall_inc = 16'h0004;
                    nxt_state = 16'd4; //Stall 
                end

                16'd8: begin // Write Offset 3
                    cache_en = 1'b1;
                    cache_wr = 1'b1;
                    offset = 3'b110;

                    nxt_state = 16'd2; //Output data and reset statemachine 
                end

            /* CACHE WRITE SM*/

            16'd20: begin // Check cache
                cache_en = 1'b1;
                comp = 1'b1;

                nxt_state = hit ? 16'd21 : /* WRITE CACHE MISS */;
            end

            16'd21: begin // Write to cache
                //Write to default offset and index
                cache_en = 1'b1;
                cache_wr = 1'b1;
                
            end

        endcase 
    end 

    cla16b stallInc(.sum(stalling), .cOut(), .inA(nxt_state), .inB(stall_inc), .cIn(1'b0));
    dff stateReg(.q(state), d(nxt_state), clk(clk), rst(rst));

endmodule