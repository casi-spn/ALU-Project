// ============================================================
//  8-bit Left Shift
//
//  Inputs : A[7:0]  – value to be shifted
//           B[7:0]  – shift amount (only B[2:0] used, range 0-7)
//  Output : result[7:0] – A shifted left by B[2:0] positions
//                         vacated LSBs are filled with 0
//
//  Implemented as a 3-stage barrel shifter so it maps cleanly
//  to gates (no behavioural shift operator required).
//    Stage 1: optionally shift by 4
//    Stage 2: optionally shift by 2
//    Stage 3: optionally shift by 1
// ============================================================
module left_shift_8bit(
    input  [7:0] A,
    input  [7:0] B,       // only B[2:0] used
    output [7:0] result
);

wire [7:0] stage1, stage2;

// Stage 1 – shift by 4 if B[2] == 1
assign stage1 = B[2] ? {A[3:0], 4'b0} : A;

// Stage 2 – shift by 2 if B[1] == 1
assign stage2 = B[1] ? {stage1[5:0], 2'b0} : stage1;

// Stage 3 – shift by 1 if B[0] == 1
assign result = B[0] ? {stage2[6:0], 1'b0} : stage2;

endmodule
