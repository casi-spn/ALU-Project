`timescale 1ns/1ps
module cu_booth (
                 input            clk,
                 input            start,
                 input            rst_n,
                 input            count,   // terminal: counter == 3
                 input            q1,      // Q[1]
                 input            q0,      // Q[0]
                 input            qm,      // Q[-1]
                 output reg       stop,
                 output reg [8:0] c
                 );
   // state encoding
   localparam IDLE     = 4'd0,
              LOAD_M   = 4'd1,
              LOAD_Q   = 4'd2,
              SCAN     = 4'd3,
              SHIFT1   = 4'd4,
              SHIFT2   = 4'd5,
              CHECK    = 4'd6,
              OUTPUT_A = 4'd7,
              OUTPUT_Q = 4'd8,
              STOP     = 4'd9;

   reg [3:0] state, next;

   always @(posedge clk or negedge rst_n) begin
      if (!rst_n) state <= IDLE;
      else        state <= next;
   end

   always @(*) begin
      next = state;
      stop = 1'b0;
      c    = 9'b0;
      case (state)
        IDLE: begin
           if (start) next = LOAD_M;
        end
        LOAD_M: begin
           c[0] = 1'b1;
           next = LOAD_Q;
        end
        LOAD_Q: begin
           c[1] = 1'b1;
           next = SCAN;
        end
        SCAN: begin
           case ({q1, q0, qm})
             3'b001, 3'b010: begin c[2]=1'b1;                       end // +M
             3'b011        : begin c[2]=1'b1;            c[8]=1'b1; end // +2M
             3'b100        : begin c[2]=1'b1; c[3]=1'b1; c[8]=1'b1; end // -2M
             3'b101, 3'b110: begin c[2]=1'b1; c[3]=1'b1;            end // -M
             default       : ;                                         // 0
           endcase
           next = SHIFT1;
        end
        SHIFT1: begin
           c[4] = 1'b1;
           next = SHIFT2;
        end
        SHIFT2: begin
           c[4] = 1'b1;
           next = CHECK;
        end
        CHECK: begin
           if (count)
             next = OUTPUT_A;
           else begin
              c[5] = 1'b1;
              next = SCAN;
           end
        end
        OUTPUT_A: begin
           c[6] = 1'b1;
           next = OUTPUT_Q;
        end
        OUTPUT_Q: begin
           c[7] = 1'b1;
           next = STOP;
        end
        STOP: begin
           stop = 1'b1;
           next = IDLE;
        end
        default: next = IDLE;
      endcase
   end
endmodule // cu_booth
