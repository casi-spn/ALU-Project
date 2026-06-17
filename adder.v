`timescale 1ns/1ps
module adder #(parameter WIDTH = 8) (
              input                     cin,
              input  signed [WIDTH-1:0] a,
              input  signed [WIDTH-1:0] b,
              output signed [WIDTH-1:0] sum
              );
   assign sum = a + b + cin;
endmodule
