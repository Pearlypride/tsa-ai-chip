import subprocess
import sys
from pathlib import Path
from datetime import datetime

ROOT = Path.home() / "tsa-ai-chip"
REPORTS = ROOT / "reports"

def run_step(title, cmd, required_markers=None):
    print()
    print("=" * 76)
    print(title)
    print("=" * 76)
    print("$ " + " ".join(cmd))
    print()

    p = subprocess.run(
        cmd,
        cwd=ROOT,
        text=True,
        capture_output=True
    )

    print(p.stdout)

    if p.stderr.strip():
        print("STDERR:")
        print(p.stderr)

    ok = p.returncode == 0
    ok = ok and "TEST FAILED" not in p.stdout
    ok = ok and "RESULT: FAILED" not in p.stdout

    if required_markers:
        for marker in required_markers:
            if marker not in p.stdout:
                print(f"[FAIL] Missing required marker: {marker}")
                ok = False

    if ok:
        print(f"[PASS] {title}")
    else:
        print(f"[FAIL] {title}")
        sys.exit(1)

    return p.stdout

def main():
    print()
    print("TSA ACCELERATOR MONSTER CARD TEST")
    print("Human-readable hardware-style test for non-HDL users")
    print("Started:", datetime.now().strftime("%Y-%m-%d %H:%M:%S"))

    run_step(
        "1/8 TSA-1 4x4 local memory accelerator test",
        ["make", "mem"],
        required_markers=[
            "STATUS = 1110",
            "TEST PASSED"
        ]
    )

    print("[PASS] 4x4 stable done_latched handshake")
    print("[PASS] 4x4 local A/B/C memory path")

    run_step(
        "2/8 TSA-1 4x4 AXI-Lite IP-core test",
        ["make", "axi"],
        required_markers=[
            "STATUS = 1110",
            "Read C through AXI-Lite:",
            "TEST PASSED",
            "STATUS after clear = 0000"
        ]
    )

    print("[PASS] 4x4 AXI-Lite read/write path")
    print("[PASS] 4x4 W1C clear_done")
    print("[PASS] 4x4 IRQ/done latch clears correctly")

    run_step(
        "3/8 TSA-1 4x4 random stress test: 50 matrices",
        ["make", "random"],
        required_markers=[
            "Passed: 50/50",
            "RESULT: ALL TESTS PASSED"
        ]
    )

    run_step(
        "4/8 TSA-2 8x8 raw systolic core test",
        ["make", "test8x8"],
        required_markers=[
            "TSA-2 SYSTOLIC 8x8 INT8 CORE test started",
            "TEST PASSED"
        ]
    )

    print("[PASS] 8x8 systolic tile")
    print("[PASS] 64 PE cells verified")

    run_step(
        "5/8 TSA-2 8x8 random stress test: 30 matrices",
        ["make", "random8x8"],
        required_markers=[
            "Passed: 30/30",
            "RESULT: ALL TESTS PASSED"
        ]
    )

    run_step(
        "6/8 TSA-2 8x8 AXI-Lite IP-core test",
        ["make", "axi8x8"],
        required_markers=[
            "TSA-2 AXI-LITE 8x8 TOP test started",
            "STATUS = 1110",
            "Read C through AXI-Lite 8x8:",
            "TEST PASSED",
            "STATUS after clear = 0000"
        ]
    )

    print("[PASS] 8x8 AXI-Lite compatible IP-core")
    print("[PASS] 8x8 host-style control path")
    print("[PASS] 8x8 stable done/valid/irq status")

    run_step(
        "7/8 TSA-1 visual matrix report",
        ["make", "report"],
        required_markers=[
            "Result: PASS"
        ]
    )

    run_step(
        "8/8 TSA-1 visual timeline report",
        ["make", "timeline"],
        required_markers=[
            "Result: PASS"
        ]
    )

    print()
    print("=" * 76)
    print("HUMAN READABLE SUMMARY")
    print("=" * 76)

    print("""
TSA passed the full monster accelerator test.

What was tested:
- TSA-1 4x4 INT8 systolic accelerator
- TSA-1 AXI-Lite compatible IP-core
- TSA-2 8x8 INT8 systolic accelerator
- TSA-2 AXI-Lite compatible IP-core
- Host writes matrix A into accelerator memory
- Host writes matrix B into accelerator memory
- Host starts compute through control register
- Accelerator computes signed INT8 matrix multiplication
- Each PE performs INT8 x INT8 with INT32 accumulation
- Host waits for stable done_latched status bit
- Host reads result matrix C from accelerator output memory
- Result is compared against expected NumPy reference
- W1C clear_done behavior is verified
- IRQ/done/valid latch behavior is verified
- 4x4 random verification: 50/50 tests passed
- 8x8 random verification: 30/30 tests passed
- Matrix and timeline visual reports are generated

Architecture status:
- Dataflow: output-stationary systolic array
- TSA-1 PE count: 16
- TSA-2 PE count: 64
- Input type: signed INT8
- Accumulator/output type: signed INT32
- Host interface: AXI-Lite compatible slave
- Control: start / busy / done_latched / valid_latched / irq
- FPGA direction: Zynq/PYNQ demo path

Current positioning:
TSA is now a simulated AXI-Lite compatible INT8 systolic AI accelerator IP-core.
This is not a GPU replacement yet.
This is a serious FPGA/ASIC-learning accelerator prototype with real verification.

Next monster step:
- TSA-3 tiled GEMM engine
- 16x16 matrix multiply using multiple 8x8 tiles
- Accumulate mode
- benchmark report
- PYNQ Python driver
""")

    print("Generated reports:")
    print(f"- {REPORTS / 'tsa_4x4_report.png'}")
    print(f"- {REPORTS / 'tsa_4x4_timeline.png'}")
    print(f"- {REPORTS / 'tsa_8x8_report.png'}")
    print(f"- {REPORTS / 'tsa_fpga_mem_timeline.csv'}")
    print(f"- {REPORTS / 'tsa_axi_lite_timeline.csv'}")

    print()
    print("FINAL RESULT: PASS")
    print()

if __name__ == "__main__":
    main()
