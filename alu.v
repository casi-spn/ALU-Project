module alu(
    input [7:0] A,
    input [7:0] B,
    input [3:0] operation,  // 0000: ADD, 0001: SUBTRACT, 0010 MULTIPLICATION, 0011: DIVIDE, 0100 AND, 0101 OR, 0110 XOR, 0111 LEFT SHIFT, 1000 RIGHT SHIFT
    output [7:0] result,
    output [7:0] quotient,
    output [7:0] remainder,
    output carry_out,
    output Z,  // Zero flag
    output N,  // Negative flag (sign bit)
    output V   // Overflow flag
);

wire [7:0] add_result, sub_result, and_result, or_result, xor_result, left_shift_result, right_shift_result;
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

// Instantiate and
gate_and_8bit gate_and(
    .A(A),
    .B(B),
    .result(and_result)
);

// Instantiate or
gate_or_8bit gate_or(
    .A(A),
    .B(B),
    .result(or_result)
);

// Instantiate xor
gate_xor_8bit gate_xor(
    .A(A),
    .B(B),
    .result(xor_result)
);

// Instantiate left shift
left_shift_8bit lshift(
    .A(A),
    .B(B),
    .result(left_shift_result)
);

// Instantiate right shift
right_shift_8bit rshift(
    .A(A),
    .B(B),
    .result(right_shift_result)
);

// Select operation based on control signal
assign result = (operation == 4'd0) ? add_result        :
                (operation == 4'd1) ? sub_result        :
                (operation == 4'd2) ? quotient          :
                (operation == 4'd3) ? quotient          :
                (operation == 4'd4) ? and_result        :
                (operation == 4'd5) ? or_result         :
                (operation == 4'd6) ? xor_result        :
                (operation == 4'd7) ? left_shift_result :
                (operation == 4'd8) ? right_shift_result:
                8'b0;

assign carry_out = (operation == 4'd0) ? add_cout :
                   (operation == 4'd1) ? sub_cout :
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
