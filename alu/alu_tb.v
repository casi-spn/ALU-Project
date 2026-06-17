`timescale 1ns/1ps
module tb_alu;

reg        clk;
reg        rst_n;
reg        start;
reg [7:0]  A;
reg [7:0]  B;
reg [3:0]  operation;

wire        done;
wire [7:0]  result;
wire [7:0]  quotient;
wire [7:0]  remainder;
wire        carry_out;
wire        Z;  // Zero flag
wire        N;  // Negative flag
wire        V;  // Overflow flag

alu uut(
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .A(A),
    .B(B),
    .operation(operation),
    .done(done),
    .result(result),
    .quotient(quotient),
    .remainder(remainder),
    .carry_out(carry_out),
    .Z(Z),
    .N(N),
    .V(V)
);

initial clk = 1'b0;
always #5 clk = ~clk;

// Reset only. Test vectors are driven afterwards via `force`, either by
// run_alu_interactive.txt or manually from the ModelSim console.
initial begin
    rst_n = 1'b0;
    A = 8'd0; B = 8'd0; operation = 4'd0; start = 1'b0;
    @(negedge clk);
    @(negedge clk);
    rst_n = 1'b1;
end

endmodule
