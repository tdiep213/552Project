/*
   CS/ECE 552 Spring '22
  
   Filename        : memory.v
   Description     : This module contains all components in the Memory stage of the 
                     processor.
*/
`default_nettype none
module memory (/* TODO: Add appropriate inputs/outputs for your memory stage here*/);

   // TODO: Your code here
   output wire [15:0] data_out;
   input wire [15:0] data_in, addr;
   input wire enable, wr, clk, rst, createdump;

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

   memory2c DATA_MEM ( .data_out   (), 
                       .data_in    (), 
                       .addr       (), 
                       .enable     (), 
                       .wr         (), 
                       .createdump (), 
                       .clk        (), 
                       .rst        ());

endmodule
`default_nettype wire
