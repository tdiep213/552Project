/*
   CS/ECE 552 Spring '22
  
   Filename        : memory.v
   Description     : This module contains all components in the Memory stage of the 
                     processor.
*/
`default_nettype none
module memory (data_out, data_in, addr, enable, wr, createdump, Halt, clk, rst);

   // TODO: Your code here
   output wire [15:0] data_out;
   input wire [15:0] data_in, addr;
   input wire enable, wr, clk, rst, createdump, Halt;

/*
   | Enable | Wr |    Function   | data_out |
   ------------------------------------------
   |   0    | X  |     No Op     |    0     |
   ------------------------------------------
   |   1    | 0  |      Read     | M[addr]  |
   ------------------------------------------
   |   1    | 1  | Write data_in |    0     |
   ------------------------------------------
*/
   wire[15:0] mem_out;
   wire en;
   assign data_out = (~enable | wr) ? 16'h0000 : mem_out;

   assign en = Halt ? 0 : enable;

   memory2c DATA_MEM ( .data_out   (mem_out), 
                       .data_in    (data_in), 
                       .addr       (addr), 
                       .enable     (en), 
                       .wr         (wr), 
                       .createdump (createdump), 
                       .clk        (clk), 
                       .rst        (rst));

endmodule
`default_nettype wire
