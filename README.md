# CipherStream-128X: Pipelined AES-128 Hardware Accelerator

## Overview
This project is a high-throughput, fully pipelined AES-128 encryption engine written in Verilog. It is wrapped in an AXI4-Lite interface for seamless integration into SoC environments (like the Xilinx Zynq-7000). Designed for continuous streaming data, this architecture achieves deterministic, stall-free encryption during steady-state operation.

## Key Architectural Features

### 1. Fully Unrolled 11-Stage Pipeline
The core datapath is fully unrolled into 11 discrete stages (Initial AddRoundKey + 10 standard AES rounds). By utilizing arrays of D-Flip Flops governed by a global Clock Enable (`ce`) signal, the engine can accept a new 128-bit plaintext block on every single clock cycle.

### 2. On-the-Fly Key Expansion
Unlike combinational key schedulers that create massive timing bottlenecks, this architecture pipelines the key expansion directly alongside the data. The key is calculated step-by-step and propagated through the pipeline registers. This provides two major advantages:
*   **High Frequency:** Significantly reduces the critical path, allowing the maximum clock frequency ($F_{max}$) to be ~120 MHz.
*   **Data Integrity:** Dynamic master key updates will never corrupt in-flight data, as each block travels down the conveyor belt with its own mathematically locked round keys.

### 3. AXI4-Lite Backpressure Engine
The wrapper manages the 32-bit AXI memory-mapped data transfers from the CPU and translates them into the 128-bit internal buses. It features a dedicated backpressure engine: if the software cannot read the ciphertext fast enough, or if the bus is congested, the wrapper drops the `ce` signal, safely freezing all 11 stages of the pipeline simultaneously without dropping any data.

## Memory Map (Software Interface)
The AXI4-Lite slave interface maps the hardware to the following byte offsets for easy C/C++ driver integration:

| Offset | Name | Type | Description |
| :--- | :--- | :--- | :--- |
| `0x00` | CTRL | Write | Write `1` to bit 0 to start encryption. |
| `0x04` | STATUS | Read | Bit 0 = Busy, Bit 1 = Idle, Bit 2 = Done. |
| `0x10` - `0x1C` | KEY_0 to KEY_3 | Write | 128-bit Master Key. |
| `0x20` - `0x2C` | DATA_IN_0 to _3 | Write | 128-bit Plaintext input block. |
| `0x30` - `0x3C` | DATA_OUT_0 to _3 | Read | 128-bit Ciphertext output block. |

## Current Status & Future Implementations (Work in Progress)
This repository is currently under active development. 

**Implemented Features:**
*   FIPS-197 compliant AES-128 core
*   Fully unrolled pipeline with on-the-fly key expansion
*   AXI4-Lite wrapper with dynamic stall logic
*   **ECB (Electronic Codebook)** Mode of Operation

**Coming Soon:**
*   Implementation of **CBC (Cipher Block Chaining)** Mode
*   Implementation of **CTR (Counter)** Mode for advanced stream-cipher workloads
