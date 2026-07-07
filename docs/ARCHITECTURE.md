# TSA Architecture

## Overview

TSA is an INT8 systolic matrix accelerator.

The current design contains two generations:

- TSA-1: 4x4 tile, 16 PE
- TSA-2: 8x8 tile, 64 PE

Both use the same core idea:

    INT8 x INT8 -> INT32 accumulation

## Processing Element

Each PE receives:

- `a_in`
- `b_in`
- `enable`
- `clear`

Each PE outputs:

- `a_out`
- `b_out`
- `acc`

Operation:

    if clear:
        acc = 0
    else if enable:
        acc = acc + a_in * b_in

The PE also forwards A to the right and B downward.

## Dataflow

TSA uses output-stationary dataflow.

Meaning:

- A moves horizontally through rows.
- B moves vertically through columns.
- C remains stationary inside the PE accumulator.

This is suitable for small matrix tiles and is conceptually similar to tensor/tile compute blocks.

## TSA-2 8x8 Tile

TSA-2 contains:

- 8 rows
- 8 columns
- 64 processing elements

The array computes:

    C[8x8] = A[8x8] x B[8x8]

The controller feeds skewed A/B streams into the systolic array and waits for the computation window to complete.

## AXI-Lite Wrapper

The AXI-Lite wrapper exposes the accelerator to a host-style interface.

Registers:

| Address Range | Function |
|---|---|
| 0x000 | CTRL |
| 0x004 | STATUS |
| 0x100..0x1FC | A buffer |
| 0x200..0x2FC | B buffer |
| 0x300..0x3FC | C buffer |

STATUS bits:

| Bit | Name |
|---:|---|
| 0 | busy |
| 1 | done_latched |
| 2 | valid_latched |
| 3 | irq |

CTRL bits:

| Bit | Name |
|---:|---|
| 0 | start |
| 1 | clear_done / W1C |

## Host Flow

1. Write matrix A into A buffer.
2. Write matrix B into B buffer.
3. Write CTRL.start.
4. Poll STATUS.done_latched.
5. Read matrix C from C buffer.
6. Clear done/irq using CTRL.clear_done.

## Verification Strategy

Verification includes:

- deterministic matrix test
- random matrix verification against NumPy
- AXI-Lite host-style testbench
- status/irq handshake verification
- W1C clear_done verification
- visual matrix report
- timeline report
- synthesis checks
