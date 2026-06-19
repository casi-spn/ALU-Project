`timescale 1ns/1ps
//--------------------------------------------------------------------------
// cu_srt2.v  --  control unit for the structural SRT-2 (non-restoring) divider
//
// Drives the datapath in div_srt2.v.  8 iterations for an 8-bit divide.
//
// Control word c[9:0]:
//   c[0] load A (initial partial remainder = 0)
//   c[1] load Q (dividend)
//   c[2] load M (divisor)
//   c[3] shift A left  (A[0] <- Q[7])
//   c[4] load A from the adder (accumulate A +/- M)
//   c[5] subtract (drives the XOR negation row + adder carry-in)
//   c[6] counter increment
//   c[7] drive A[7:0] -> bus (remainder)
//   c[8] drive Q      -> bus (quotient)
//   c[9] shift Q left  (Q[0] <- quotient bit)
//
// Per iteration: SHIFT (A<<1) -> ADDSUB (A>=0 ? A-M : A+M) -> SETQ (q-bit = ~A[9]).
// After 8 iterations: CORRECT (if A<0, A = A+M) then output remainder, quotient.
//--------------------------------------------------------------------------
module cu_srt2 (
    input            clk,
    input            start,
    input            rst_n,
    input            count,    // terminal: counter == 7  (8 iterations done)
    input            s,        // sign of partial remainder (A_reg[9])
    output reg       stop,
    output reg [9:0] c
);
    localparam IDLE     = 4'd0,
               LOAD_A   = 4'd1,
               LOAD_Q   = 4'd2,
               LOAD_M   = 4'd3,
               SHIFT    = 4'd4,
               ADDSUB   = 4'd5,
               SETQ     = 4'd6,
               CHECK    = 4'd7,
               CORRECT  = 4'd8,
               OUTPUT_A = 4'd9,
               OUTPUT_Q = 4'd10,
               STOP     = 4'd11;

    reg [3:0] state, next;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) state <= IDLE;
        else        state <= next;
    end

    always @(*) begin
        next = state;
        stop = 1'b0;
        c    = 10'b0;
        case (state)
            IDLE:     if (start) next = LOAD_A;
            LOAD_A:   begin c[0] = 1'b1; next = LOAD_Q; end
            LOAD_Q:   begin c[1] = 1'b1; next = LOAD_M; end
            LOAD_M:   begin c[2] = 1'b1; next = SHIFT;  end
            SHIFT:    begin c[3] = 1'b1; next = ADDSUB; end
            ADDSUB:   begin
                         c[4] = 1'b1;        // load A from adder
                         c[5] = ~s;          // s=0 (A>=0) -> subtract ; s=1 (A<0) -> add
                         next = SETQ;
                      end
            SETQ:     begin c[9] = 1'b1; next = CHECK; end   // Q << 1, Q[0] <- ~A[9]
            CHECK:    begin
                         if (count) next = CORRECT;
                         else begin c[6] = 1'b1; next = SHIFT; end
                      end
            CORRECT:  begin
                         if (s) begin c[4] = 1'b1; c[5] = 1'b0; end  // A<0 -> restore: A = A + M
                         next = OUTPUT_A;
                      end
            OUTPUT_A: begin c[7] = 1'b1; next = OUTPUT_Q; end
            OUTPUT_Q: begin c[8] = 1'b1; next = STOP;     end
            STOP:     begin stop = 1'b1; next = IDLE;     end
            default:  next = IDLE;
        endcase
    end
endmodule // cu_srt2
