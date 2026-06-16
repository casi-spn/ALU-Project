module divider_8bit(
    input [7:0] A,          // dividend (positive only)
    input [7:0] B,          // divisor (positive only)
    output [7:0] quotient,
    output [7:0] remainder
);

assign quotient  = A / B;
assign remainder = A % B;

endmodule
