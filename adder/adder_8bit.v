module adder_8bit(
    input [7:0] A,
    input [7:0] B,
    output [7:0] sum,
    output cout
);

wire [8:0] carry;

assign carry[0] = 0;

full_adder FA0(A[0], B[0], carry[0], sum[0], carry[1]);
full_adder FA1(A[1], B[1], carry[1], sum[1], carry[2]);
full_adder FA2(A[2], B[2], carry[2], sum[2], carry[3]);
full_adder FA3(A[3], B[3], carry[3], sum[3], carry[4]);
full_adder FA4(A[4], B[4], carry[4], sum[4], carry[5]);
full_adder FA5(A[5], B[5], carry[5], sum[5], carry[6]);
full_adder FA6(A[6], B[6], carry[6], sum[6], carry[7]);
full_adder FA7(A[7], B[7], carry[7], sum[7], carry[8]);

assign cout = carry[8];

endmodule