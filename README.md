# Dual-Core Quad Hardware-Threaded ARM ISA-Compatible CPU

## Overview

This repository contains the design and implementation of a **dual-core, quad-hardware-threaded, ARM-ISA-compatible, pipelined processor**. The design integrates two independent quad hardware-threaded ARM ISA-compatible processors, with both cores sharing a common data memory. Together, the two cores support up to **eight concurrent hardware threads**, enabling multiple threads to execute instructions simultaneously and improving overall throughput and resource utilization.

Since both cores access the same data memory, additional mechanisms are required to detect and handle cross-core memory hazards, ensuring a consistent view of shared memory and maintaining correct program execution.

The processor is written in Verilog and targets Xilinx FPGAs. The implementation has been tested on the NetFPGA v2 platform.

## Instruction Encoding

![ISA Encoding Diagram](ARM_ISA.png)
<!-- TODO: add ISA/instruction encoding diagram image -->

All instructions are 32 bits wide with a common field layout:

| Bits    | 31:28 | 27:26 | 25  | 24:21    | 20  | 19:16 | 15:12 | 11:0                |
|---------|-------|-------|-----|----------|-----|-------|-------|---------------------|
| Field   | Cond  | Type  | Imm | Opcode   | Set | Rn    | Rd    | Operand / Rs / Offset |

- **Cond** — 4-bit condition field, evaluated against the NZCV flags to decide whether the instruction executes
- **Type** — top-level instruction class (`00` = data processing, `01` = load/store, `10` = branch)
- **Imm** — selects between register operand (`Rs`, bits [3:0]) and immediate operand (bits [11:0]) for data-processing instructions
- **Opcode** — selects the specific ALU/data-processing operation
- **Set** — when asserted, the instruction updates the NZCV flags
- **Rn** — first source register
- **Rd** — destination register (data processing) or source/destination register (load/store)
- **Operand / Address offset** — immediate value, shifted register, or memory addressing offset depending on instruction class

### Data Processing (Type = `00`)

| Mnemonic | Opcode [24:21] | Operation                  |
|----------|----------------|-----------------------------|
| AND      | `0000`         | Rd = Rn & Operand            |
| XOR      | `0001`         | Rd = Rn ^ Operand            |
| SUB      | `0010`         | Rd = Rn − Operand            |
| RSUB     | `0011`         | Rd = Operand − Rn (reverse subtract) |
| ADD      | `0100`         | Rd = Rn + Operand            |
| ADC      | `0101`         | Rd = Rn + Operand + Carry    |
| SUBC     | `0110`         | Rd = Rn − Operand − !Carry   |
| RSUBC    | `0111`         | Rd = Operand − Rn − !Carry   |
| TST      | `1000`         | Rn & Operand (flags only, no writeback) |
| TEQ      | `1001`         | Rn ^ Operand (flags only, no writeback) |
| CMP      | `1010`         | Rn − Operand (flags only, no writeback) |
| CMN      | `1011`         | Rn + Operand (flags only, no writeback) |
| OR       | `1100`         | Rd = Rn \| Operand           |
| LSL/MOV  | `1101`         | Rd = Operand (optionally shifted) |
| BIC      | `1110`         | Rd = Rn & ~Operand (bit clear) |
| INV      | `1111`         | Rd = ~Operand (bitwise NOT)  |

All data-processing instructions update the NZCV flags when **Set** (bit 20) is asserted. `TST`, `TEQ`, `CMP`, and `CMN` always compute their result for flag-setting purposes only and never write back to `Rd`.

### Load/Store (Type = `01`)

| Mnemonic | Bit 24 (Imm) | Bits [23:20] (P, U, B, W) | Operation |
|----------|--------------|----------------------------|-----------|
| LW       | `0`          | P, U, B, W, **L=1**        | Rd = Mem[Rn + Address offset] |
| SW       | `0`          | P, U, B, W, **L=0**        | Mem[Rn + Address offset] = Rd |

- **P** — pre/post-indexed addressing select
- **U** — up/down (add/subtract offset)
- **B** — byte/word access size
- **W** — writeback of the computed address into `Rn`
- **L** — load (1) vs. store (0), distinguishing `LW` from `SW`

### Branch (Type = `10`)

| Field          | Bits     | Description |
|----------------|----------|--------------|
| L              | `25`     | Link bit — when set, stores the return address (branch-and-link) |
| Signed Immediate | `[23:0]` | 24-bit signed offset, sign-extended and shifted for word alignment, added to the PC |

Branches are conditionally executed based on the 4-bit **Cond** field evaluated against the current NZCV flags (e.g. `EQ`, `NE`, `GT`, `LT`, always/never, etc.), matching the condition-code scheme of classic ARM branch instructions.

## Pipeline Stages

The processor is organized into five stages:

```
IF  →  ID  →  EX  →  MEM  →  WB
```

| Stage | Name              | Function                                                                 |
|-------|-------------------|---------------------------------------------------------------------------|
| IF    | Instruction Fetch | Fetch instruction from instruction memory using PC                       |
| ID    | Decode            | Decode instruction, read register file, generate control signals         |
| EX    | Execute           | ALU operations, branch target/condition resolution, NZCV flag generation |
| MEM   | Memory            | Data memory access (loads/stores) via block RAM                          |
| WB    | Writeback         | Write result back to register file                                       |
