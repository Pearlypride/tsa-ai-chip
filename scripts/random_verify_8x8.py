import os
import subprocess
import numpy as np
from pathlib import Path

ROOT = Path.home() / "tsa-ai-chip"
TB_PATH = ROOT / "tb" / "tsa_systolic_8x8_random_tb.sv"
SIM_PATH = ROOT / "build" / "tsa_systolic_8x8_random_sim"

N = 8
TESTS = 30
RNG = np.random.default_rng(888)

def sv_i8(x: int) -> str:
    if x < 0:
        return f"-8'sd{abs(x)}"
    return f"8'sd{x}"

def sv_i32(x: int) -> str:
    if x < 0:
        return f"-32'sd{abs(x)}"
    return f"32'sd{x}"

def generate_tb(A, B, C, test_id):
    text = f"""`timescale 1ns/1ps

module tsa_systolic_8x8_random_tb;

    reg clk;
    reg reset;
    reg start;

"""

    for r in range(N):
        text += "    reg signed [7:0] " + ", ".join([f"a{r}{c}" for c in range(N)]) + ";\n"

    text += "\n"

    for r in range(N):
        text += "    reg signed [7:0] " + ", ".join([f"b{r}{c}" for c in range(N)]) + ";\n"

    text += "\n"

    for r in range(N):
        text += "    wire signed [31:0] " + ", ".join([f"c{r}{c}" for c in range(N)]) + ";\n"

    text += """
    wire busy;
    wire done;
    wire valid;

    tsa_systolic_8x8_core_i8 dut (
        .clk(clk),
        .reset(reset),
        .start(start),

"""

    for r in range(N):
        for c in range(N):
            text += f"        .a{r}{c}(a{r}{c}),\n"

    text += "\n"

    for r in range(N):
        for c in range(N):
            text += f"        .b{r}{c}(b{r}{c}),\n"

    text += "\n"

    for r in range(N):
        for c in range(N):
            text += f"        .c{r}{c}(c{r}{c}),\n"

    text += """
        .busy(busy),
        .done(done),
        .valid(valid)
    );

    always begin
        #5 clk = ~clk;
    end

    initial begin
        clk = 0;
        reset = 1;
        start = 0;

"""

    for r in range(N):
        for c in range(N):
            text += f"        a{r}{c} = 0;\n"

    for r in range(N):
        for c in range(N):
            text += f"        b{r}{c} = 0;\n"

    text += """
        #10;
        reset = 0;

"""

    for r in range(N):
        for c in range(N):
            text += f"        a{r}{c} = {sv_i8(int(A[r, c]))};\n"

    text += "\n"

    for r in range(N):
        for c in range(N):
            text += f"        b{r}{c} = {sv_i8(int(B[r, c]))};\n"

    text += """
        #10;
        start = 1;
        #10;
        start = 0;

        wait(valid == 1'b1);
        #1;

        if (
"""

    checks = []
    for r in range(N):
        for c in range(N):
            checks.append(f"            c{r}{c} == {sv_i32(int(C[r, c]))}")

    text += " &&\n".join(checks)

    text += f"""
        ) begin
            $display("RANDOM 8x8 TEST {test_id}: PASS");
        end else begin
            $display("RANDOM 8x8 TEST {test_id}: FAIL");
            $display("Output:");
"""

    for r in range(N):
        fmt = " ".join(["%d"] * N)
        args = ", ".join([f"c{r}{c}" for c in range(N)])
        text += f'            $display("{fmt}", {args});\n'

    text += """
            $display("Expected:");
"""

    for r in range(N):
        row = " ".join([str(int(C[r, c])) for c in range(N)])
        text += f'            $display("{row}");\n'

    text += """
        end

        #20;
        $finish;
    end

endmodule
"""

    TB_PATH.write_text(text)

def run_one(test_id: int) -> bool:
    A = RNG.integers(-8, 9, size=(N, N), dtype=np.int32)
    B = RNG.integers(-8, 9, size=(N, N), dtype=np.int32)
    C = A @ B

    generate_tb(A, B, C, test_id)

    compile_cmd = [
        "iverilog", "-g2012",
        "-o", str(SIM_PATH),
        str(ROOT / "rtl" / "tsa_pe_i8.v"),
        str(ROOT / "rtl" / "tsa_systolic_8x8_i8.sv"),
        str(ROOT / "rtl" / "tsa_systolic_8x8_core_i8.sv"),
        str(TB_PATH),
    ]

    subprocess.run(compile_cmd, cwd=ROOT, check=True)

    result = subprocess.run(
        ["vvp", str(SIM_PATH)],
        cwd=ROOT,
        text=True,
        capture_output=True,
        check=True
    )

    ok = "PASS" in result.stdout and "FAIL" not in result.stdout

    if not ok:
        print(result.stdout)

    return ok

def main():
    os.makedirs(ROOT / "build", exist_ok=True)
    os.makedirs(ROOT / "tb", exist_ok=True)

    passed = 0

    for i in range(TESTS):
        if run_one(i):
            passed += 1
            print(f"[{i+1:03d}/{TESTS}] PASS")
        else:
            print(f"[{i+1:03d}/{TESTS}] FAIL")
            break

    print()
    print("TSA-2 8x8 random verification")
    print(f"Passed: {passed}/{TESTS}")

    if passed == TESTS:
        print("RESULT: ALL TESTS PASSED")
    else:
        print("RESULT: FAILED")

if __name__ == "__main__":
    main()
