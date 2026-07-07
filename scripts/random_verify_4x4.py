import os
import subprocess
import numpy as np
from pathlib import Path

ROOT = Path.home() / "tsa-ai-chip"
TB_PATH = ROOT / "tb" / "tsa_systolic_4x4_random_tb.sv"
SIM_PATH = ROOT / "build" / "tsa_systolic_4x4_random_sim"

TESTS = 50
RNG = np.random.default_rng(42)

def sv_num(x: int) -> str:
    if x < 0:
        return f"-8'sd{abs(x)}"
    return f"8'sd{x}"

def expected_num(x: int) -> str:
    if x < 0:
        return f"-32'sd{abs(x)}"
    return f"32'sd{x}"

def generate_tb(A, B, C, test_id):
    a_assign = []
    b_assign = []
    checks = []

    for r in range(4):
        for c in range(4):
            a_assign.append(f"        a{r}{c} = {sv_num(int(A[r, c]))};")
            b_assign.append(f"        b{r}{c} = {sv_num(int(B[r, c]))};")

    for r in range(4):
        for c in range(4):
            checks.append(f"            c{r}{c} == {expected_num(int(C[r, c]))}")

    check_expr = " &&\n".join(checks)

    tb = f"""`timescale 1ns/1ps

module tsa_systolic_4x4_random_tb;

    reg clk;
    reg reset;
    reg start;

    reg signed [7:0] a00, a01, a02, a03;
    reg signed [7:0] a10, a11, a12, a13;
    reg signed [7:0] a20, a21, a22, a23;
    reg signed [7:0] a30, a31, a32, a33;

    reg signed [7:0] b00, b01, b02, b03;
    reg signed [7:0] b10, b11, b12, b13;
    reg signed [7:0] b20, b21, b22, b23;
    reg signed [7:0] b30, b31, b32, b33;

    wire signed [31:0] c00, c01, c02, c03;
    wire signed [31:0] c10, c11, c12, c13;
    wire signed [31:0] c20, c21, c22, c23;
    wire signed [31:0] c30, c31, c32, c33;

    wire busy;
    wire done;
    wire valid;

    tsa_systolic_4x4_core_i8 dut (
        .clk(clk),
        .reset(reset),
        .start(start),

        .a00(a00), .a01(a01), .a02(a02), .a03(a03),
        .a10(a10), .a11(a11), .a12(a12), .a13(a13),
        .a20(a20), .a21(a21), .a22(a22), .a23(a23),
        .a30(a30), .a31(a31), .a32(a32), .a33(a33),

        .b00(b00), .b01(b01), .b02(b02), .b03(b03),
        .b10(b10), .b11(b11), .b12(b12), .b13(b13),
        .b20(b20), .b21(b21), .b22(b22), .b23(b23),
        .b30(b30), .b31(b31), .b32(b32), .b33(b33),

        .c00(c00), .c01(c01), .c02(c02), .c03(c03),
        .c10(c10), .c11(c11), .c12(c12), .c13(c13),
        .c20(c20), .c21(c21), .c22(c22), .c23(c23),
        .c30(c30), .c31(c31), .c32(c32), .c33(c33),

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

        a00 = 0; a01 = 0; a02 = 0; a03 = 0;
        a10 = 0; a11 = 0; a12 = 0; a13 = 0;
        a20 = 0; a21 = 0; a22 = 0; a23 = 0;
        a30 = 0; a31 = 0; a32 = 0; a33 = 0;

        b00 = 0; b01 = 0; b02 = 0; b03 = 0;
        b10 = 0; b11 = 0; b12 = 0; b13 = 0;
        b20 = 0; b21 = 0; b22 = 0; b23 = 0;
        b30 = 0; b31 = 0; b32 = 0; b33 = 0;

        #10;
        reset = 0;

{chr(10).join(a_assign)}

{chr(10).join(b_assign)}

        #10;
        start = 1;
        #10;
        start = 0;

        wait(valid == 1'b1);
        #1;

        if (
{check_expr} &&
            valid == 1'b1
        ) begin
            $display("RANDOM TEST {test_id}: PASS");
        end else begin
            $display("RANDOM TEST {test_id}: FAIL");

            $display("Output:");
            $display("%d %d %d %d", c00, c01, c02, c03);
            $display("%d %d %d %d", c10, c11, c12, c13);
            $display("%d %d %d %d", c20, c21, c22, c23);
            $display("%d %d %d %d", c30, c31, c32, c33);

            $display("Expected:");
            $display("{int(C[0,0])} {int(C[0,1])} {int(C[0,2])} {int(C[0,3])}");
            $display("{int(C[1,0])} {int(C[1,1])} {int(C[1,2])} {int(C[1,3])}");
            $display("{int(C[2,0])} {int(C[2,1])} {int(C[2,2])} {int(C[2,3])}");
            $display("{int(C[3,0])} {int(C[3,1])} {int(C[3,2])} {int(C[3,3])}");
        end

        #20;
        $finish;
    end

endmodule
"""
    TB_PATH.write_text(tb)

def run_one(test_id: int) -> bool:
    A = RNG.integers(-8, 9, size=(4, 4), dtype=np.int32)
    B = RNG.integers(-8, 9, size=(4, 4), dtype=np.int32)
    C = A @ B

    generate_tb(A, B, C, test_id)

    compile_cmd = [
        "iverilog", "-g2012",
        "-o", str(SIM_PATH),
        str(ROOT / "rtl" / "tsa_pe_i8.v"),
        str(ROOT / "rtl" / "tsa_systolic_4x4_i8.sv"),
        str(ROOT / "rtl" / "tsa_systolic_4x4_core_i8.sv"),
        str(TB_PATH),
    ]

    subprocess.run(compile_cmd, check=True, cwd=ROOT)

    result = subprocess.run(
        ["vvp", str(SIM_PATH)],
        check=True,
        cwd=ROOT,
        capture_output=True,
        text=True,
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
        ok = run_one(i)
        if ok:
            passed += 1
            print(f"[{i+1:03d}/{TESTS}] PASS")
        else:
            print(f"[{i+1:03d}/{TESTS}] FAIL")
            break

    print()
    print("TSA-1 4x4 random verification")
    print(f"Passed: {passed}/{TESTS}")

    if passed == TESTS:
        print("RESULT: ALL TESTS PASSED")
    else:
        print("RESULT: FAILED")

if __name__ == "__main__":
    main()
