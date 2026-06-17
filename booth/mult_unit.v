// ============================================================
//  Multiply unit: wraps the radix-4 Booth multiplier (booth.v)
//  with a simple start/done handshake so it can be driven from
//  a single clock pulse, instead of manually sequencing inbus
//  through booth's LOAD_M -> LOAD_Q load order.
//
//  Timing (mirrors booth_tb.v's do_mult task):
//    cycle 0 (IDLE)   : start=1, inbus=A -> booth latches A as M
//    cycle 1 (LOAD_M) : inbus=A (held)
//    cycle 2 (LOAD_Q) : inbus=B -> booth latches B as Q
//    booth then runs SCAN/SHIFT/CHECK on its own until done.
// ============================================================
module mult_unit(
    input        clk,
    input        rst_n,
    input        start,        // pulse for 1 cycle to begin a multiply
    input  [7:0] A,
    input  [7:0] B,
    output       done,
    output [15:0] product
);

localparam S_IDLE   = 2'd0,
           S_LOAD_M = 2'd1,
           S_LOAD_Q = 2'd2,
           S_RUN    = 2'd3;

reg [1:0]        seq_state;
reg              booth_start;
reg signed [7:0] booth_inbus;
wire             booth_done;

booth dut (
    .clk(clk),
    .rst_n(rst_n),
    .enable(booth_start),
    .inbus(booth_inbus),
    .done(booth_done),
    .outbus(),
    .product(product)
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        seq_state   <= S_IDLE;
        booth_start <= 1'b0;
        booth_inbus <= 8'd0;
    end else begin
        case (seq_state)
            S_IDLE: begin
                booth_start <= 1'b0;
                if (start) begin
                    booth_start <= 1'b1;
                    booth_inbus <= A;
                    seq_state   <= S_LOAD_M;
                end
            end
            S_LOAD_M: begin
                booth_start <= 1'b0;
                booth_inbus <= A;
                seq_state   <= S_LOAD_Q;
            end
            S_LOAD_Q: begin
                booth_inbus <= B;
                seq_state   <= S_RUN;
            end
            S_RUN: begin
                if (booth_done) seq_state <= S_IDLE;
            end
        endcase
    end
end

assign done = booth_done;

endmodule
