module gate_or_8bit(
    input [7:0] A,
    input [7:0] B,
    output [7:0] result
);

assign result = A | B;

endmodule
