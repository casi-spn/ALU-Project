`timescale 1ns/1ps
module booth_tb;

   reg               clk;
   reg               rst_n;
   reg               start;
   reg signed [7:0]  inbus;
   wire       [7:0]  outbus;
   wire              done;

   booth dut (
              .clk(clk),
              .rst_n(rst_n),
              .enable(start),
              .inbus(inbus),
              .done(done),
              .outbus(outbus)
              );

   initial begin
      $dumpfile("booth_tb.vcd");
      $dumpvars;
   end

   initial clk = 1'b0;
   always #5 clk = ~clk;

   integer errors;
   integer tests;
   integer a, b;

   reg signed [15:0] prod, exp;

   // run one multiply (mv * qv) and self-check against the expected product
   task do_mult;
      input signed [7:0] mv;
      input signed [7:0] qv;
      input              verbose;
      begin
         // reset (one-shot start)
         start = 1'b0; inbus = 8'sd0;
         rst_n = 1'b0; @(negedge clk); @(negedge clk);
         rst_n = 1'b1;

         // IDLE: raise start, present M
         @(negedge clk); start = 1'b1; inbus = mv;
         // LOAD_M: keep M while it is latched
         @(negedge clk); start = 1'b0; inbus = mv;
         // LOAD_Q: present Q while it is latched
         @(negedge clk); inbus = qv;

         wait (done);
         @(negedge clk);

         prod  = {dut.A_reg[7:0], dut.Q_reg};   // product = {A[7:0], Q[7:0]}
         exp   = mv * qv;
         tests = tests + 1;
         if (prod !== exp) begin
            errors = errors + 1;
            if (errors <= 20)
              $display("FAIL  %0d * %0d = %0d  (expected %0d)", mv, qv, prod, exp);
         end
         else if (verbose)
           $display("PASS  %0d * %0d = %0d", mv, qv, prod);
      end
   endtask

   initial begin
      errors = 0; tests = 0;

      $display("=== radix-4 Booth multiplier : directed demo ===");
      do_mult(-8'sd3,   8'sd5,   1'b1);   // -3 * 5   = -15
      do_mult( 8'sd7,   8'sd6,   1'b1);   //  7 * 6   =  42
      do_mult(-8'sd9,  -8'sd9,   1'b1);   // -9 * -9  =  81
      do_mult(-8'sd128,-8'sd128, 1'b1);   // worst case: -128 * -128 = 16384
      do_mult( 8'sd127, 8'sd127, 1'b1);   // 127 * 127 = 16129

      $display("=== exhaustive sweep : all 256 x 256 signed pairs ===");
      for (a = -128; a < 128; a = a + 1)
        for (b = -128; b < 128; b = b + 1)
          do_mult(a[7:0], b[7:0], 1'b0);

      $display("=================================================");
      $display("  %0d tests, %0d errors  ->  %s",
               tests, errors, (errors == 0) ? "ALL PASS" : "FAILURES");
      $display("=================================================");
      $finish;
   end

   initial begin #2000000000; $display("TIMEOUT"); $finish; end
endmodule // booth_tb
