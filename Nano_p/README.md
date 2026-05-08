# 4-bit Nanoprocessor — FPGA Project

**University of Moratuwa** | Team: `240348`, `240351`, `240347`, `240343`  
**Target Board:** Digilent Basys3 (Artix-7 XC7A35T-1CPG236C)  
**Language:** VHDL-93 | **Clock:** 100 MHz → ~0.5 Hz

---

## 📁 File Overview

| File | Description |
|------|-------------|
| `program_counter.vhd` | 3-bit PC — async reset, enable, load-for-jump |
| `program_rom.vhd` | 8 × 12-bit ROM — countdown R1: 10 → 0, then halt |
| `register_bank.vhd` | 8 × 4-bit registers — R0 hardwired to `0000` |
| `adder_4bit.vhd` | 4-bit adder/subtractor — Zero, Overflow, Carry flags |
| `adder_3bit.vhd` | 3-bit adder — PC increment helper |
| `alu_enhanced.vhd` | 8-op ALU: ADD SUB AND OR XOR NOT SHL SHR |
| `comparator_4bit.vhd` | 4-bit signed/unsigned comparator (competition bonus) |
| `mux_8way_4bit.vhd` | 8-to-1 MUX, 4-bit wide |
| `mux_2way_3bit.vhd` | 2-to-1 MUX, 3-bit wide |
| `decoder_3to8.vhd` | 3-to-8 decoder — register write-enable |
| `nanoprocessor_top.vhd` | **Main top-level** — structural, all components wired |
| `nanoprocessor_top_VISIBLE.vhd` | **Demo top-level** — 4-digit 7-seg, 16 LEDs |
| `tb_alu_enhanced.vhd` | ALU testbench (VHDL-93, full assert coverage) |
| `tb_nanoprocessor.vhd` | System testbench + fast behavioral sim |
| `nanoprocessor_basys3.xdc` | Vivado XDC pin constraints for Basys3 |
| `create_project.tcl` | Vivado TCL — one-click project creation |

---

## ⚙️ Instruction Set Architecture

| Opcode | Mnemonic | Encoding [11:0] | Operation |
|--------|----------|-----------------|-----------|
| `00` | `ADD RA, RB` | `00_RA_RB_0000` | RA ← RA + RB |
| `01` | `NEG RA` | `01_RA_000_0000` | RA ← 0 − RA |
| `10` | `MOVI RA, imm` | `10_RA_000_imm4` | RA ← imm[3:0] |
| `11` | `JZR RA, addr` | `11_RA_000_addr3` | if RA=0: PC ← addr[2:0] |

> **R0 is always 0** — `JZR R0, addr` is an **unconditional jump**.

---

## 🧠 ROM Program — Countdown 10 → 0

```
Addr 0: MOVI R1, 10   → 100010001010   R1 ← 10
Addr 1: MOVI R2,  1   → 100100000001   R2 ← 1
Addr 2: NEG  R2        → 010100000000   R2 ← -1
Addr 3: ADD  R1, R2   → 000001010000   R1 ← R1 - 1
Addr 4: JZR  R1, 7    → 110010000111   if R1=0 → halt
Addr 5: JZR  R0, 3    → 110000000011   unconditional → Addr 3
Addr 6: NOP            → 000000000000   (never reached)
Addr 7: JZR  R0, 7    → 110000000111   halt (infinite loop)
```

---

## 🔌 Board I/O Mapping

| Signal | Basys3 | Description |
|--------|--------|-------------|
| `clk` | W5 | 100 MHz onboard clock |
| `reset_btn` | U18 (BTNC) | Async reset |
| `led[3:0]` | LD3–LD0 | R1 value (countdown) |
| `led[4]` | LD4 | Zero flag |
| `led[5]` | LD5 | Overflow flag |
| `led[6]` | LD6 | PC[1] |
| `led[7]` | LD7 | PC[2] |
| `zero_flag` | LD14 | Zero flag |
| `ovf_flag` | LD15 | Overflow flag |
| `seg_led[6:0]` | 7-seg segments a–g | Active-low |
| `anode[3:0]` | Digit select | Active-low |

### VISIBLE Version extra LEDs
| Signal | Basys3 | Description |
|--------|--------|-------------|
| `led[8]` | LD8 | Heartbeat (slow_clk) |
| `led[11:9]` | LD11–LD9 | Full PC value |
| `led[13:12]` | LD13–LD12 | Opcode |

### 7-Segment (VISIBLE version)
| Digit | Shows |
|-------|-------|
| 3 (leftmost) | R1 high nibble (always `0`) |
| 2 | R1 value (0–F hex) |
| 1 | Opcode glyph: `A`=ADD `E`=NEG `I`=MOVI `J`=JZR |
| 0 (rightmost) | PC value (0–7) |

---

## 🚀 Vivado Setup — Step by Step

### Option A: TCL Script (Recommended)
1. Open **Vivado → Tcl Console**
2. Run:
   ```tcl
   cd C:/Users/DELL/Desktop/Nano_p
   source create_project.tcl
   ```
3. Project is ready. Proceed to **Flow → Run Synthesis**.

### Option B: Manual
1. **File → Project → New**
2. Part: `xc7a35tcpg236-1` (Basys3)
3. Add all `.vhd` files as sources
4. Add `nanoprocessor_basys3.xdc` as constraint
5. Set top: `nanoprocessor_top` (or `nanoprocessor_top_VISIBLE`)

### To switch to VISIBLE version
```tcl
set_property top nanoprocessor_top_VISIBLE [current_fileset]
update_compile_order -fileset sources_1
```

---

## 🧪 Simulation

### ALU Testbench
```tcl
set_property top tb_alu_enhanced [get_filesets sim_1]
launch_simulation
```
Tests all 8 ALU ops with assert statements — check Tcl console for PASS/FAIL.

### System Testbench (fast behavioral)
```tcl
set_property top tb_nanoprocessor_fast [get_filesets sim_1]
launch_simulation
run 5000ns
```
Runs the countdown behaviorally in ~200ns using a 4-cycle clock divider.

---

## 🏆 Competition Features

| Feature | Component | Notes |
|---------|-----------|-------|
| 4-bit signed/unsigned comparator | `comparator_4bit.vhd` | Bonus hardware |
| 8-operation enhanced ALU | `alu_enhanced.vhd` | ADD SUB AND OR XOR NOT SHL SHR |
| Signed overflow detection | `adder_4bit.vhd` | Both add and subtract |
| Live PC on 7-segment | `nanoprocessor_top.vhd` | Active-low, Basys3 native |
| 4-digit multiplexed display | `nanoprocessor_top_VISIBLE.vhd` | PC + opcode + R1 value |
| Slow clock (0.5 Hz visible) | Both top-levels | 100M ÷ 50M counter |
| Zero & Overflow LEDs | LD4, LD5, LD14, LD15 | Real-time flag display |

---

## ⚠️ VHDL-93 Compliance Notes

- No `to_string()` — use `report "..."` with constants
- No `'image` on `STD_LOGIC_VECTOR` — use integer reports
- No reading from `out` ports — internal signals used throughout
- No VHDL-2008 features
- `STD_LOGIC_UNSIGNED` and `STD_LOGIC_ARITH` used for arithmetic

---

*Good luck at the competition! 🎓 — Team 240348, 240351, 240347, 240343*
