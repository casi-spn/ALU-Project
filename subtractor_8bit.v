module subtractor_8bit(
    input [7:0] A,
    input [7:0] B,
    output [7:0] diff,
    output cout
);

wire [7:0] B_comp;
wire [8:0] carry;

assign B_comp = ~B;

assign carry[0] = 1;

full_adder FA0(A[0], B_comp[0], carry[0], diff[0], carry[1]);
full_adder FA1(A[1], B_comp[1], carry[1], diff[1], carry[2]);
full_adder FA2(A[2], B_comp[2], carry[2], diff[2], carry[3]);
full_adder FA3(A[3], B_comp[3], carry[3], diff[3], carry[4]);
full_adder FA4(A[4], B_comp[4], carry[4], diff[4], carry[5]);
full_adder FA5(A[5], B_comp[5], carry[5], diff[5], carry[6]);
full_adder FA6(A[6], B_comp[6], carry[6], diff[6], carry[7]);
full_adder FA7(A[7], B_comp[7], carry[7], diff[7], carry[8]);

assign cout = carry[8];

endmodule