/* $Author: karu $ */
/* $LastChangedDate: 2009-04-24 09:28:13 -0500 (Fri, 24 Apr 2009) $ */
/* $Rev: 77 $ */

`default_nettype none
module mem_system(/*AUTOARG*/
   // Outputs
   DataOut, Done, Stall, CacheHit, err,
   // Inputs
   Addr, DataIn, Rd, Wr, createdump, clk, rst
   );
   
   input wire [15:0] Addr;
   input wire [15:0] DataIn;
   input wire        Rd;
   input wire        Wr;
   input wire        createdump;
   input wire        clk;
   input wire        rst;
   
   output wire [15:0] DataOut;
   output wire        Done;
   output wire        Stall;
   output wire        CacheHit;
   output reg        err;

   wire mem_rd, mem_wr;
   wire[3:0] busy; 
   wire[15:0] mem_addr, mem_data_out;
   wire mem_stall;

   wire cache1_en, write1, valid_in, comp;
   wire cache2_en, write2;
   wire[15:0] cache1_data_out, cache2_data_out, cache_data_in;

   wire[7:0] cache_index;
   wire[4:0] cache_tag, tag1, tag2;
   wire[2:0] offset; 
   wire hit1, dirty1, valid1;
   wire hit2, dirty2, valid2;

   wire sel;
   wire[15:0] write_cache_data;
   wire write_sel;

   sa_fsm f0(  // Outputs
               //PROC
            .CacheHit(CacheHit), .stall_out(Stall), .done(Done),
               //MEM
            .mem_addr(mem_addr), .mem_wr(mem_wr), .mem_rd(mem_rd),
            
               //CACHE
            .comp(comp),
            .cache_tag(cache_tag), .cache_index(cache_index), .offset(offset),
            .cache_data_wr(cache_data_in), .valid_in(valid_in),
            
               //CACHE 1
            .cache1_en(cache1_en),  .cache1_wr(write1),
               //CACHE 2
            .cache2_en(cache2_en),  .cache2_wr(write2),
              
            .sel(sel), 
            .write_sel(write_sel),

            // Inputs
               //PROC
            .addr(Addr),
            .data(DataIn),
            .rd(Rd),
            .wr(Wr),
               //MEM
            .stall   (mem_stall),
            .busy    (busy),
               //CACHE1
            .tag1_in(tag1),
            .hit1(hit1),
            .dirty1(dirty1),
            .valid1(valid1),
               //CACHE2
            .tag2_in(tag2),
            .hit2(hit2),
            .dirty2(dirty2),
            .valid2(valid2),

            .clk(clk), .rst(rst));

   
   assign write_cache_data = write_sel ? cache_data_in : mem_data_out;
   /* data_mem = 1, inst_mem = 0 *
    * needed for cache parameter */
   parameter memtype = 0;
   cache #(0 + memtype) c0(// Outputs
                          .tag_out              (tag1),
                          .data_out             (cache1_data_out),
                          .hit                  (hit1),
                          .dirty                (dirty1),
                          .valid                (valid1),
                          .err                  (),
                          // Inputs
                          .enable               (cache1_en),
                          .clk                  (clk),
                          .rst                  (rst),
                          .createdump           (),
                          .tag_in               (cache_tag),
                          .index                (cache_index),
                          .offset               (offset),
                          .data_in              (write_cache_data),
                          .comp                 (comp),
                          .write                (write1),
                          .valid_in             (valid_in));
   cache #(2 + memtype) c1(// Outputs
                          .tag_out              (tag2),
                          .data_out             (cache2_data_out),
                          .hit                  (hit2),
                          .dirty                (dirty2),
                          .valid                (valid2),
                          .err                  (),
                          // Inputs
                          .enable               (cache2_en),
                          .clk                  (clk),
                          .rst                  (rst),
                          .createdump           (),
                          .tag_in               (cache_tag),
                          .index                (cache_index),
                          .offset               (offset),
                          .data_in              (write_cache_data),
                          .comp                 (comp),
                          .write                (write2),
                          .valid_in             (valid_in));

   four_bank_mem mem(// Outputs
                     .data_out          (mem_data_out),
                     .stall             (mem_stall),
                     .busy              (busy),
                     .err               (),
                     // Inputs
                     .clk               (clk),
                     .rst               (rst),
                     .createdump        (),
                     .addr              (mem_addr),
                     .data_in           (DataOut),
                     .wr                (mem_wr),
                     .rd                (mem_rd));
   // your code here

 assign DataOut = sel ? cache2_data_out : cache1_data_out;
   
endmodule // mem_system
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :9:
