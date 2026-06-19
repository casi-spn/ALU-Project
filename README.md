# ALU-Project
8-bit Arithmetic Logic Unit with interactive simulation in ModelSim.

## Overview
This project implements an 8-bit ALU capable of nine operations:
- **ADD**: Addition of two 8-bit signed numbers
- **SUBTRACT**: Subtraction of two 8-bit signed numbers
- **MULTIPLICATION**: Multiplication of two 8-bit signed numbers, producing a 16-bit product, via a radix-4 Booth multiplier
- **DIVIDE**: Division of two 8-bit unsigned numbers, producing a quotient and remainder, via a structural SRT-2 (non-restoring) divider
- **AND**: Bitwise AND of two 8-bit operands
- **OR**: Bitwise OR of two 8-bit operands
- **XOR**: Bitwise XOR of two 8-bit operands
- **LEFT SHIFT**: Logical left shift of A by B[2:0] positions (0-7)
- **RIGHT SHIFT**: Logical right shift of A by B[2:0] positions (0-7)

The ALU includes status flags that indicate the state of the result:
- **Z (Zero Flag)**: Set if the result is zero
- **N (Negative Flag)**: Set if the MSB (sign bit) of the result is 1
- **V (Overflow Flag)**: Set if signed arithmetic overflow occurs (ADD/SUBTRACT), if the product does not fit in 8 bits (MULTIPLICATION), or on division by zero (DIVIDE); always 0 for AND/OR/XOR and the shifts
- **carry_out**: Carry/borrow out of the adder/subtractor (ADD/SUBTRACT only)

### Operation encoding (`operation[3:0]`)
| Code | Operation     | A, B interpretation                  | Main outputs              | Cycles        |
|------|---------------|--------------------------------------|---------------------------|---------------|
| 0000 | ADD           | signed (-128..127)                   | result, Z, N, V, carry    | combinational |
| 0001 | SUBTRACT      | signed (-128..127)                   | result, Z, N, V, carry    | combinational |
| 0010 | MULTIPLICATION| signed (-128..127)                   | result(lo)+remainder(hi)  | multi-cycle   |
| 0011 | DIVIDE        | unsigned (A: 0..255, B: 1..255)      | quotient, remainder, V    | multi-cycle   |
| 0100 | AND           | unsigned bit pattern (0..255)        | result, Z, N              | combinational |
| 0101 | OR            | unsigned bit pattern (0..255)        | result, Z, N              | combinational |
| 0110 | XOR           | unsigned bit pattern (0..255)        | result, Z, N              | combinational |
| 0111 | LEFT SHIFT    | A: value 0..255, B: amount 0..7      | result, Z, N              | combinational |
| 1000 | RIGHT SHIFT   | A: value 0..255, B: amount 0..7      | result, Z, N              | combinational |

## Project Structure

Files are organized into packages by functional unit:

