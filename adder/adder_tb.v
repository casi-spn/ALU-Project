module tb_adder;

reg signed [7:0] A;
reg signed [7:0] B;

wire signed [7:0] sum;
wire cout;

adder_8bit uut(A, B, sum, cout);

initial begin
    $monitor("A=%d B=%d sum=%d cout=%b", A, B, sum, cout);

    A = 8'd10;   B = 8'd5;   #10; // 15
    A = 8'd20;   B = 8'd15;  #10; // 35
    A = 8'd100;  B = 8'd50;  #10; // -106 because overflow in 8-bit signed

    $stop;
end

endmodule