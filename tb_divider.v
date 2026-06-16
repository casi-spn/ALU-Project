module tb_divider;

reg [7:0] A;
reg [7:0] B;

wire [7:0] quotient;
wire [7:0] remainder;
wire div_by_zero;

divider_8bit uut(
    .A(A),
    .B(B),
    .quotient(quotient),
    .remainder(remainder),
    .div_by_zero(div_by_zero)
);

initial begin
    // 20 / 4 = 5 rem 0
    A = 8'd20; B = 8'd4; #10;

    // 17 / 5 = 3 rem 2
    A = 8'd17; B = 8'd5; #10;

    // 255 / 10 = 25 rem 5
    A = 8'd255; B = 8'd10; #10;

    // 0 / 5 = 0 rem 0
    A = 8'd0; B = 8'd5; #10;

    // 100 / 7 = 14 rem 2
    A = 8'd100; B = 8'd7; #10;

    // division by zero
    A = 8'd10; B = 8'd0; #10;

    $stop;
end

endmodule
