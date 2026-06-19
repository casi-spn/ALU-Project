`timescale 1ns/1ps
//--------------------------------------------------------------------------
// div_srt2.v  --  structural SRT-2 (non-restoring) signed-magnitude divider
//
// 8-bit unsigned dividend / 8-bit unsigned divisor -> 8-bit quotient + 8-bit
// remainder.  Built ONLY from existing project modules:
//   register, mux2, counter_nbits, tristate_buffer_bus  (common/)
//   and3_gate, xorn_gate                                (gates/)
//   adder                                               (adder/adder.v)
//   cu_srt2                                             (this folder)
//
// Accumulator A is 10 bits: the worked-out example used 9 (A[8:0]), which only
// divides correctly for divisor <= 127. One extra guard bit makes it correct
// for the full 0..255 range (verified exhaustively for all 256x255 pairs).
//
// Interface mirrors booth.v: load A/Q/M from inbus, drive remainder then
// quotient on outbus; quotient/remainder are also exposed directly so the
// div_unit wrapper can read them at `done`.
//--------------------------------------------------------------------------
module div_srt2 (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       enable,         // start (BEGIN)
    input  wire [7:0] inbus,
    output wire       done,
    output wire       V,              // overflow: division by zero
    output wire [7:0] outbus,
    output wire [7:0] quotient,       // direct read (Q register)
    output wire [7:0] remainder       // direct read (A[7:0])
);
    wire [9:0] c;
    tri  [7:0] output_buffer;

    wire signed [7:0] A_in, Q_in, M_in;
    wire signed [9:0] A_reg, A_reg_in, adder_out;
    wire        [9:0] xor_out, M_reg10;
    wire signed [7:0] Q_reg, M_reg;
    wire              Q_0;
    wire        [2:0] counter_out;
    wire              count_and_out;

    // sign of partial remainder ; quotient bit = ~sign
    wire s = A_reg[9];
    assign Q_0 = ~A_reg[9];

    // division by zero
    assign V = (M_reg == 8'b0);

    // ---- tristate inputs from the shared inbus ----
    tristate_buffer_bus #(8) A_buffer_in (.data_in(inbus), .enable(c[0]), .data_out(A_in));
    tristate_buffer_bus #(8) Q_buffer_in (.data_in(inbus), .enable(c[1]), .data_out(Q_in));
    tristate_buffer_bus #(8) M_buffer_in (.data_in(inbus), .enable(c[2]), .data_out(M_in));

    // ---- control unit ----
    cu_srt2 ctrl_unit (
        .clk(clk), .start(enable), .rst_n(rst_n),
        .count(count_and_out), .s(s),
        .stop(done), .c(c)
    );

    // ---- 3-bit counter -> 8 iterations (terminal at 7) ----
    counter_nbits #(3) counter (.clk(clk), .rst_n(rst_n), .en(c[6]), .count(counter_out));
    and3_gate and_counter (.a(counter_out[0]), .b(counter_out[1]), .c(counter_out[2]), .y(count_and_out));

    // ---- A register (10-bit): init load (c0) or adder load (c4); left shift (c3) ----
    register #(10) reg_A (
        .clk(clk), .rst_n(rst_n),
        .load_en(c[0] | c[4]), .shift_en(c[3]),
        .sr(1'b0), .sl(Q_reg[7]), .shift_dir(1'b0),   // shift in MSB of Q
        .d(A_reg_in), .q(A_reg)
    );

    // ---- Q register (8-bit): load (c1); left shift (c9), bring in quotient bit ----
    register #(8) reg_Q (
        .clk(clk), .rst_n(rst_n),
        .load_en(c[1]), .shift_en(c[9]),
        .sr(1'b0), .sl(Q_0), .shift_dir(1'b0),
        .d(Q_in), .q(Q_reg)
    );

    // ---- M register (8-bit): load (c2) ----
    register #(8) reg_M (
        .clk(clk), .rst_n(rst_n),
        .load_en(c[2]), .shift_en(1'b0),
        .sr(1'b0), .sl(1'b0), .shift_dir(1'b0),
        .d(M_in), .q(M_reg)
    );

    // ---- mux: initial A (sign-extended inbus, = 0) vs adder result ----
    mux2 #(10) mux_A (
        .d0({ {2{A_in[7]}}, A_in }),   // sign-extend the 8-bit initial value to 10 bits
        .d1(adder_out),
        .s(c[4]),
        .y(A_reg_in)
    );

    // ---- zero-extend M to 10 bits (unsigned divisor) ----
    assign M_reg10 = {2'b00, M_reg};

    // ---- XOR row: invert M when subtracting (c5=1) ----
    xorn_gate #(10) xor_instance (.a(M_reg10), .b(c[5]), .y(xor_out));

    // ---- adder: A +/- M  (cin=c5 completes the two's-complement subtraction) ----
    adder #(10) adder_instance (.cin(c[5]), .a(A_reg), .b(xor_out), .sum(adder_out));

    // ---- tristate outputs: remainder (c7) then quotient (c8) ----
    tristate_buffer_bus #(8) A_buffer_out (.data_in(A_reg[7:0]), .enable(c[7]), .data_out(output_buffer));
    tristate_buffer_bus #(8) Q_buffer_out (.data_in(Q_reg),      .enable(c[8]), .data_out(output_buffer));
    assign outbus = output_buffer;

    // ---- direct outputs (registers hold final values once done=1) ----
    assign quotient  = Q_reg;
    assign remainder = A_reg[7:0];
endmodule // div_srt2
