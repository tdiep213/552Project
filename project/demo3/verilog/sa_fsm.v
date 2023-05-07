module sa_fsm(   // Outputs
               //PROC
            CacheHit, stall_out, done,
               //MEM
            mem_addr, mem_wr, mem_rd,
            
               //CACHE
            comp,
            cache_tag, cache_index, offset,
            cache_data_wr, valid_in,
            
               //CACHE 1
            cache1_en,  cache1_wr,
               //CACHE 2
            cache2_en,  cache2_wr,
              
            sel, 
            write_sel,

            // Inputs
               //PROC
            addr,
            data,
            rd,
            wr,
               //MEM
            stall,
            busy,
               //CACHE1
            tag1_in,
            hit1,
            dirty1,
            valid1,
               //CACHE2
            tag2_in,
            hit2,
            dirty2,
            valid2,

            clk, rst);


    output reg [15:0] mem_addr; 
    output wire [15:0] cache_data_wr;
    output wire [7:0]  cache_index;
    output wire [4:0] cache_tag;
    output reg [2:0] offset;
    output reg  comp, 
                valid_in, 
                sel, 
                cache1_wr, cache2_wr, 
                cache1_en, cache2_en, 
                mem_wr, 
                mem_rd,
                done,
                CacheHit,
                write_sel,
                stall_out;

    input wire [15:0] addr,
                      data;
    input wire [4:0] tag1_in, tag2_in;
    input wire [3:0] busy;
    input wire rd, 
               wr, 
               stall, 
               hit1,
               dirty1,
               valid1,
               hit2,
               dirty2, 
               valid2;
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

    wire [4:0] tag;
    assign mem_addr_wb[0] = {tag, cache_index, 3'b000}; 
    assign mem_addr_wb[1] = {tag, cache_index, 3'b010}; 
    assign mem_addr_wb[2] = {tag, cache_index, 3'b100}; 
    assign mem_addr_wb[3] = {tag, cache_index, 3'b110}; 

    
    // wire[15:0] data_out;
    assign cache_data_wr = data;

    wire victim, write_victim; // 0 - Cache1, 1 - Cache2
    reg  nxt_victim, set_victim;
    assign write_victim = set_victim ? nxt_victim : victim;

    assign tag = victim ? tag2_in : tag1_in;
    /*
    offset
    110 100 010 000 

    */
    wire[15:0] state;
    reg[15:0]  nxt_state;

    wire dirty, valid;
    assign dirty = victim ? dirty2 : dirty1;
    assign valid = victim ? valid2 : valid1;
    /* State list
    0/default   = rst/idle state

    1           = Check Cache Hit/Miss
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
        cache1_en = 1'b0;        // Cache disabled
        cache2_en = 1'b0;
        cache1_wr = 1'b0;        // Don't write to cache
        cache2_wr = 1'b0; 
        comp = 1'b0;            // Don't do cache tag comparison
        offset = addr[2:0];     // Default read offset
        valid_in = 1'b1; 

        mem_rd = 1'b0;          // Don't read from memory
        mem_wr = 1'b0;          // Don't write to memory
        mem_addr = mem_addr_offset[4];  //Default memory read/write address

        // sel = 1'b0;             // Output from cache1 
        stall_out= 1'b0;
        
        write_sel = 1'b1;       // Cache data in from processor
        done = 1'b0;
        nxt_state = 16'd0;      // Loop default state
        set_victim = 1'b0;
        case(state)
            default: begin // Default/Idle case
                nxt_state = wr  ?  16'd20 : (rd ? 16'd1: 16'd0);
                stall_out = wr|rd ? 1'b1: 1'b0;
            end
            
            /* ----- CACHE READ FSM ----- */
            16'd1: begin // Check cache
                //If either cache hits, we just automatically read from them  
                cache1_en = 1'b1;
                cache2_en = 1'b1;      
                comp = 1'b1;
                
                nxt_victim = ~victim;

                sel = (hit1 & valid1) ? 1'b0 : (hit2 & valid2) ? 1'b1 : victim;
                done = (hit1 & valid1) | (hit2 & valid2);
                CacheHit = (hit1 & valid1) | (hit2 & valid2);

                comp = 1'b1;
                
                stall_out = ~((hit1 & valid1) | (hit2 & valid2));
                nxt_state = ((hit1 & valid1) | (hit2 & valid2)) ? 16'd0 :  16'd9;  
                 
            end

            16'd2: begin // Cache Read miss | FSM reset
                cache1_en = ~victim;
                cache2_en = victim;

                nxt_state = 16'd0;    //Reset FSM
                CacheHit = 1'b0;
                done = 1'b1;           
                set_victim = 1'b1;     
            end


            /* ----- CACHE WRITE ----- */
            16'd20: begin // Check cache
                nxt_victim = ~victim;

                cache1_en = 1'b1;
                cache2_en = 1'b1;
                comp = 1'b1;

                sel = (hit1 & valid1) ? 1'b0 : (hit2 & valid2) ? 1'b1 : victim;
                nxt_state = (hit1 & valid1) | (hit2 & valid2)  ? 16'd0: 16'd9/* WRITE CACHE MISS */;

                //Write to cache
                cache1_wr = (hit1 & valid1);
                cache2_wr = (hit2 & valid2);
                done = (hit1 & valid1) | (hit2 & valid2);
                CacheHit = (hit1 & valid1) | (hit2 & valid2);
                stall_out = 1'b1;
            end

            16'd21: begin 
                //Write Cache miss | write to cache
                //Write data to default offset and index
                cache1_en = ~victim;
                cache2_en = victim;
                cache1_wr = ~victim;
                cache2_wr = victim;
                comp = 1'b1;

                stall_out = 1'b1;
                valid_in = 1'b1;
                done = 1'b1;
                set_victim = 1'b1;
            end


                /* DIRTY BIT MEMORY CHECK */
                16'd9: begin   //Check dirty bit
                    comp = 1'b1;
                    cache1_en = ~victim;
                    cache2_en = victim;
                    nxt_state = (dirty & valid) ? 16'd11: 16'd3;
                    stall_out = 1'b1;
                end

                /* WRITE CACHE LINE TO MEMORY*/
                /* Also done as part of write to cache*/


                //Write Victim Cache Line w/ offset 0 to corresponding memory location
                16'd11: begin  
                    cache1_en = ~victim;
                    cache2_en = victim;
                    offset = 3'b000;

                    mem_addr = mem_addr_wb[0];
                    mem_wr = 1'b1;

                    stall_out = 1'b1;
                    nxt_state = 16'd12;
                end

                //Write Cache Line w/ offset 1 to corresponding memory location
                16'd12: begin 
                    cache1_en = ~victim;
                    cache2_en = victim;
                    offset = 3'b010;

                    mem_addr = mem_addr_wb[1];
                    mem_wr =  1'b1;

                    stall_out = 1'b1;
                    nxt_state = 16'd13;/*stall*/
                end

                //Write Cache Line w/ offset 2 to corresponding memory location
                16'd13: begin 
                    cache1_en = ~victim;
                    cache2_en = victim;
                    offset = 3'b100;

                    mem_addr = mem_addr_wb[2];
                    mem_wr = 1'b1;

                    stall_out = 1'b1;
                    nxt_state = 16'd14;/*stall*/
                end

                //Write Cache Line w/ offset 3 to corresponding memory location
                16'd14: begin  
                    cache1_en = ~victim;
                    cache2_en = victim;
                    offset = 3'b110;

                    mem_addr = mem_addr_wb[3];
                    mem_wr = 1'b1;

                    stall_out = 1'b1;
                    nxt_state = 16'd3;
                end

                /* WRITE MEMORY TO CACHE LINE */


                16'd3 : begin
                    //Read Memory offset 0
                    cache1_en = ~victim;
                    cache2_en = victim;

                    mem_rd = ~((addr[2:1] == 2'b00) & wr);
                    mem_addr = mem_addr_offset[0];
                    
                    stall_out = 1'b1;
                    nxt_state = 16'd4;
                end

                16'd4: begin 
                    // Read offset 1
                    cache1_en = ~victim;
                    cache2_en = victim;

                    mem_rd = ~((addr[2:1] == 2'b01) & wr);
                    mem_addr = mem_addr_offset[1];

                    stall_out = 1'b1;
                    nxt_state =16'd5;
                end

                16'd5: begin 
                    // Read offset 2
                    //Write to offset 0
                    cache1_en = ~victim;
                    cache2_en = victim;
                    cache1_wr = ~victim & ~((addr[2:1] == 2'b00) & wr);
                    cache2_wr = victim  & ~((addr[2:1] == 2'b00) & wr);

                    offset = 3'b000;

                    mem_rd = ~((addr[2:1] == 2'b10) & wr);
                    mem_addr = mem_addr_offset[2];
                    
                    write_sel = 1'b0;
                    stall_out = 1'b1;
                    nxt_state = 16'd6;
                end

                16'd6: begin 
                    // Read offset 3
                    //Write to offset 1
                    cache1_en = ~victim;
                    cache2_en = victim;
                    cache1_wr = ~victim & ~((addr[2:1] == 2'b01) & wr);
                    cache2_wr = victim & ~((addr[2:1] == 2'b01) & wr);

                    offset = 3'b010;

                    mem_rd = ~((addr[2:1] == 2'b11) & wr);
                    mem_addr = mem_addr_offset[3];
                    
                    write_sel = 1'b0;
                    stall_out = 1'b1;
                    nxt_state = 16'd7;
                end

                16'd7: begin 
                    // Write offset 2
                    cache1_en = ~victim;
                    cache2_en = victim;
                    cache1_wr = ~victim & ~((addr[2:1] == 2'b10) & wr);
                    cache2_wr = victim & ~((addr[2:1] == 2'b10) & wr);
                    offset = 3'b100;

                    write_sel = 1'b0;
                    stall_out = 1'b1;
                    nxt_state = 16'd8;
                end

                16'd8: begin 
                    // Write offset 3
                    cache1_en = ~victim;
                    cache2_en = victim;
                    cache1_wr = ~victim & ~((addr[2:1] == 2'b11) & wr);
                    cache2_wr = victim  & ~((addr[2:1] == 2'b11) & wr);
                    offset = 3'b110;

                    // If we're reading, we can return to reset/idle
                    // If we're writing, we write to new cache line
                    write_sel = 1'b0;
                    stall_out = 1'b1;
                    nxt_state = rd ? 16'd2 : 16'd21; //reset statemachine 
                end

        endcase 
    end 

    dff vic(.q(victim), .d(write_victim), .clk(clk), .rst(rst));
   
    dff_16 stateReg(.q(state), .err(), .d(nxt_state), .clk(clk), .rst(rst));


endmodule