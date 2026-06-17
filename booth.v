`timescale 1ns/1ps
module booth (
              input             clk,
              input             enable,   // start (BEGIN)
              input             rst_n,
              input  signed [7:0] inbus,
              output            done,
              output [7:0]      outbus
              );
   // control word
   wire [8:0] c;
   wire       stop;

   wire [7:0] output_buffer;

   // register outputs
   wire signed [9:0] A_reg;          // 10-bit accumulator
   wire signed [7:0] M_reg, Q_reg;
   wire              Qm;
   wire signed [7:0] M_input, Q_input;

   // counter
   wire [1:0] counter_o;
   wire       count_term;

   // operand / adder nets
   wire        [8:0] m2_9;           // 2*M (9-bit)
   wire signed [9:0] m_ext, m2_ext;  // M and 2M sign-extended to 10 bits
   wire signed [9:0] mag;            // selected magnitude (M or 2M)
   wire        [9:0] xor_o;          // magnitude after XOR negation row
   wire signed [9:0] adder_o;        // adder result -> A

   // ======================= CONTROL UNIT =======================
   cu_booth ctrl_unit (
                       .clk(clk),
                       .start(enable),
                       .rst_n(rst_n),
                       .count(count_term),
                       .q1(Q_reg[1]),
                       .q0(Q_reg[0]),
                       .qm(Qm),
                       .stop(stop),
                       .c(c)
                       );
   assign done = stop;

   // ======================= COUNTER (DFF only) =======================
   counter_nbits #(.WIDTH(2)) counter (
                                       .clk(clk),
                                       .rst_n(rst_n),
                                       .en(c[5]),
                                       .count(counter_o)
                                       );
   and2_gate and_counter (.a(counter_o[0]), .b(counter_o[1]), .y(count_term));

   // ======================= REGISTERS =======================
   register #(.WIDTH(10)) reg_A (
                                 .clk(clk), .rst_n(rst_n),
                                 .load_en(c[2]), .shift_en(c[4]),
                                 .sr(A_reg[9]), .sl(1'b0), .shift_dir(1'b1),
                                 .d(adder_o), .q(A_reg)
                                 );

   register #(.WIDTH(8)) reg_Q (
                                .clk(clk), .rst_n(rst_n),
                                .load_en(c[1]), .shift_en(c[4]),
                                .sr(A_reg[0]), .sl(1'b0), .shift_dir(1'b1),
                                .d(Q_input), .q(Q_reg)
                                );

   register #(.WIDTH(1)) reg_Qm (
                                 .clk(clk), .rst_n(rst_n),
                                 .load_en(c[1]), .shift_en(c[4]),
                                 .sr(Q_reg[0]), .sl(1'b0), .shift_dir(1'b1),
                                 .d(1'b0), .q(Qm)
                                 );

   register #(.WIDTH(8)) reg_M (
                                .clk(clk), .rst_n(rst_n),
                                .load_en(c[0]), .shift_en(1'b0),
                                .sr(1'b0), .sl(1'b0), .shift_dir(1'b0),
                                .d(M_input), .q(M_reg)
                                );

   // ======================= OPERAND SELECT + ADDER =======================
   lshift lsh (.in(M_reg), .out(m2_9));            // 2M = M << 1
   assign m_ext  = {{2{M_reg[7]}}, M_reg};         // M  sign-extended to 10 bits
   assign m2_ext = {m2_9[8], m2_9};                // 2M sign-extended to 10 bits

   mux2 #(10) mux_double (.d0(m_ext), .d1(m2_ext), .s(c[8]), .y(mag));
   xorn_gate #(10) xor_instance (.a(mag), .b(c[3]), .y(xor_o));
   adder #(10) adder_instance (.cin(c[3]), .a(A_reg), .b(xor_o), .sum(adder_o));

   // ======================= TRI-STATE BUSES =======================
   tristate_buffer_bus #(8) M_in  (.data_in(inbus),      .enable(c[0]), .data_out(M_input));
   tristate_buffer_bus #(8) Q_in  (.data_in(inbus),      .enable(c[1]), .data_out(Q_input));
   tristate_buffer_bus #(8) A_out (.data_in(A_reg[7:0]), .enable(c[6]), .data_out(output_buffer));
   tristate_buffer_bus #(8) Q_out (.data_in(Q_reg),      .enable(c[7]), .data_out(output_buffer));

   assign outbus = output_buffer;
endmodule // booth
