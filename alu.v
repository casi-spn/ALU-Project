module alu(
    input [7:0] A,
    input [7:0] B,
    input [2:0] operation,  // 000: ADD, 001: SUBTRACT, 011: DIVIDE
    output [7:0] result,
    output [7:0] quotient,
    output [7:0] remainder,
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

// Instantiate divider
divider_8bit divider(
    .A(A),
    .B(B),
    .quotient(quotient),
    .remainder(remainder)
);

// Select operation based on control signal
assign result = (operation == 3'd0) ? add_result :
                (operation == 3'd1) ? sub_result :
                (operation == 3'd3) ? quotient   :
                8'b0;

assign carry_out = (operation == 3'd0) ? add_cout :
                   (operation == 3'd1) ? sub_cout :
                   1'b0;

// Status Flags
assign Z = (result == 8'b0) ? 1'b1 : 1'b0;
assign N = result[7];

// Overflow flag (only meaningful for ADD/SUB)
assign V = (operation == 3'd0) ?
           ((A[7] == B[7]) && (A[7] != add_result[7])) :
           (operation == 3'd1) ?
           ((A[7] != B[7]) && (A[7] != sub_result[7])) :
           1'b0;

endmodule
