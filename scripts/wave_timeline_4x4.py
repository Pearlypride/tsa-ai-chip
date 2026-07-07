from pathlib import Path
import pandas as pd
import matplotlib.pyplot as plt

CSV_PATH = Path("reports/tsa_4x4_timeline.csv")
OUT_PATH = Path("reports/tsa_4x4_timeline.png")

EXPECTED_FINAL = {
    "c00": 90,   "c01": 16,   "c02": -44,  "c03": 120,
    "c10": 16,   "c11": 228,  "c12": -170, "c13": 16,
    "c20": -36,  "c21": -76,  "c22": 110,  "c23": -48,
    "c30": 190,  "c31": -16,  "c32": -96,  "c33": 280,
}

OUTPUTS = [
    "c00", "c01", "c02", "c03",
    "c10", "c11", "c12", "c13",
    "c20", "c21", "c22", "c23",
    "c30", "c31", "c32", "c33",
]

def main():
    if not CSV_PATH.exists():
        raise SystemExit(f"CSV not found: {CSV_PATH}")

    OUT_PATH.parent.mkdir(exist_ok=True)

    df = pd.read_csv(CSV_PATH)

    final = df.iloc[-1]
    final_values = {name: int(final[name]) for name in OUTPUTS}
    passed = final_values == EXPECTED_FINAL

    fig = plt.figure(figsize=(16, 10))

    ax1 = fig.add_subplot(3, 1, 1)
    offsets = {
        "start": 0,
        "busy": 2,
        "done": 4,
        "valid": 6,
    }

    for name, offset in offsets.items():
        ax1.step(df["time_ps"], df[name] + offset, where="post", label=name)

    ax1.set_title("TSA-1 Control Timeline")
    ax1.set_ylabel("logic + offset")
    ax1.legend(loc="upper right")
    ax1.grid(True)

    ax2 = fig.add_subplot(3, 1, 2)
    ax2.step(df["time_ps"], df["cycle"], where="post")
    ax2.set_title("Controller cycle")
    ax2.set_ylabel("cycle")
    ax2.grid(True)

    ax3 = fig.add_subplot(3, 1, 3)

    for name in OUTPUTS:
        ax3.step(df["time_ps"], df[name], where="post", label=name)

    ax3.set_title("Output C matrix values over time")
    ax3.set_xlabel("time, ps")
    ax3.set_ylabel("INT32 value")
    ax3.grid(True)
    ax3.legend(ncol=8, fontsize=8, loc="upper left")

    fig.suptitle(
        f"TSA-1 4x4 INT8 Systolic Core Timeline — {'PASS' if passed else 'FAIL'}",
        fontsize=16
    )

    plt.tight_layout()
    plt.savefig(OUT_PATH, dpi=160)

    print("Saved timeline report:")
    print(OUT_PATH)

    print("Final values:")
    for r in range(4):
        row = []
        for c in range(4):
            row.append(str(final_values[f'c{r}{c}']).rjust(5))
        print(" ".join(row))

    print("Result:", "PASS" if passed else "FAIL")

if __name__ == "__main__":
    main()
