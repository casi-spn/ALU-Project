`timescale 1ns/1ps
module lshift (
               input  [7:0] in,
               output [8:0] out
               );
   assign out = {in, 1'b0};
endmodule // lshift
