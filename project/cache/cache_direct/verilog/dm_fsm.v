
module dm_fsm(  // Outputs
            mem_addr, mem_wr, mem_rd, cache_en, cache_tag, cache_index,
            offset, cache_data_wr, cache_wr, comp, valid_in, sel,
            done, CacheHit, stall_out,
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
            tag_in,
            hit,
            dirty,
            valid,
            write_sel,

            clk, rst
            );


    output reg [15:0] mem_addr; 
    output wire [15:0] cache_data_wr;
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

    input wire [15:0] addr,
                      data;
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

    // wire[15:0] data_out;
    assign cache_data_wr = data;

    /*
    offset
    110 100 010 000 

    */
    wire[15:0] state, stalling;
    reg[15:0]  stall_inc, nxt_state;
    /* State list

    1 -> 19 Read
    20 ->

    0/default   = rst/idle state

    1           = Check cache
    2           = Read Cache hit

    3           = Read memory index w/ offset 0
    4           = R/W stall  
    5           = Read memory index w/ offset 1 | Write Cache w/ offset 0
    6           = Read memory index w/ offset 2 | Write Cache w/ offset 1
    7           = Read memory index w/ offset 3 | Write Cache w/ offset 2
    8           = Write Cache w/ offset 3

    9           = Check dirty bit for READ
    10          = DIRTY | Write cache to memory
    11          =    

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
        stall_inc = 16'h0000;
        stall_out= 1'b0;
        
        write_sel = 1'b1;
        done = 1'b0;
        nxt_state = 16'd0;      // Loop default state
        case(state)
            default: begin // Default/Idle case
                nxt_state = wr  ?  16'd20 : ((rd & (~hit | ~valid))? 16'd1: 16'd0);

                stall_out = wr|rd ? 1'b1: 1'b0;
                comp = 1'b1;
                cache_en = rd ? 1'b1 : 1'b0;
                done = (rd & hit & valid) ? 1'b1 : 1'b0;
                CacheHit = (rd & hit & valid) ? 1'b1: 1'b0; 
            end
            
            /* ----- CACHE READ FSM ----- */
            16'd1: begin // Cache miss | Check valid & dirty 
                cache_en = 1'b1;
                comp = 1'b1;        
                stall_out = 1'b1;
                
                nxt_state = valid & dirty ? 16'd11 : 16'd3;
            end

            16'd2: begin // Cache miss fsm reset
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

                //Yeah the ternaries aren't needed, but I find it easier to read
                cache_wr = (hit & valid) ? 1'b1 : 1'b0;
                done = (hit  & valid) ? 1'b1 : 1'b0;
                CacheHit = (hit & valid)? 1'b1 : 1'b0;
                stall_out = 1'b1;
            end

            16'd21: begin // Write to cache
                //Write data to default offset and index
                cache_en = 1'b1;
                cache_wr = 1'b1;
                comp = 1'b1;

                stall_out = 1'b1;
                valid_in = 1'b1;
                done = 1'b1;
            end


                /* DIRTY BIT MEMORY CHECK */
                16'd9: begin   //Check dirty bit
                    comp = 1'b1;
                    cache_en = 1'b1;
                    nxt_state = dirty ? 16'd11: 16'd3;
                    stall_out = 1'b1;
                end

                /* WRITE CACHE LINE TO MEMORY*/
                /* Also done as part of write to cache*/

                16'd10: begin   //Stall
                    // nxt_state = |busy ? 16'd10 : stalling;
                    // stall_out = 1'b1;
                    nxt_state = |busy ? 16'd10 : 16'd3;
                    stall_out = 1'b1;
                end

                16'd11: begin  //Write offset 0
                    cache_en = 1'b1;
                    offset = 3'b000;

                    mem_addr = mem_addr_wb[0];
                    mem_wr = 1'b1;//|busy ? 1'b0 : 1'b1;

                    stall_inc = 16'd1;
                    stall_out = 1'b1;
                    nxt_state = 16'd12;//|busy ? 16'd11: 16'd12;/*stall*/
                end

                16'd12: begin  //Write offset 1
                    cache_en = 1'b1;
                    offset = 3'b010;

                    mem_addr = mem_addr_wb[1];
                    mem_wr = 1'b1;//|busy ? 1'b0 : 1'b1;

                    stall_out = 1'b1;
                    stall_inc = 16'd2;
                    nxt_state = 16'd13;//|busy ? 16'd12: 16'd13;/*stall*/
                end

                16'd13: begin  //Write offset 2
                    cache_en = 1'b1;
                    offset = 3'b100;

                    mem_addr = mem_addr_wb[2];
                    mem_wr = 1'b1;//|busy ? 1'b0 : 1'b1;

                    stall_out = 1'b1;
                    stall_inc = 16'd3;
                    nxt_state = 16'd14;//|busy ? 16'd13: 16'd14;/*stall*/
                end

                16'd14: begin  //Write offset 3
                    cache_en = 1'b1;
                    offset = 3'b110;

                    mem_addr = mem_addr_wb[3];
                    mem_wr = 1'b1;//|busy ? 1'b0 : 1'b1;

                    stall_out = 1'b1;
                    stall_inc = 16'd4;
                    nxt_state = 16'd3;//|busy ? 16'd14 : 16'd3;
                end

                /* WRITE MEMORY TO CACHE LINE */
                16'd4: begin // Miss stalls
                    offset = 3'b000;
                    write_sel = 1'b0;

                    stall_out = 1'b1;
                    nxt_state = stalling; 
                end

                16'd3 : begin // Cache Miss, read index 0 
                    cache_en = 1'b1;
                    mem_rd = ((addr[2:1] == 2'b00) & wr) ? 1'b0 : 1'b1;
                    mem_addr = mem_addr_offset[0];
                    
                    write_sel = 1'b0;
                    stall_out = 1'b1;
                    nxt_state = ((addr[2:1] == 2'b00) & wr) ? 16'd5 : 16'd4;
                    stall_inc = 16'h0001;
                end

                16'd5: begin // Read offset 1
                    //Write to offset 0
                    cache_en = 1'b1;
                    cache_wr = 1'b1;
                    offset = 3'b000;

                    mem_rd = ((addr[2:1] == 2'b01) & wr) ? 1'b0 : 1'b1;
                    mem_addr = mem_addr_offset[1];

                    write_sel = 1'b0;
                    stall_out = 1'b1;
                    nxt_state = ((addr[2:1] == 2'b01) & wr) ? 16'd6 : 16'd4;//Stall 
                    stall_inc = 16'h0002;
                end

                16'd6: begin // Read offset 2
                    //Write to offset 1
                    cache_en = 1'b1;
                    cache_wr = 1'b1;
                    offset = 3'b010;

                    mem_rd = ((addr[2:1] == 2'b10) & wr) ? 1'b0 : 1'b1;
                    mem_addr = mem_addr_offset[2];
                    
                    write_sel = 1'b0;
                    stall_out = 1'b1;
                    nxt_state = ((addr[2:1] == 2'b10) & wr) ? 16'd7 : 16'd4; //Stall 
                    stall_inc = 16'h0003;
                end

                16'd7: begin // Read offset 3
                    //Write to offset 2
                    cache_en = 1'b1;
                    cache_wr = 1'b1;
                    offset = 3'b100;

                    mem_rd = ((addr[2:1] == 2'b11) & wr) ? 1'b0 : 1'b1;
                    mem_addr = mem_addr_offset[3];
                    
                    write_sel = 1'b0;
                    stall_out = 1'b1;
                    nxt_state = ((addr[2:1] == 2'b11) & wr) ? 16'd8 : 16'd4; //Stall 
                    stall_inc = 16'h0004;
                end

                16'd8: begin // Write offset 3
                    cache_en = 1'b1;
                    cache_wr = 1'b1;
                    offset = 3'b110;

                    // If we're reading, we can return to reset/idle
                    // If we're writing, we write to new cache line
                    write_sel = 1'b0;
                    stall_out = 1'b1;
                    nxt_state = rd ? 16'd2 : 16'd21; //reset statemachine 
                end

        endcase 
    end 

    cla16b stallInc(.sum(stalling), .cOut(), .inA(nxt_state), .inB(stall_inc), .cIn(1'b0));
    dff_16b stateReg(.q(state), .err(), .d(nxt_state), .clk(clk), .rst(rst));


endmodule