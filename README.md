# ALU-Project
8-bit Arithmetic Logic Unit with interactive simulation in ModelSim.

## Overview
This project implements an 8-bit ALU capable of:
- **ADD**: Addition of two 8-bit signed numbers
- **SUBTRACT**: Subtraction of two 8-bit signed numbers
- **MULTIPLICATION**: Multiplication of two 8-bit signed numbers, producing a 16-bit product, via a radix-4 Booth multiplier
- **DIVIDE**: Division of two 8-bit unsigned numbers, producing a quotient and remainder

The ALU includes status flags that indicate the state of the result:
- **Z (Zero Flag)**: Set if result is zero
- **N (Negative Flag)**: Set if the MSB (sign bit) is 1
- **V (Overflow Flag)**: Set if signed arithmetic overflow occurs (ADD/SUBTRACT only)

## Project Structure

Files are organized into packages by functional unit:

- **`adder/`**: `full_adder.v` (1-bit full adder), `adder_8bit.v` (8-bit adder using cascaded full adders), `adder.v` (parameterized adder used internally by `booth.v`), `adder_tb.v`
- **`subtractor/`**: `subtractor_8bit.v` (8-bit subtractor using two's complement), `subtractor_tb.v`
- **`divider/`**: `divider_8bit.v` (8-bit unsigned divider, outputs quotient and remainder), `divider_tb.v` (standalone divider testbench)
- **`booth/`**: `booth.v` (radix-4 Booth multiplier, multi-cycle clocked FSM), `cu_booth.v` (control unit/state machine for the Booth multiplier), `mult_unit.v` (wraps `booth.v` with a simple `start`/`done` handshake, so a multiply can be kicked off with a single pulse instead of manually sequencing the multiplier's load order), `booth_tb.v` (standalone, self-checking testbench with directed cases + exhaustive 256x256 sweep)
- **`gates/`**: `gates.v` (bit-level `and2_gate`, `and3_gate`, `or2_gate`, `xorn_gate` primitives, instantiated directly by `alu.v` and `booth.v`)
- **`shifters/`**: `left_shift_8bit.v`, `right_shift_8bit.v`, `lshift.v` (used internally by `booth.v`), `left_shift_tb.v`, `right_shift_tb.v`
- **`common/`**: `dff.v`, `mux.v`, `buffer.v`, `register.v`, `counter_nbits.v` — gate/register-level building blocks used internally by `booth.v`
- **`alu/`**: `alu.v` (main ALU module with operation control and status flags; clocked `clk`/`rst_n` to support the multi-cycle MULTIPLY operation, all other operations remain combinational and settle within one clock cycle), `alu_tb.v` (ALU testbench — resets the DUT; test vectors are driven via `force` from `run_alu_interactive.txt` or the ModelSim console)

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

### Step 3: Follow the Prompts
The script will guide you through:
1. **Select Operation**: Enter `0` for ADD, `1` for SUBTRACT, `2` for MULTIPLICATION, or `3` for DIVIDE
2. **Enter A**: For ADD/SUBTRACT/MULTIPLICATION input -128 to 127; for DIVIDE input 0 to 255
3. **Enter B**: For ADD/SUBTRACT/MULTIPLICATION input -128 to 127; for DIVIDE input 0 to 255

### Step 4: View Results
**ADD / SUBTRACT** display:
- **Result**: decimal and hex value
- **Z (Zero)**: 1 if result = 0, else 0
- **N (Negative)**: 1 if result is negative, else 0
- **V (Overflow)**: 1 if signed overflow occurred, else 0

**MULTIPLICATION** displays:
- **Product**: the 16-bit signed product of A x B, in hex and decimal. Internally this drives the ALU's `start` input for one cycle and waits for `done`, since the Booth multiplier takes multiple clock cycles to finish; `result` holds the low byte of the product and `remainder` holds the high byte

**DIVIDE** displays:
- **Quotient**: integer result of A ÷ B
- **Remainder**: remainder of A ÷ B

The **Wave window** shows all signals including:
- Inputs: clk, rst_n, start, A, B, operation
- Outputs: done, result, quotient, remainder, carry_out, Z, N, V

### Step 5: Run More Tests
When prompted, enter `y` to test more values or `n` to exit.

## Example Tests

### Test 1: Simple Addition
```
Operation: ADD (0)
A: 50
B: 25
Result: 75 (no flags set)
```

### Test 2: Addition with Negative Number
```
Operation: ADD (0)
A: -5
B: 10
Result: 5 (Z=0, N=0, V=0)
```

### Test 3: Overflow Detection
```
Operation: ADD (0)
A: 100
B: 50
Result: -106 (Z=0, N=1, V=1) ← Overflow flag set!
```

### Test 4: Subtraction
```
Operation: SUBTRACT (1)
A: 20
B: 5
Result: 15 (Z=0, N=0, V=0)
```

### Test 4b: Multiplication
```
Operation: MULTIPLICATION (2)
A: -3
B: 5
Product: -15
```

### Test 5: Division
```
Operation: DIVIDE (3)
A: 17
B: 5
Quotient: 3
Remainder: 2
```

### Test 6: Division exact
```
Operation: DIVIDE (3)
A: 100
B: 4
Quotient: 25
Remainder: 0
```

## Number Representation
- **ADD / SUBTRACT / MULTIPLICATION range**: -128 to 127 (8-bit signed, two's complement)
- **DIVIDE range**: 0 to 255 (8-bit unsigned, positive numbers only)

## Design Notes
- The subtractor uses two's complement: A - B = A + (~B) + 1
- Overflow detection compares the sign bits of inputs and result
- The divider operates on unsigned values only; both A and B must be positive
- Multiplication uses a radix-4 Booth multiplier (`booth.v`), which is the only
  multi-cycle operation in the ALU. `alu.v` is otherwise purely combinational;
  `clk`/`rst_n` exist solely to drive the Booth FSM, and `start`/`done` are
  used only for MULTIPLICATION. All other operations ignore `start` and
  assert `done` immediately.
- A multiply takes a fixed 21 clock cycles to complete after `start` is
  pulsed (LOAD_M, LOAD_Q, 4x SCAN/SHIFT1/SHIFT2/CHECK, OUTPUT_A, OUTPUT_Q,
  STOP), since the multiplier processes 2 bits of the operand per cycle.
- All calculations are performed in 8-bit binary format (16-bit for the
  multiplication product)
- Operation encoding: `0000`=ADD, `0001`=SUBTRACT, `0010`=MULTIPLICATION, `0011`=DIVIDE
