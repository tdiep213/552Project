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
   
   output reg [15:0] DataOut;
   output reg        Done;
   output reg        Stall;
   output reg        CacheHit;
   output reg        err;

   /* data_mem = 1, inst_mem = 0 *
    * needed for cache parameter */
   parameter memtype = 0;

   wire mem_rd, mem_wr, busy; 
   wire[15:0] mem_addr, mem_data_out;

   wire cache_en, write, valid_in, comp;
   wire[15:0] cache_data_out, cache_data_in;

   wire[7:0] cache_index;
   wire[4:0] cache_tag;
   wire[2:0] offset; 

   wire sel;

   dm_fsm f0(  // Outputs
            .mem_addr(mem_addr), .mem_wr(mem_wr), .mem_rd(mem_rd),
            .cache_en(cache_en), .cache_tag(cache_tag), .cache_index(cache_index),
            .offset(offset), .cache_data_wr(cache_data_in), .cache_wr(write),
            .comp(comp), .valid_in(valid_in), .sel(sel),
            // Inputs
               //PROC
            .addr(Addr),
            .data(DataIn),
            .rd(Rd),
            .wr(Wr),
               //MEM
            .stall   (Stall),
            .busy    (busy),
               //CACHE
            .hit(hit),
            .dirty(dirty),
            .valid(valid)
            );


   cache #(0 + memtype) c0(// Outputs
                          .tag_out              (tag),
                          .data_out             (cache_data_out),
                          .hit                  (hit),
                          .dirty                (dirty),
                          .valid                (valid),
                          .err                  (err),
                          // Inputs
                          .enable               (cache_en),
                          .clk                  (clk),
                          .rst                  (rst),
                          .createdump           (),
                          .tag_in               (cache_tag),
                          .index                (cache_index),
                          .offset               (offset),
                          .data_in              (cache_data_in),
                          .comp                 (comp),
                          .write                (write),
                          .valid_in             (valid_in));

   four_bank_mem mem(// Outputs
                     .data_out          (mem_data_out),
                     .stall             (Stall),
                     .busy              (busy),
                     .err               (),
                     // Inputs
                     .clk               (clk),
                     .rst               (rst),
                     .createdump        (),
                     .addr              (mem_addr),
                     .data_in           (cache_data_out),
                     .wr                (mem_wr),
                     .rd                (mem_rd));
   
   // your code here

   assign dataOut = sel ? mem_data_out : cache_data_out;
   
endmodule // mem_system
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :9:
