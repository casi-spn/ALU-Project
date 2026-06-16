# ALU-Project
8-bit Arithmetic Logic Unit with interactive simulation in ModelSim.

## Overview
This project implements an 8-bit ALU capable of:
- **ADD**: Addition of two 8-bit signed numbers
- **SUBTRACT**: Subtraction of two 8-bit signed numbers
- **DIVIDE**: Division of two 8-bit unsigned numbers, producing a quotient and remainder

The ALU includes status flags that indicate the state of the result:
- **Z (Zero Flag)**: Set if result is zero
- **N (Negative Flag)**: Set if the MSB (sign bit) is 1
- **V (Overflow Flag)**: Set if signed arithmetic overflow occurs (ADD/SUBTRACT only)

## Project Structure

### Modules
- **`full_adder.v`**: Basic full adder module (1-bit)
- **`adder_8bit.v`**: 8-bit adder using cascaded full adders
- **`subtractor_8bit.v`**: 8-bit subtractor using two's complement
- **`divider_8bit.v`**: 8-bit unsigned divider, outputs quotient and remainder
- **`alu.v`**: Main ALU module with operation control and status flags
- **`tb_alu.v`**: ALU testbench
- **`tb_divider.v`**: Standalone divider testbench

### Scripts
- **`run_alu_interactive.txt`**: Interactive TCL script for ModelSim simulation

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
1. **Select Operation**: Enter `0` for ADD, `1` for SUBTRACT, or `3` for DIVIDE
2. **Enter A**: For ADD/SUBTRACT input -128 to 127; for DIVIDE input 0 to 255
3. **Enter B**: For ADD/SUBTRACT input -128 to 127; for DIVIDE input 0 to 255

### Step 4: View Results
**ADD / SUBTRACT** display:
- **Result**: decimal and hex value
- **Z (Zero)**: 1 if result = 0, else 0
- **N (Negative)**: 1 if result is negative, else 0
- **V (Overflow)**: 1 if signed overflow occurred, else 0

**DIVIDE** displays:
- **Quotient**: integer result of A ÷ B
- **Remainder**: remainder of A ÷ B

The **Wave window** shows all signals including:
- Inputs: A, B, operation
- Outputs: result, quotient, remainder, carry_out, Z, N, V

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
- **ADD / SUBTRACT range**: -128 to 127 (8-bit signed, two's complement)
- **DIVIDE range**: 0 to 255 (8-bit unsigned, positive numbers only)

## Design Notes
- The subtractor uses two's complement: A - B = A + (~B) + 1
- Overflow detection compares the sign bits of inputs and result
- The divider operates on unsigned values only; both A and B must be positive
- All calculations are performed in 8-bit binary format
- Operation encoding: `000`=ADD, `001`=SUBTRACT, `011`=DIVIDE
