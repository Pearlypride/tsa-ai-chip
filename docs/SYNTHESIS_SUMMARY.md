# TSA Synthesis Summary

## Target

Current synthesis target:

- Tool: Yosys
- Flow: `synth_xilinx`
- FPGA family: Xilinx 7-series / `xc7`
- Top module: `tsa_axi_lite_top_8x8_i8`

## Design

TSA-2 AXI-Lite 8x8 is an INT8 systolic matrix accelerator IP-core.

Architecture:

- 8x8 systolic tile
- 64 processing elements
- signed INT8 inputs
- signed INT32 accumulators
- output-stationary dataflow
- AXI-Lite compatible host interface
- local A/B/C buffers
- start / busy / done_latched / valid_latched / irq control path

## Xilinx Mapping Result

| Resource | Count |
|---|---:|
| DSP48E1 | 64 |
| Total cells | 15544 |
| LUT1 | 7 |
| LUT2 | 84 |
| LUT3 | 174 |
| LUT4 | 3100 |
| LUT5 | 142 |
| LUT6 | 1381 |
| Warnings | 7 |

## Interpretation

The most important result is:

    DSP48E1 = 64

This means the 64 INT8 multiply-accumulate processing elements map to Xilinx DSP blocks instead of being implemented purely in LUT logic.

This is a strong FPGA-readiness signal for the current PE implementation.

## Warning Analysis

The warnings are memory-to-register replacement warnings:

- `A`
- `B`
- `a_feed`
- `b_feed`
- `mem_a`
- `mem_b`
- `mem_c`

These are not functional errors.

Yosys is reporting that small arrays were expanded into registers instead of being mapped into explicit BRAM/LUTRAM macros.

## What This Proves

This synthesis run proves:

- RTL is synthesizable through Yosys.
- TSA-2 hierarchy is preserved.
- 64 PE cells are preserved.
- DSP inference works.
- AXI-Lite wrapper synthesizes.
- No fatal synthesis errors were reported.
- No critical latch inference was observed.

## What This Does Not Prove Yet

This is not yet a final FPGA implementation report.

Still missing:

- Vivado synthesis report
- place-and-route
- timing closure
- Fmax
- power estimate
- concrete FPGA board utilization
- hardware execution on a real board

## Next Step

Run Vivado against a concrete Zynq target, preferably:

- PYNQ-Z2
- Zynq-7020
- AXI-Lite IP integration
- Python driver
- Jupyter demo
