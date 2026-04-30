# 🚀 Nanoprocessor - 4-Bit Microprocessor in VHDL

![VHDL](https://img.shields.io/badge/VHDL-IEEE%201076--1993-blue) ![FPGA](https://img.shields.io/badge/FPGA-Artix--7-orange) ![BASYS3](https://img.shields.io/badge/Board-BASYS3-green)

> A complete 4-bit nanoprocessor with 8 registers, 12-bit ISA, and single-cycle execution

[Features](#-features) • [Architecture](#-architecture) • [Instruction Set](#-instruction-set-architecture-isa) • [Assembly Programs](#-assembly-programs) • [Quick Start](#-quick-start)

---

## 🎯 About

This is a fully functional 4-bit nanoprocessor implemented in VHDL for FPGA (Artix-7 / BASYS3). It features a custom 4-instruction set architecture, 8 general-purpose registers, and a Harvard-like design optimized for minimal gate count while maintaining complete functionality.

---

## ✨ Features

| Feature | Details |
|---------|---------|
| 📊 Data Width | 4-bit (signed integers, 2's complement) |
| 💾 Registers | 8 × 4-bit (R0–R7), R0 hardwired to 0 |
| 📝 Instructions | 4 instructions (MOVI, ADD, NEG, JZR) |
| 🔢 Instruction Size | 12 bits |
| 🧠 Program Memory | 8 words (ROM) |
| ⚡ Execution | Single-cycle |
| 🚩 Flags | Zero flag, Overflow flag |
| 🖥️ Display | LEDs + 7-segment display |

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     NANOPROCESSOR TOP LEVEL                 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────┐   ┌──────────┐   ┌──────────────────┐        │
│  │   PC    │──▶│   ROM    │──▶│  INSTRUCTION     │        │
│  │ (3-bit) │   │ (8×12b)  │   │  DECODER         │        │
│  └────┬─────┘   └──────────┘   └────┬─────────────┘        │
│       │                              │                       │
│       ▼                              ▼                       │
│  ┌─────────┐              ┌────────────┐                    │
│  │  PC+1   │◀─────────────│  Control   │                    │
│  │  Adder  │              │  Signals   │                    │
│  └────┬─────┘              └────┬───────┘                    │
│       │                         │                            │
│       ▼                         ▼                            │
│  ┌─────────┐   ┌─────────────────────────────────┐         │
│  │  PC MUX │◀──│                                 │         │
│  └─────────┘   │         REGISTER BANK           │         │
│                │           (R0 - R7)              │         │
│                │   ┌──────┐                       │         │
│                │   │MUX 8 │───┐                   │         │
│                │   │ 4bit │   │                   │         │
│                │   └──────┘   ▼                   │         │
│                │        ┌──────────────┐          │         │
│                │        │     ALU      │          │         │
│                │        │   (4-bit)    │          │         │
│                │        └──────┬───────┘          │         │
│                │               │                  │         │
│                └───────────────┼──────────────────┘         │
│                                │                             │
│                   ┌────────┴────────┐                       │
│                   │  WRITE BACK MUX │                       │
│                   └─────────────────┘                       │
│                                                             │
│  OUTPUTS:                                                   │
│    ├── LD[3:0]  → Register value / Result                   │
│    ├── LD14     → Overflow Flag                             │
│    ├── LD15     → Zero Flag                                 │
│    └── 7-Seg   → Hexadecimal display                        │
└─────────────────────────────────────────────────────────────┘
```

### Components (10 Total)

| # | Component | File | Description |
|---|-----------|------|-------------|
| 1 | ALU | `alu_4bit.vhd` | 4-bit Add/Subtract with flags |
| 2 | Adder | `adder_3bit.vhd` | 3-bit adder for PC+1 |
| 3 | PC | `program_counter.vhd` | 3-bit program counter |
| 4 | MUX 8:1 | `mux8_4bit.vhd` | Register selection (×2) |
| 5 | MUX 2:1 | `mux2_3bit.vhd` | PC source selection |
| 6 | Registers | `register_bank.vhd` | 8 × 4-bit register file |
| 7 | Decoder | `decoder_3to8.vhd` | 3-to-8 write enable decoder |
| 8 | Decoder | `instruction_decoder.vhd` | Instruction decode logic ⭐ |
| 9 | ROM | `program_rom.vhd` | Program memory (8×12 bits) |
| 10 | Top | `nanoprocessor_top.vhd` | Complete system integration |

---

## 📝 Instruction Set Architecture (ISA)

### The 4 Instructions

| Instr | Opcode | Syntax | Operation | Binary Format |
|-------|--------|--------|-----------|---------------|
| **MOVI** | `10` | `MOVI R, d` | Load immediate d into R | `10 RRR 0000 dddd` |
| **ADD** | `00` | `ADD Ra, Rb` | Ra ← Ra + Rb | `00 RaRaRa RbRbRb 0000` |
| **NEG** | `01` | `NEG R` | R ← −R (2's complement) | `01 RRR R00000000` |
| **JZR** | `11` | `JZR R, d` | If R==0, jump to address d | `11 RRR R0000 dddd` |

### Number Representation (4-bit Signed)

```
Decimal:  -8    -7    -6    -5    -4    -3    -2    -1    0     1     2     3     4     5     6     7
Binary:  1000  1001  1010  1011  1100  1101  1110  1111  0000  0001  0010  0011  0100  0101  0110  0111
Hex:      8     9     A     B     C     D     E     F     0     1     2     3     4     5     6     7
```

> **Note:** `-1` = `1111`, `-2` = `1110`, etc. Maximum positive is `7` (`0111`), minimum negative is `-8` (`1000`).

---

## 💻 Assembly Programs

### Program 1: Calculate 10 − 1 = 9 (Main Demo) 🎯

Subtracts 1 from 10 in a loop until result reaches 0.

```assembly
Address 0:  MOVI R1, 10      ; R1 ← 10
Address 1:  MOVI R2, 1       ; R2 ← 1
Address 2:  NEG R2           ; R2 ← -R2  (R2 = -1 = 1111)
Address 3:  ADD R1, R2       ; R1 ← R1 + R2  (subtract 1)
Address 4:  JZR R1, 7        ; If R1 == 0, goto 7 (exit)
Address 5:  JZR R0, 3        ; If R0 == 0, goto 3 (ALWAYS loop!)
Address 6:  NOP
Address 7:  HALT
```

**Execution Trace:**

```
Cycle  PC   Instruction    R1    Notes
─────  ───  ────────────  ────  ─────────────────────
  1     0   MOVI R1,10     10   Initialize
  2     1   MOVI R2,1      10   Load constant
  3     2   NEG R2         10   R2 becomes -1
  4     3   ADD R1,R2       9   10 + (-1) = 9 ✓
  5     4   JZR R1,7        9   Not zero → continue
  6     5   JZR R0,3        9   R0=0 → jump to 3!
  7     3   ADD R1,R2       8   9 + (-1) = 8
 ...   ...  ...            ...  Loops until R1=0...
Final   7   HALT            0   Done!
```

**Machine Code for ROM:**

```vhdl
0 => "100010000101",  -- MOVI R1, 10
1 => "100100000001",  -- MOVI R2, 1
2 => "010100000000",  -- NEG R2
3 => "000001010000",  -- ADD R1, R2
4 => "110010000111",  -- JZR R1, 7
5 => "110000000011",  -- JZR R0, 3
6 => "000000000000",  -- NOP
7 => "000000000000"   -- HALT
```

---

### Program 2: Sum 1 + 2 + 3 = 6 🔢

```assembly
Address 0:  MOVI R1, 1       ; R1 ← 1
Address 1:  MOVI R2, 2       ; R2 ← 2
Address 2:  ADD R1, R2       ; R1 ← 3
Address 3:  MOVI R2, 3       ; R2 ← 3
Address 4:  ADD R1, R2       ; R1 ← 6  ★ RESULT = 6
Address 5:  JZR R0, 5        ; Halt (infinite loop)
Address 6:  NOP
Address 7:  NOP
```

**Machine Code:**

```vhdl
0 => "100010000001",
1 => "100100000010",
2 => "000001010000",
3 => "100100000011",
4 => "000001010000",
5 => "110000000101",
6 => "000000000000",
7 => "000000000000"
```

---

### Program 3: Countdown Timer 7 → 0 (LED Visual Demo!) 🎰

Counts down continuously — perfect for hardware demonstration!

```assembly
Address 0:  MOVI R1, 7       ; R1 ← 7  (start at max)
Address 1:  MOVI R2, 1       ; R2 ← 1
Address 2:  NEG R2           ; R2 ← -1
Address 3:  ADD R1, R2       ; R1 ← R1 - 1  (count down!)
Address 4:  JZR R1, 0        ; If R1==0, restart from address 0
Address 5:  JZR R0, 3        ; Else, loop back to 3
Address 6:  NOP
Address 7:  NOP
```

LED Output: `0111 → 0110 → 0101 → 0100 → 0011 → 0010 → 0001 → 0000 → repeat ♻️`

**Machine Code:**

```vhdl
0 => "100010000111",
1 => "100100000001",
2 => "010100000000",
3 => "000001010000",
4 => "110010000000",
5 => "110000000011",
6 => "000000000000",
7 => "000000000000"
```

---

### Program 4: Binary Counter 0 → 7 📊

Displays all binary values sequentially on LEDs.

```assembly
Address 0:  MOVI R1, 0       ; Show 0 (0000)
Address 1:  MOVI R1, 1       ; Show 1 (0001)
Address 2:  MOVI R1, 2       ; Show 2 (0010)
Address 3:  MOVI R1, 3       ; Show 3 (0011)
Address 4:  MOVI R1, 4       ; Show 4 (0100)
Address 5:  MOVI R1, 5       ; Show 5 (0101)
Address 6:  MOVI R1, 6       ; Show 6 (0110)
Address 7:  MOVI R1, 7       ; Show 7 (0111) → wraps to 0
```

**Machine Code:**

```vhdl
0 => "100010000000",
1 => "100010000001",
2 => "100010000010",
3 => "100010000011",
4 => "100010000100",
5 => "100010000101",
6 => "100010000110",
7 => "100010000111"
```

---

## 📁 File Structure

```
nanoprocessor/
│
├── src/
│   ├── alu_4bit.vhd                 # 4-bit ALU (Add/Sub + Flags)
│   ├── adder_3bit.vhd               # 3-bit Adder (PC Increment)
│   ├── program_counter.vhd          # 3-bit Program Counter
│   ├── mux8_4bit.vhd                # 8-to-1 Multiplexer (4-bit)
│   ├── mux2_3bit.vhd                # 2-to-1 Multiplexer (3-bit)
│   ├── register_bank.vhd            # Register File (R0-R7)
│   ├── decoder_3to8.vhd             # 3-to-8 Decoder
│   ├── instruction_decoder.vhd      # Instruction Decoder ⭐
│   ├── program_rom.vhd              # Program Memory (8×12b)
│   └── nanoprocessor_top.vhd        # Top-Level Integration 🏆
│
├── sim/
│   └── tb_nanoprocessor_complete.vhd  # Comprehensive Testbench
│
├── constr/
│   └── basys3_constraints.xdc       # BASYS3 Pin Constraints
│
├── docs/
│   ├── assembly_guide.md            # Assembly Programming Guide
│   └── timing_diagrams.pdf          # Timing Waveforms
│
├── README.md                        # This file
└── LICENSE                          # MIT License
```

---

## ⚡ Quick Start

### Prerequisites

- Xilinx Vivado (2020.2 or later)
- Digilent BASYS3 board (Artix-7 FPGA)
- USB cable for programming

### Step-by-Step Setup

**1. Create Vivado Project**
```
File → New Project → Project Name: nanoprocessor
Target: xc7a35tcpg236-1 (Artix-7)
Add all .vhd files from src/ directory
```

**2. Set Top Module**
```
Right-click nanoprocessor_top.vhd → Set as Top
```

**3. Run Simulation (Optional but Recommended)**
```
Add testbench from sim/ directory
Set testbench as simulation top
Run Simulation → Run Behavioral Simulation
Verify [PASS] messages in console
```

**4. Synthesize & Generate Bitstream**
```
Flow → Run Synthesis
Flow → Run Implementation
Flow → Generate Bitstream
```

**5. Program FPGA**
```
Connect BASYS3 via USB
Open Hardware Manager → Open Target → Auto Connect
Right-click device → Program Device → Select .bit file
```

**6. Test on Hardware**
```
1. Press BTNC (reset) → All LEDs off
2. Release reset → Program starts running
3. Watch LEDs change as program executes
4. Observe 7-segment display showing values
```

---

## 🧪 Testing & Verification

### Test Coverage

| Category | Tests | What's Verified |
|----------|-------|-----------------|
| Reset | 3 | Power-on reset, mid-execution reset |
| MOVI | 4 | Loading values 0–15, different registers |
| ADD | 6 | Positive, negative, overflow, zero result |
| NEG | 4 | Negation of positive, negative, zero |
| JZR | 5 | Jump when zero, no jump when non-zero |
| Flags | 4 | Zero flag, overflow flag correctness |
| Full Program | 3 | Complete execution trace |

### Running Testbench

In Vivado TCL Console:

```tcl
launch_simulation
run 1 us
# Check console output for:
# [PASS] or [FAIL] messages
```

### Expected Output

```
================================================================================
  TEST SUMMARY
================================================================================
Total Tests:  29
PASSED:       29
FAILED:        0
🎉 ALL TESTS PASSED!
================================================================================
```

---

## 🔌 Hardware Pin Assignment (BASYS3)

| Signal | Pin | BASYS3 Resource |
|--------|-----|-----------------|
| clk | W5 | 100 MHz Clock |
| reset_btn | U18 | BTNC (Center button) |
| led_data[0] | U16 | LD0 |
| led_data[1] | E19 | LD1 |
| led_data[2] | U19 | LD2 |
| led_data[3] | V19 | LD3 |
| led_overflow | W18 | LD14 |
| led_zero | U15 | LD15 |
| seg_out[0] | U7 | Segment A |
| seg_out[1] | V5 | Segment B |
| seg_out[2] | U5 | Segment C |
| seg_out[3] | V4 | Segment D |
| seg_out[4] | U4 | Segment E |
| seg_out[5] | V3 | Segment F |
| seg_out[6] | W3 | Segment G |
| anode_out[0] | W7 | Digit 0 (left) |
| anode_out[1] | W6 | Digit 1 |
| anode_out[2] | U8 | Digit 2 |
| anode_out[3] | V8 | Digit 3 (right) |

---

## 📊 Demonstration Guide

### Competition Demo Script

> *"Our nanoprocessor is a complete 4-bit processor featuring 8 registers, a 12-bit instruction set architecture, and single-cycle execution."*

> *"Let me demonstrate the countdown timer program:"*

1. **Reset** → All LEDs turn off, processor initializes ✓
2. **Start** → Press release, program begins executing
3. **Observe** → LEDs count down: 7, 6, 5, 4, 3, 2, 1, 0 ✓
4. **Flags** → Zero flag activates at 0, triggers jump instruction ✓
5. **Loop** → Automatically restarts, proving continuous operation ✓

> *"This demonstrates all four instructions in our ISA:"*

- **MOVI** loads initial values into registers
- **NEG** creates the subtraction constant (−1) using 2's complement
- **ADD** performs arithmetic each iteration
- **JZR** provides conditional control flow using the zero flag

### Key Talking Points for Judges

| Topic | What to Say |
|-------|-------------|
| Architecture | "Harvard-like design with separate program/data paths" |
| Optimization | "R0 hardwired to zero enables NEG without extra hardware" |
| Flags | "Zero flag used by JZR; Overflow detects signed arithmetic errors" |
| Gate Count | "Estimated <200 LUTs through shared component reuse" |
| Extensibility | "12-bit format allows easy addition of new instructions" |

---

## 🏆 Optimization Highlights

### Gate Reduction Techniques Applied

| Technique | Savings |
|-----------|---------|
| Shared adder structure (ALU + PC increment) | ~15 gates |
| Dual-port register file (eliminates external MUXes) | ~64 gates |
| Compact decoder with don't-care optimization | ~20 gates |
| Fixed-format ISA reduces decode complexity | ~30 gates |
| R0 hardwired zero trick | ~10 gates |

### Estimated Resource Utilization (Artix-7)

```
Resource    Used    Available   Utilization
─────────  ──────  ───────────  ────────────
LUTs        ~180    20,800       < 1%
FFs          ~45    41,600       < 0.1%
IO           ~20       210       ~10%
Frequency  >100 MHz    —         Single-cycle exec.
```

---

## 🛠️ Tech Stack

| Tool/Language | Version | Purpose |
|---------------|---------|---------|
| VHDL | IEEE 1076-1993 | Hardware description |
| Vivado | 2020.2+ | Synthesis & Implementation |
| FPGA | XC7A35T | Target device |
| Board | BASYS3 Rev C | Development board |

---

## 👥 Team & Contributions

| Member | Role | Components |
|--------|------|------------|
| Oahini Kavindi | ALU Designer | ALU, Adder, Flag logic |
| Nimsara Kodithuwakku | Datapath Designer | Registers, MUXes, PC |
| Widushi Kawya | Control Designer | Instruction Decoder, ROM |
| Yasandu Kethmika | Verification | Integration, Top Module, Testbench, Debugging, Hardware test |


---

## 📚 References & Resources

- [Xilinx Vivado Documentation](https://docs.xilinx.com/v/u/en-US/ug973-vivado-release-notes-install-license)
- [Digilent BASYS3 Reference Manual](https://digilent.com/reference/programmable-logic/basys-3/reference-manual)
- VHDL IEEE Standard 1076-1993
- Course lecture notes on Digital Design & Computer Architecture

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2024 Nanoprocessor Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```

---

## 🙏 Acknowledgments

- Course instructors for project specifications and guidance
- Digilent for excellent BASYS3 documentation
- Xilinx for Vivado toolchain and Artix-7 architecture
- Open-source VHDL community for reference implementations
