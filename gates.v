`timescale 1ns/1ps
module and3_gate (input a, input b, input c, output y);
   assign y = (a & b & c);
endmodule // and3_gate

module and2_gate (input a, input b, output y);
   assign y = (a & b);
endmodule // and2_gate

module or2_gate (input a, input b, output y);
   assign y = (a | b);
endmodule // or2_gate

// y = a XOR {WIDTH{b}}. WIDTH=1 -> plain 2-input XOR (counter toggle logic);
// WIDTH=10 -> operand-negation row in front of the adder.
module xorn_gate #(parameter WIDTH = 8)
   (input  [WIDTH-1:0] a,
    input              b,
    output [WIDTH-1:0] y);
   assign y = a ^ {WIDTH{b}};
endmodule // xorn_gate
