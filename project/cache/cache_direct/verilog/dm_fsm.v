module dm_fsm(  
            // Outputs
                //PROC
            done, CacheHit, stall_out,
                // Memory
            mem_addr, mem_wr, mem_rd, 
                //Cache
            cache_tag, cache_index, offset,
            cache_en, cache_wr,
            valid_in, comp,
                //MEM_SYS
            sel,

            // Inputs
               //PROC
            addr,
            rd,
            wr,
               //MEM
            stall,
            busy,
               //CACHE
            tag_in,
            hit,
            dirty,
            valid,
            write_sel,

            clk, rst
            );


    output reg [15:0] mem_addr; 
    output wire [7:0]  cache_index;
    output wire [4:0] cache_tag;
    output reg [2:0] offset;
    output reg cache_wr, 
                comp, 
                valid_in, 
                sel, 
                cache_en, 
                mem_wr, 
                mem_rd,
                done,
                CacheHit,
                write_sel,
                stall_out;

    input wire [15:0] addr;
    input wire [4:0] tag_in;
    input wire [3:0] busy;
    input wire rd, 
               wr, 
               stall, 
               hit,
               dirty,
               valid;
    input wire clk, rst;


    assign cache_tag = addr[15:11];
    assign cache_index = addr[10:3];

    wire [15:0] mem_addr_offset[4:0];
    wire [15:0] mem_addr_wb[3:0];

    assign mem_addr_offset[0] = {cache_tag, cache_index, 3'b000}; 
    assign mem_addr_offset[1] = {cache_tag, cache_index, 3'b010};
    assign mem_addr_offset[2] = {cache_tag, cache_index, 3'b100};
    assign mem_addr_offset[3] = {cache_tag, cache_index, 3'b110};

    assign mem_addr_offset[4] = {cache_tag, cache_index, addr[2:0]};

    assign mem_addr_wb[0] = {tag_in, cache_index, 3'b000}; 
    assign mem_addr_wb[1] = {tag_in, cache_index, 3'b010}; 
    assign mem_addr_wb[2] = {tag_in, cache_index, 3'b100}; 
    assign mem_addr_wb[3] = {tag_in, cache_index, 3'b110}; 


    wire[15:0] state;
    reg[15:0]  nxt_state;

    /* State list
    0/default   = rst/idle state

    1           = Read Cache miss | check dirty and valid bits
    2           = Read Cache miss | FSM reset

    3           = Read memory index w/ offset 0
    4           = Read memory index w/ offset 1
    5           = Read memory index w/ offset 2 | Write Cache w/ offset 0
    6           = Read memory index w/ offset 3 | Write Cache w/ offset 1
    7           = Write Cache w/ offset 2
    8           = Write Cache w/ offset 3

    9           = Write Cache miss | check dirty and valid bits

    11          = Write cache line to memory offset 0
    12          = Write cache line to memory offset 1
    13          = Write cache line to memory offset 2
    14          = Write cache line to memory offset 3

    20          = Check cache
    21          = Write to cache
    */
    always @* begin 

        //Default outputs 
        cache_en = 1'b0;        // Cache disabled
        cache_wr = 1'b0;        // Don't write to cache
        comp = 1'b0;            // Don't do cache tag comparison
        offset = addr[2:0];     // Default read offset
        valid_in = 1'b1; 

        mem_rd = 1'b0;          // Don't read from memory
        mem_wr = 1'b0;          // Don't write to memory
        mem_addr = mem_addr_offset[4];  //Default memory read/write address

        sel = 1'b0;             // Output from cache 
        stall_out= 1'b0;
        
        write_sel = 1'b1;
        done = 1'b0;
        nxt_state = 16'd0;      // Loop default state
        case(state)
            default: begin // Default/Idle case
                nxt_state = wr  ?  16'd20 : ((rd & (~hit | ~valid))? 16'd1: 16'd0);

                stall_out = wr|rd;
                comp = 1'b1;
                cache_en = rd;
                done = (rd & hit & valid);
                CacheHit = (rd & hit & valid);
            end
            
            /* ----- CACHE READ FSM ----- */
            16'd1: begin // Cache Read miss | Check valid & dirty 
                cache_en = 1'b1;
                comp = 1'b1;        
                stall_out = 1'b1;
                
                nxt_state = (valid & dirty) ? 16'd11 : 16'd3;
            end

            //Not 100% sure if this is needed lol
            16'd2: begin // Cache Read miss | FSM reset
                cache_en = 1'b1;
                nxt_state = 16'd0;    //Reset FSM
                CacheHit = 1'b0;
                done = 1'b1;                
            end


            /* ----- CACHE WRITE ----- */
            16'd20: begin // Check cache
                cache_en = 1'b1;
                comp = 1'b1;

                nxt_state = (hit & valid) ? 16'd0: 16'd9/* WRITE CACHE MISS */;

                cache_wr = (hit & valid);
                done = (hit  & valid);
                CacheHit = (hit & valid);
                stall_out = 1'b1;
            end

            16'd21: begin 
                // Write to cache
                //Write data to default offset and index
                cache_en = 1'b1;
                cache_wr = 1'b1;
                comp = 1'b1;

                stall_out = 1'b1;
                valid_in = 1'b1;
                done = 1'b1;
            end


                /* DIRTY BIT MEMORY CHECK */
                16'd9: begin   //Cache Miss | Check dirty bit
                    comp = 1'b1;
                    cache_en = 1'b1;
                    nxt_state = (dirty & valid) ? 16'd11: 16'd3;
                    stall_out = 1'b1;
                end

                 /* WRITE CACHE LINE TO MEMORY*/
                /* 
                    Initiates a write request for each of the cache line offsets
                    Only requires stalling logic after final write requiest 
                    due to each offset being contained in seperate memory banks
                    and having the ability to write to seperate banks in parallel 

                    Memory takes 4 cycles to complete a write operation

                    Currently doesn't handle busy memory bank errors
                */

                //Write Cache Line w/ offset 0 to corresponding memory location
                16'd11: begin  
                    cache_en = 1'b1;
                    offset = 3'b000;

                    mem_addr = mem_addr_wb[0];
                    mem_wr = 1'b1;

                    stall_out = 1'b1;
                    nxt_state = 16'd12;
                end

                //Write Cache Line w/ offset 1 to corresponding memory location
                16'd12: begin  
                    cache_en = 1'b1;
                    offset = 3'b010;

                    mem_addr = mem_addr_wb[1];
                    mem_wr = 1'b1;

                    stall_out = 1'b1;
                    nxt_state = 16'd13;
                end

                //Write Cache Line w/ offset 2 to corresponding memory location
                16'd13: begin  
                    cache_en = 1'b1;
                    offset = 3'b100;

                    mem_addr = mem_addr_wb[2];
                    mem_wr = 1'b1;

                    stall_out = 1'b1;
                    nxt_state = 16'd14;
                end

                //Write Cache Line w/ offset 3 to corresponding memory location
                16'd14: begin 
                    cache_en = 1'b1;
                    offset = 3'b110;

                    mem_addr = mem_addr_wb[3];
                    mem_wr = 1'b1;

                    stall_out = 1'b1;
                    nxt_state = 16'd3;
                end

                /* WRITE MEMORY TO CACHE LINE */
                /*
                */

                16'd3 : begin
                    //Read Memory offset 0
                    cache_en = 1'b1;

                    mem_rd = ~((addr[2:1] == 2'b00) & wr);
                    mem_addr = mem_addr_offset[0];
                    

                    stall_out = 1'b1;
                    nxt_state = 16'd4;
                end

                16'd4: begin 
                    //Read Memory offset 1
                    cache_en = 1'b1;

                    mem_rd = ~((addr[2:1] == 2'b01) & wr);
                    mem_addr = mem_addr_offset[1];

                    stall_out = 1'b1;
                    nxt_state = 16'd5;
                end

                16'd5: begin 
                    // Read offset 2
                    //Write to offset 0
                    cache_en = 1'b1;
                    cache_wr = ~((addr[2:1] == 2'b00) & wr);

                    offset = 3'b000;
                    write_sel = 1'b0;

                    mem_rd = ~((addr[2:1] == 2'b10) & wr);
                    mem_addr = mem_addr_offset[2];

                    stall_out = 1'b1;
                    nxt_state = 16'd6; 
                end

                16'd6: begin // Read offset 3
                    //Write to offset 1
                    cache_en = 1'b1;
                    cache_wr = ~((addr[2:1] == 2'b01) & wr);
                    offset = 3'b010;

                    mem_rd = ~((addr[2:1] == 2'b11) & wr);
                    mem_addr = mem_addr_offset[3];
                    
                    write_sel = 1'b0;
                    stall_out = 1'b1; 

                    nxt_state = 16'd7;
                end

                16'd7: begin // Write offset 2
                    cache_en = 1'b1;
                    cache_wr = ~((addr[2:1] == 2'b10) & wr);

                    offset = 3'b100;
                    write_sel = 1'b0;
                    
                    stall_out = 1'b1;
                    nxt_state = 16'd8;
                end

                16'd8: begin // Write offSet 3
                    cache_en = 1'b1;
                    cache_wr = ~((addr[2:1] == 2'b11) & wr);

                    offset = 3'b110;
                    write_sel = 1'b0;
                    
                    // If we're reading, we can return to reset/idle
                    // If we're writing, we write to new cache line
                    stall_out = 1'b1;
                    nxt_state = rd ? 16'd2 : 16'd21; //reset statemachine 
                end
        endcase 
    end 

    dff_16b stateReg(.q(state), .err(), .d(nxt_state), .clk(clk), .rst(rst));


endmodule