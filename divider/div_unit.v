`timescale 1ns/1ps
//--------------------------------------------------------------------------
// div_unit.v  --  wraps the structural SRT-2 divider (div_srt2.v) with a
// start/done handshake, exactly like booth/mult_unit.v wraps booth.v.
//
//  Timing (one inbus value per cycle, matching cu_srt2's LOAD order):
//    cycle 0 (IDLE)   : start=1, inbus=0  -> div latches A (partial rem) = 0
//    cycle 1 (LOAD_A) : inbus=0  (held)
//    cycle 2 (LOAD_Q) : inbus=A  (dividend)
//    cycle 3 (LOAD_M) : inbus=B  (divisor)
//    div then runs the 8 SRT-2 iterations on its own until done.
//--------------------------------------------------------------------------
module div_unit(
    input        clk,
    input        rst_n,
    input        start,         // pulse for 1 cycle to begin a divide
    input  [7:0] A,             // dividend
    input  [7:0] B,             // divisor
    output       done,
    output       V,             // division by zero
    output [7:0] quotient,
    output [7:0] remainder
);
    localparam S_IDLE   = 3'd0,
               S_LOAD_A = 3'd1,
               S_LOAD_Q = 3'd2,
               S_LOAD_M = 3'd3,
               S_RUN    = 3'd4;

    reg [2:0]        seq_state;
    reg              div_start;
    reg signed [7:0] div_inbus;
    wire             div_done;

    div_srt2 dut (
        .clk(clk),
        .rst_n(rst_n),
        .enable(div_start),
        .inbus(div_inbus),
        .done(div_done),
        .V(V),
        .outbus(),
        .quotient(quotient),
        .remainder(remainder)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            seq_state <= S_IDLE;
            div_start <= 1'b0;
            div_inbus <= 8'd0;
        end else begin
            case (seq_state)
                S_IDLE: begin
                    div_start <= 1'b0;
                    if (start) begin
                        div_start <= 1'b1;
                        div_inbus <= 8'd0;   // initial partial remainder A = 0
                        seq_state <= S_LOAD_A;
                    end
                end
                S_LOAD_A: begin
                    div_start <= 1'b0;
                    div_inbus <= 8'd0;
                    seq_state <= S_LOAD_Q;
                end
                S_LOAD_Q: begin
                    div_inbus <= A;          // dividend
                    seq_state <= S_LOAD_M;
                end
                S_LOAD_M: begin
                    div_inbus <= B;          // divisor
                    seq_state <= S_RUN;
                end
                S_RUN: begin
                    if (div_done) seq_state <= S_IDLE;
                end
            endcase
        end
    end

    assign done = div_done;
endmodule // div_unit
