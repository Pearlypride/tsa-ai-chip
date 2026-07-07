import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path

A = np.array([
    [ 1, -2,  3,  4],
    [ 5,  6, -7,  8],
    [-1,  2,  3, -4],
    [ 9, -8,  7,  6],
], dtype=np.int32)

B = np.array([
    [ 1,   2,  -3,   4],
    [-5,   6,   7,  -8],
    [ 9, -10,  11,  12],
    [13,  14, -15,  16],
], dtype=np.int32)

C_expected = A @ B

# From current Verilog test output
C_hw = np.array([
    [ 90,  16,  -44, 120],
    [ 16, 228, -170,  16],
    [-36, -76,  110, -48],
    [190, -16,  -96, 280],
], dtype=np.int32)

passed = np.array_equal(C_hw, C_expected)

out_dir = Path("reports")
out_dir.mkdir(exist_ok=True)

def draw_matrix(ax, matrix, title):
    ax.imshow(matrix, aspect="equal")
    ax.set_title(title)
    ax.set_xticks(range(matrix.shape[1]))
    ax.set_yticks(range(matrix.shape[0]))

    for i in range(matrix.shape[0]):
        for j in range(matrix.shape[1]):
            ax.text(j, i, str(matrix[i, j]), ha="center", va="center")

    ax.set_xlabel("col")
    ax.set_ylabel("row")

fig = plt.figure(figsize=(14, 8))

ax1 = fig.add_subplot(2, 3, 1)
draw_matrix(ax1, A, "Input A INT8")

ax2 = fig.add_subplot(2, 3, 2)
draw_matrix(ax2, B, "Input B INT8")

ax3 = fig.add_subplot(2, 3, 3)
draw_matrix(ax3, C_expected, "Expected C = A x B")

ax4 = fig.add_subplot(2, 3, 4)
draw_matrix(ax4, C_hw, "TSA-1 Hardware Output")

diff = C_hw - C_expected
ax5 = fig.add_subplot(2, 3, 5)
draw_matrix(ax5, diff, "Difference HW - Expected")

ax6 = fig.add_subplot(2, 3, 6)
ax6.axis("off")

status = "PASS" if passed else "FAIL"
text = f"""
TSA-1 4x4 INT8 Systolic Core

Architecture:
- 4x4 systolic array
- 16 PE cells
- signed INT8 inputs
- signed INT32 accumulators
- start / busy / done / valid control

Result: {status}

Cycles:
- start pulse
- clear accumulators
- feed A/B diagonally
- cycle 0..9
- valid = 1 when C is ready
"""

ax6.text(0.02, 0.98, text, va="top", family="monospace", fontsize=11)

plt.tight_layout()
plt.savefig(out_dir / "tsa_4x4_report.png", dpi=160)

print("Saved visual report:")
print(out_dir / "tsa_4x4_report.png")
print("Result:", status)
