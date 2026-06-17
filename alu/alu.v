module alu(
    input clk,
    input rst_n,
    input start,             // pulse for 1 cycle to begin MULTIPLY; ignored by all other ops
    input [7:0] A,
    input [7:0] B,
    input [3:0] operation,  // 0000: ADD, 0001: SUBTRACT, 0010 MULTIPLICATION, 0011: DIVIDE, 0100 AND, 0101 OR, 0110 XOR, 0111 LEFT SHIFT, 1000 RIGHT SHIFT
    output done,             // 1 when result is valid; combinational ops are always done, MULTIPLY pulses this once the Booth FSM finishes
    output [7:0] result,     // for MULTIPLY: low byte of the 16-bit product (high byte appears on remainder)
    output [7:0] quotient,
    output [7:0] remainder,
    output carry_out,
    output Z,  // Zero flag
    output N,  // Negative flag (sign bit)
    output V   // Overflow flag
);

wire [7:0] add_result, sub_result, and_result, or_result, xor_result, left_shift_result, right_shift_result;
wire add_cout, sub_cout;
wire [15:0] mult_product;
wire mult_done;
wire mult_start = start && (operation == 4'd2);

// Instantiate multiplier (radix-4 Booth, multi-cycle)
mult_unit multiplier(
    .clk(clk),
    .rst_n(rst_n),
    .start(mult_start),
    .A(A),
    .B(B),
    .done(mult_done),
    .product(mult_product)
);

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
wire [7:0] div_quotient, div_remainder;
divider_8bit divider(
    .A(A),
    .B(B),
    .quotient(div_quotient),
    .remainder(div_remainder)
);

assign quotient  = (operation == 4'd3) ? div_quotient  : 8'b0;
assign remainder = (operation == 4'd2) ? mult_product[15:8] :
                   (operation == 4'd3) ? div_remainder  : 8'b0;

// Instantiate and/or/xor (bit-sliced from gate primitives in gates.v)
genvar gi;
generate
    for (gi = 0; gi < 8; gi = gi + 1) begin : bitwise_gates
        and2_gate  and_inst (.a(A[gi]), .b(B[gi]), .y(and_result[gi]));
        or2_gate   or_inst  (.a(A[gi]), .b(B[gi]), .y(or_result[gi]));
        xorn_gate #(1) xor_inst (.a(A[gi]), .b(B[gi]), .y(xor_result[gi]));
    end
endgenerate

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
                (operation == 4'd2) ? mult_product[7:0] :
                (operation == 4'd3) ? div_quotient      :
                (operation == 4'd4) ? and_result        :
                (operation == 4'd5) ? or_result         :
                (operation == 4'd6) ? xor_result        :
                (operation == 4'd7) ? left_shift_result :
                (operation == 4'd8) ? right_shift_result:
                8'b0;

assign carry_out = (operation == 4'd0) ? add_cout :
                   (operation == 4'd1) ? sub_cout :
                   1'b0;

// done: combinational ops settle immediately; MULTIPLY needs the Booth FSM
assign done = (operation == 4'd2) ? mult_done : 1'b1;

// Status Flags
assign Z = (result == 8'b0) ? 1'b1 : 1'b0;
assign N = result[7];

// Overflow flag (meaningful for ADD/SUB/MULTIPLY/DIVIDE)
assign V = (operation == 4'd0) ?
           ((A[7] == B[7]) && (A[7] != add_result[7])) :
           (operation == 4'd1) ?
           ((A[7] != B[7]) && (A[7] != sub_result[7])) :
           (operation == 4'd2) ?
           (mult_product[15:7] != {9{mult_product[7]}}) :
           (operation == 4'd3) ?
           (B == 8'd0) :
           1'b0;

endmodule
