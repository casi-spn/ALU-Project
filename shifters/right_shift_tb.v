module tb_right_shift;

reg [7:0] A;
reg [7:0] B;

wire [7:0] result;

right_shift_8bit uut(
    .A(A),
    .B(B),
    .result(result)
);

initial begin
    // A = 1000 0000, shift by 1 -> 0100 0000
    A = 8'b10000000; B = 8'd1; #10;

    // A = 1000 0000, shift by 7 -> 0000 0001
    A = 8'b10000000; B = 8'd7; #10;

    // A = 1111 1111, shift by 1 -> 0111 1111 (MSB filled with 0)
    A = 8'b11111111; B = 8'd1; #10;

    // A = 1111 1111, shift by 4 -> 0000 1111
    A = 8'b11111111; B = 8'd4; #10;

    // A = 1010 1010, shift by 1 -> 0101 0101
    A = 8'b10101010; B = 8'd1; #10;

    // A = 0000 0001, shift by 1 -> 0000 0000 (LSB shifted out)
    A = 8'b00000001; B = 8'd1; #10;

    // A = 1011 0101, shift by 0 -> 1011 0101 (no change)
    A = 8'b10110101; B = 8'd0; #10;

    // A = 0000 0000, shift by 5 -> 0000 0000
    A = 8'b00000000; B = 8'd5; #10;

    // A = 0001 0000, shift by 3 -> 0000 0010
    A = 8'b00010000; B = 8'd3; #10;

    $stop;
end

endmodule
