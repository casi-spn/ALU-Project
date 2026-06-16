module tb_subtractor;

reg signed [7:0] A;
reg signed [7:0] B;

wire signed [7:0] diff;
wire cout;

subtractor_8bit uut(A, B, diff, cout);

initial begin
    $monitor("A=%d B=%d diff=%d cout=%b", A, B, diff, cout);

    A = 8'd10;  B = 8'd5;    #10; // 5
    A = 8'd20;  B = 8'd15;   #10; // 5
    A = 8'd50;  B = 8'd100;  #10; // -50

    $stop;
end

endmodule