- **`adder/`**: `full_adder.v` (1-bit full adder), `adder_8bit.v` (8-bit adder using cascaded full adders), `adder.v` (parameterized adder reused by `booth.v` and the SRT-2 divider), `adder_tb.v`
- **`subtractor/`**: `subtractor_8bit.v` (8-bit subtractor using two's complement), `subtractor_tb.v`
- **`divider/`**: structural SRT-2 (non-restoring) divider —
  - `cu_srt2.v` (control unit / state machine)
  - `div_srt2.v` (datapath, built entirely from the `common/`, `gates/`, and `adder/` blocks)
  - `div_unit.v` (wraps the divider with a `start`/`done` handshake, like `mult_unit.v`)
  - `div_srt2_tb.v` (self-checking testbench: directed cases + exhaustive 256x255 sweep)
  - `divider_8bit.v` (legacy behavioral divider, kept for reference; no longer used by `alu.v`), `divider_tb.v`
- **`booth/`**: `booth.v` (radix-4 Booth multiplier, multi-cycle clocked FSM), `cu_booth.v` (control unit for the Booth multiplier), `mult_unit.v` (wraps `booth.v` with a `start`/`done` handshake), `booth_tb.v` (self-checking testbench)
- **`gates/`**: `gates.v` (bit-level `and2_gate`, `and3_gate`, `or2_gate`, `xorn_gate` primitives, instantiated directly by `alu.v` for AND/OR/XOR and by `booth.v`/the divider)
- **`shifters/`**: `left_shift_8bit.v`, `right_shift_8bit.v` (barrel shifters used by `alu.v`), `lshift.v` (used internally by `booth.v`), `left_shift_tb.v`, `right_shift_tb.v`
- **`common/`**: `dff.v`, `mux.v`, `buffer.v`, `register.v`, `counter_nbits.v` — gate/register-level building blocks shared by `booth.v` and the SRT-2 divider
- **`alu/`**: `alu.v` (main ALU module with operation control and status flags; clocked `clk`/`rst_n` to support the multi-cycle MULTIPLY and DIVIDE operations, all other operations remain combinational and settle within one clock cycle), `alu_tb.v` (resets the DUT; test vectors are driven via `force` from `run_alu_interactive.txt` or the ModelSim console)

### Scripts
- **`run_alu_interactive.txt`**: Interactive TCL script for ModelSim simulation (kept at the project root since it's run via `do run_alu_interactive.txt` from the repo root)

## How to Run in ModelSim

### Step 1: Open ModelSim
Launch ModelSim and navigate to the ALU-Project directory.

### Step 2: Run the Interactive Simulation
In the ModelSim console (or Transcript window), execute:
```tcl
do run_alu_interactive.txt
```
The script compiles every module, brings the ALU out of reset, and then loops so you can run as many tests as you like.

### Step 3: Follow the Prompts
1. **Select Operation**: Enter a code from `0` to `8`:
   `0`=ADD, `1`=SUBTRACT, `2`=MULTIPLICATION, `3`=DIVIDE, `4`=AND, `5`=OR, `6`=XOR, `7`=LEFT SHIFT, `8`=RIGHT SHIFT
2. **Enter A / B**: the prompt shows the valid range for the chosen operation:
   - ADD / SUBTRACT / MULTIPLICATION: -128 to 127 (signed)
   - DIVIDE: A (dividend) 0 to 255, B (divisor) 1 to 255
   - AND / OR / XOR: 0 to 255 (unsigned)
   - LEFT / RIGHT SHIFT: A is the value (0 to 255), B is the shift amount (0 to 7)

### Step 4: View Results
**ADD / SUBTRACT / AND / OR / XOR / LEFT SHIFT / RIGHT SHIFT** display (same format):
- **Result**: hex and decimal value
- **Z (Zero)**: 1 if result = 0, else 0
- **N (Negative)**: 1 if the result MSB is 1, else 0
- **V (Overflow)**: 1 if signed overflow occurred (ADD/SUBTRACT); always 0 for AND/OR/XOR and the shifts

**MULTIPLICATION** displays:
- **Product**: the 16-bit signed product of A x B, in hex and decimal. The script pulses the ALU's `start` input and waits for `done`, since the Booth multiplier takes multiple clock cycles; `result` holds the low byte of the product and `remainder` holds the high byte.

**DIVIDE** displays:
- **Quotient**: integer result of A / B
- **Remainder**: remainder of A / B
  As with MULTIPLICATION, the script pulses `start` and lets the SRT-2 divider FSM run to completion before reading the result.

The **Wave window** shows all signals:
- Inputs: clk, rst_n, start, A, B, operation
- Outputs: done, result, quotient, remainder, carry_out, Z, N, V

### Step 5: Run More Tests
When prompted, enter `y` to test more values or `n` to exit.

## Example Tests

### ADD
```
Operation: ADD (0)        A: 50    B: 25    ->  Result: 75   (Z=0, N=0, V=0)
```

### ADD with overflow
```
Operation: ADD (0)        A: 100   B: 50    ->  Result: -106 (Z=0, N=1, V=1)  <- overflow
```

### SUBTRACT
```
Operation: SUBTRACT (1)   A: 20    B: 5     ->  Result: 15   (Z=0, N=0, V=0)
```

### MULTIPLICATION
```
Operation: MULTIPLICATION (2)   A: -3   B: 5    ->  Product: -15
```

### DIVIDE
```
Operation: DIVIDE (3)     A: 17    B: 5     ->  Quotient: 3,  Remainder: 2
Operation: DIVIDE (3)     A: 100   B: 4     ->  Quotient: 25, Remainder: 0
```

### AND
```
Operation: AND (4)        A: 0xF0  B: 0x3C  ->  Result: 0x30 (Z=0, N=0)
```

### OR
```
Operation: OR (5)         A: 0xF0  B: 0x0C  ->  Result: 0xFC (Z=0, N=1)
```

### XOR
```
Operation: XOR (6)        A: 0xFF  B: 0x0F  ->  Result: 0xF0 (Z=0, N=1)
```

### LEFT SHIFT
```
Operation: LEFT SHIFT (7)  A: 1 (0x01)  B: 3   ->  Result: 8 (0x08)
```

### RIGHT SHIFT
```
Operation: RIGHT SHIFT (8) A: 0x80      B: 2   ->  Result: 0x20 (32)
```

## Number Representation
- **ADD / SUBTRACT / MULTIPLICATION**: -128 to 127 (8-bit signed, two's complement)
- **DIVIDE**: 0 to 255 (8-bit unsigned; divisor must be >= 1)
- **AND / OR / XOR**: 0 to 255 (treated as raw bit patterns)
- **LEFT / RIGHT SHIFT**: value 0 to 255; shift amount 0 to 7 (only B[2:0] is used)

## Design Notes
- The subtractor uses two's complement: A - B = A + (~B) + 1.
- Overflow detection compares the sign bits of the inputs and the result
  (meaningful for ADD/SUBTRACT; for MULTIPLICATION, V is set when the 16-bit
  product does not fit in 8 bits; for DIVIDE, V is set on division by zero; for
  AND/OR/XOR and the shifts, V is always 0).
- AND/OR/XOR are built by bit-slicing the gate primitives in `gates.v`
  (`and2_gate`, `or2_gate`, `xorn_gate`), one gate per bit.
- The shifters are logical (vacated bits are filled with 0) and built as
  barrel shifters.
- MULTIPLICATION uses a radix-4 Booth multiplier (`booth.v`); it processes
  2 bits of the operand per cycle and takes a fixed 21 clock cycles after
  `start` is pulsed (LOAD_M, LOAD_Q, 4x SCAN/SHIFT1/SHIFT2/CHECK, OUTPUT_A,
  OUTPUT_Q, STOP).
- DIVIDE uses a structural SRT-2 (non-restoring) divider (`div_srt2.v` +
  `cu_srt2.v`): 8 iterations of "shift left, then A-M if A>=0 else A+M, then set
  the quotient bit", followed by a non-restoring correction. Its accumulator is
  10 bits wide (one guard bit beyond the textbook 9), which makes it correct for
  the full 0..255 divisor range. It is driven through `div_unit.v` with the same
  `start`/`done` handshake as the multiplier.
- `alu.v` is combinational except for MULTIPLY and DIVIDE; `clk`/`rst_n` exist
  to drive those two FSMs, and `start`/`done` are used only for them. All other
  operations ignore `start` and assert `done` immediately.
- All calculations are performed in 8-bit binary format (16-bit for the
  multiplication product).

## Testbenches
Each unit has a standalone, self-checking testbench (`*_tb.v`). The Booth
multiplier (`booth/booth_tb.v`) and the SRT-2 divider (`divider/div_srt2_tb.v`)
include exhaustive sweeps over all input pairs. To run one directly, e.g. the
divider:
```tcl
vlog common/dff.v gates/gates.v common/mux.v adder/adder.v common/buffer.v \
     common/register.v common/counter_nbits.v divider/cu_srt2.v \
     divider/div_srt2.v divider/div_srt2_tb.v
vsim div_srt2_tb
run -all
```