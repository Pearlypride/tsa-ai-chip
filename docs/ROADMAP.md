# TSA Roadmap

## Completed

### TSA-1

- 4x4 INT8 systolic core
- 16 PE
- local-memory/MMIO top
- AXI-Lite wrapper
- 50/50 random verification
- visual matrix report
- timeline report

### TSA-2

- 8x8 INT8 systolic core
- 64 PE
- AXI-Lite wrapper
- 30/30 random verification
- full card-style test
- generic Yosys synthesis
- Xilinx 7-series `synth_xilinx` mapping
- DSP48E1 inference confirmed

## Current Status

TSA-2 is a synthesis-mapped AXI-Lite compatible INT8 systolic AI accelerator IP-core.

Current strongest result:

    TSA-2 8x8 maps to 64 DSP48E1 blocks on Xilinx 7-series synthesis flow.

## Next Priority

### 1. Vivado FPGA Flow

Goal:

- synthesize for a real Zynq target
- obtain LUT/FF/DSP/BRAM utilization
- obtain timing/Fmax
- check whether design closes timing

Preferred board:

- PYNQ-Z2
- Zynq-7020

### 2. PYNQ Python Driver

Goal:

- load matrices from Python
- write A/B through MMIO
- start accelerator
- poll done_latched
- read C
- compare against NumPy

### 3. Real Board Demo

Goal:

- run TSA on an actual FPGA board
- show host-to-accelerator flow
- optionally blink LED on irq/done

### 4. TSA-3 Tiled GEMM Engine

Goal:

- compute larger matrices using 8x8 tiles
- support accumulate mode:

    C = C + A_tile x B_tile

Target sizes:

- 16x16
- 32x32
- 64x64

### 5. INT8 MNIST Inference

Goal:

- run a tiny MLP inference workload
- prove TSA is used as an AI accelerator, not only a matrix multiplier

Possible network:

    784 -> 64 -> 10

## Later Research Ideas

- structured sparsity
- INT4 mode
- bit-serial PE
- transformer attention microbenchmark
- OpenLane/Sky130 exploration
