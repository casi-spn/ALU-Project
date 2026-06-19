`timescale 1ns/1ps
//--------------------------------------------------------------------------
// div_srt2_tb.v  --  self-checking testbench for the structural SRT-2 divider
//
//  Icarus Verilog:
//    iverilog -o sim common/dff.v gates/gates.v common/mux.v adder/adder.v \
//             common/buffer.v common/register.v common/counter_nbits.v \
//             divider/cu_srt2.v divider/div_srt2.v divider/div_srt2_tb.v
//    vvp sim
//
//  Drives div_srt2 directly: load A=0, then dividend (Q), then divisor (M),
//  exactly as the div_unit wrapper sequences inbus.
//--------------------------------------------------------------------------
module div_srt2_tb;

    reg              clk, rst_n, enable;
    reg signed [7:0] inbus;
    wire             done, V;
    wire [7:0]       outbus, quotient, remainder;

    div_srt2 dut (
        .clk(clk), .rst_n(rst_n), .enable(enable), .inbus(inbus),
        .done(done), .V(V), .outbus(outbus),
        .quotient(quotient), .remainder(remainder)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    integer errors, tests, d, v;

    task do_div;
        input [7:0] dividend;
        input [7:0] divisor;
        input       verbose;
        begin
            // reset (one-shot)
            enable = 1'b0; inbus = 8'd0;
            rst_n = 1'b0; @(negedge clk); @(negedge clk); rst_n = 1'b1;
            // IDLE: start + present A (= 0)
            @(negedge clk); enable = 1'b1; inbus = 8'd0;
            // LOAD_A: A = 0 latched
            @(negedge clk); enable = 1'b0; inbus = 8'd0;
            // LOAD_Q: dividend
            @(negedge clk); inbus = dividend;
            // LOAD_M: divisor
            @(negedge clk); inbus = divisor;
            // run to completion
            wait (done);
            @(negedge clk);
            tests = tests + 1;
            if (divisor == 8'd0) begin
                if (V !== 1'b1) begin
                    errors = errors + 1;
                    if (errors <= 20) $display("FAIL div-by-0: V=%b (expected 1)", V);
                end
            end
            else if (quotient !== (dividend / divisor) ||
                     remainder !== (dividend % divisor)) begin
                errors = errors + 1;
                if (errors <= 20)
                    $display("FAIL %0d / %0d -> q=%0d r=%0d  (expected q=%0d r=%0d)",
                             dividend, divisor, quotient, remainder,
                             dividend / divisor, dividend % divisor);
            end
            else if (verbose)
                $display("PASS %0d / %0d -> q=%0d r=%0d", dividend, divisor, quotient, remainder);
        end
    endtask

    initial begin
        $dumpfile("div_srt2_tb.vcd");
        $dumpvars;
        errors = 0; tests = 0;

        $display("=== directed ===");
        do_div(8'd17,  8'd5,   1'b1);   // 3 r 2
        do_div(8'd100, 8'd4,   1'b1);   // 25 r 0
        do_div(8'd255, 8'd255, 1'b1);   // 1 r 0
        do_div(8'd255, 8'd1,   1'b1);   // 255 r 0
        do_div(8'd200, 8'd13,  1'b1);   // 15 r 5
        do_div(8'd5,   8'd10,  1'b1);   // 0 r 5
        do_div(8'd42,  8'd0,   1'b1);   // division by zero -> V=1

        $display("=== exhaustive (divisor 1..255) ===");
        for (d = 0; d < 256; d = d + 1)
            for (v = 1; v < 256; v = v + 1)
                do_div(d[7:0], v[7:0], 1'b0);

        $display("=================================================");
        $display("  %0d tests, %0d errors  ->  %s",
                 tests, errors, (errors == 0) ? "ALL PASS" : "FAILURES");
        $display("=================================================");
        $finish;
    end

    initial begin #5_000_000_000; $display("TIMEOUT"); $finish; end
endmodule // div_srt2_tb
