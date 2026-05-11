module alu(
    input [7:0] A,
    input [7:0] B,
    input [1:0] operation,  // 00: ADD, 01: SUBTRACT, 10: reserved, 11: reserved
    output [7:0] result,
    output carry_out,
    output Z,  // Zero flag
    output N,  // Negative flag (sign bit)
    output V   // Overflow flag
);

wire [7:0] add_result, sub_result;
wire add_cout, sub_cout;

// Instantiate adder
adder_8bit adder(
    .A(A),
    .B(B),
    .sum(add_result),
    .cout(add_cout)
);

// Instantiate subtractor
subtractor_8bit subtractor(
    .A(A),
    .B(B),
    .diff(sub_result),
    .cout(sub_cout)
);

// Select operation based on control signal
assign result = (operation == 2'b00) ? add_result :
                (operation == 2'b01) ? sub_result :
                8'b0;

assign carry_out = (operation == 2'b00) ? add_cout :
                   (operation == 2'b01) ? sub_cout :
                   1'b0;

// Status Flags
// Zero Flag: Set if result is zero
assign Z = (result == 8'b0) ? 1'b1 : 1'b0;

// Negative Flag: Set if MSB (sign bit) is 1
assign N = result[7];

// Overflow Flag: Detects signed arithmetic overflow
// For ADD: overflow if signs of A and B are same, but result sign is different
// For SUB: overflow if signs of A and B are different, but result sign is different from A
assign V = (operation == 2'b00) ?
           (A[7] == B[7]) && (A[7] != add_result[7]) :
           (operation == 2'b01) ?
           (A[7] != B[7]) && (A[7] != sub_result[7]) :
           1'b0;

endmodule
