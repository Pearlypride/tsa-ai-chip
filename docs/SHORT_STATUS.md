# TSA Short Status

TSA is a synthesis-mapped INT8 systolic AI accelerator IP-core.

Current version:

- TSA-1: 4x4, 16 PE, AXI-Lite, PASS
- TSA-2: 8x8, 64 PE, AXI-Lite, PASS
- INT8 inputs
- INT32 accumulation
- output-stationary dataflow
- AXI-Lite host interface
- stable done/valid/irq handshake
- W1C clear_done
- 50/50 random tests for 4x4
- 30/30 random tests for 8x8
- Yosys generic synthesis PASS
- Xilinx 7-series synth_xilinx mapping PASS
- DSP48E1 inferred: 64

Next:

- Vivado synthesis
- Fmax/timing report
- PYNQ/Zynq driver
- real FPGA board demo
- tiled GEMM
- MNIST INT8 inference
