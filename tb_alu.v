module tb_alu;

reg [7:0] A;
reg [7:0] B;
reg [3:0] operation;

wire [7:0] result;
wire [7:0] quotient;
wire [7:0] remainder;
wire carry_out;
wire Z;  // Zero flag
wire N;  // Negative flag
wire V;  // Overflow flag

alu uut(
    .A(A),
    .B(B),
    .operation(operation),
    .result(result),
    .quotient(quotient),
    .remainder(remainder),
    .carry_out(carry_out),
    .Z(Z),
    .N(N),
    .V(V)
);

endmodule
