module tb_alu;

reg [7:0] A;
reg [7:0] B;
reg [1:0] operation;

wire [7:0] result;
wire carry_out;
wire Z;  // Zero flag
wire N;  // Negative flag
wire V;  // Overflow flag

alu uut(
    .A(A),
    .B(B),
    .operation(operation),
    .result(result),
    .carry_out(carry_out),
    .Z(Z),
    .N(N),
    .V(V)
);

endmodule
