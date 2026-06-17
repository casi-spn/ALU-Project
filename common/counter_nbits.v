`timescale 1ns/1ps
module counter_nbits #(parameter WIDTH = 2)
   (
    input              clk,
    input              rst_n,
    input              en,
    output [WIDTH-1:0] count
    );

   wire [WIDTH-1:0] q;
   wire [WIDTH-1:0] t;   // toggle enable per bit
   wire [WIDTH-1:0] d;   // next state into each flip-flop

   assign t[0] = en;
   xorn_gate #(1) x0 (.a(q[0]), .b(t[0]), .y(d[0]));
   dff       f0 (.clk(clk), .rst_n(rst_n), .d(d[0]), .q(q[0]));

   genvar i;
   generate
      for (i = 1; i < WIDTH; i = i + 1) begin : gen_ff
         and2_gate     a_i (.a(t[i-1]), .b(q[i-1]), .y(t[i]));
         xorn_gate #(1) x_i (.a(q[i]), .b(t[i]), .y(d[i]));
         dff           f_i (.clk(clk), .rst_n(rst_n), .d(d[i]), .q(q[i]));
      end
   endgenerate

   assign count = q;
endmodule // counter_nbits
