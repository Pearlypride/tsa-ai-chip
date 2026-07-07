I started building a tiny AI accelerator from scratch.

Not a CUDA kernel.
Not a library.
Actual RTL.

The project is called TSA — Tiny Systolic Accelerator.

Current status:

- 4x4 INT8 systolic accelerator
- 8x8 INT8 systolic accelerator
- 16 PE version
- 64 PE version
- signed INT8 inputs
- signed INT32 accumulation
- output-stationary dataflow
- AXI-Lite compatible host interface
- stable done/valid/irq status registers
- W1C clear_done behavior
- NumPy reference verification
- random stress tests
- visual matrix reports
- waveform/timeline reports
- Yosys synthesis
- Xilinx 7-series synthesis mapping

The 8x8 version now runs through an AXI-Lite style testbench:

Host writes matrix A.
Host writes matrix B.
Host writes CTRL.start.
Accelerator computes INT8 matrix multiplication.
Host waits for done_latched.
Host reads matrix C.
Result is compared with NumPy.

Current verification:

- 4x4 memory interface test: PASS
- 4x4 AXI-Lite IP-core test: PASS
- 4x4 random verification: 50/50 PASS
- 8x8 raw systolic core: PASS
- 8x8 random verification: 30/30 PASS
- 8x8 AXI-Lite IP-core: PASS
- full card-style accelerator test: PASS

Current synthesis result:

- Target: Xilinx 7-series flow through Yosys synth_xilinx
- DSP48E1: 64
- Total cells: 15544
- The 64 PE array maps to FPGA DSP blocks

This is not a GPU replacement.

It is a compact FPGA/ASIC learning project and a synthesis-mapped AI accelerator IP-core prototype.

Next steps:

- Vivado synthesis for a concrete Zynq target
- timing/Fmax report
- PYNQ Python driver
- real FPGA board demo
- tiled GEMM engine
- INT8 MNIST inference

Building hardware is slow.

But seeing your own matrix accelerator pass simulation, random verification, AXI-Lite host tests, and Xilinx synthesis mapping hits different.
