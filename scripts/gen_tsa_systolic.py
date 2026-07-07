from pathlib import Path
import numpy as np

ROOT = Path.home() / "tsa-ai-chip"
RTL = ROOT / "rtl"
TB = ROOT / "tb"

N = 8
CORE_NAME = f"tsa_systolic_{N}x{N}_core_i8"
ARRAY_NAME = f"tsa_systolic_{N}x{N}_i8"
TB_NAME = f"{CORE_NAME}_tb"

RTL.mkdir(exist_ok=True)
TB.mkdir(exist_ok=True)

def port_matrix(prefix):
    lines = []
    for r in range(N):
        row = []
        for c in range(N):
            comma = "," if not (prefix == "b" and r == N-1 and c == N-1) else ","
            row.append(f"    input  wire signed [7:0]       {prefix}{r}{c}{comma}")
        lines.extend(row)
    return "\n".join(lines)

def output_matrix():
    lines = []
    for r in range(N):
        for c in range(N):
            comma = "," if not (r == N-1 and c == N-1) else ","
            lines.append(f"    output wire signed [31:0]      c{r}{c}{comma}")
    return "\n".join(lines)

def core_ports_call(prefix):
    lines = []
    for r in range(N):
        for c in range(N):
            lines.append(f"        .{prefix}{r}{c}({prefix}{r}{c}),")
    return "\n".join(lines)

def c_ports_call():
    lines = []
    for r in range(N):
        for c in range(N):
            lines.append(f"        .c{r}{c}(c{r}{c}),")
    return "\n".join(lines)

def generate_array():
    path = RTL / f"{ARRAY_NAME}.sv"

    c_outputs = []
    for r in range(N):
        for c in range(N):
            comma = "," if not (r == N-1 and c == N-1) else ""
            c_outputs.append(f"    output wire signed [31:0]      c{r}{c}{comma}")

    assigns_c = []
    for r in range(N):
        for c in range(N):
            assigns_c.append(f"    assign c{r}{c} = acc[{r}][{c}];")

    text = f"""module {ARRAY_NAME} (
    input  wire                    clk,
    input  wire                    reset,
    input  wire                    enable,
    input  wire                    clear,

"""

    for i in range(N):
        text += f"    input  wire signed [7:0]       a{i}_in,\n"
    text += "\n"
    for j in range(N):
        comma = "," 
        text += f"    input  wire signed [7:0]       b{j}_in,\n"
    text += "\n"
    text += "\n".join(c_outputs)
    text += "\n);\n\n"

    text += f"""    wire signed [7:0]  a_link [0:{N-1}][0:{N}];
    wire signed [7:0]  b_link [0:{N}][0:{N-1}];
    wire signed [31:0] acc    [0:{N-1}][0:{N-1}];

"""

    for i in range(N):
        text += f"    assign a_link[{i}][0] = a{i}_in;\n"
    text += "\n"
    for j in range(N):
        text += f"    assign b_link[0][{j}] = b{j}_in;\n"

    text += f"""

    genvar r;
    genvar col;

    generate
        for (r = 0; r < {N}; r = r + 1) begin : ROWS
            for (col = 0; col < {N}; col = col + 1) begin : COLS
                tsa_pe_i8 pe (
                    .clk(clk),
                    .reset(reset),
                    .enable(enable),
                    .clear(clear),

                    .a_in(a_link[r][col]),
                    .b_in(b_link[r][col]),

                    .a_out(a_link[r][col + 1]),
                    .b_out(b_link[r + 1][col]),

                    .acc(acc[r][col])
                );
            end
        end
    endgenerate

"""
    text += "\n".join(assigns_c)
    text += "\n\nendmodule\n"
    path.write_text(text)

def generate_core():
    path = RTL / f"{CORE_NAME}.sv"

    text = f"""module {CORE_NAME} (
    input  wire                    clk,
    input  wire                    reset,
    input  wire                    start,

"""
    for r in range(N):
        for c in range(N):
            text += f"    input  wire signed [7:0]       a{r}{c},\n"

    text += "\n"

    for r in range(N):
        for c in range(N):
            text += f"    input  wire signed [7:0]       b{r}{c},\n"

    text += "\n"

    for r in range(N):
        for c in range(N):
            text += f"    output wire signed [31:0]      c{r}{c},\n"

    text += """
    output reg                     busy,
    output reg                     done,
    output reg                     valid
);

"""

    text += f"""    reg enable;
    reg clear;

    reg [5:0] cycle;
    reg [2:0] state;

    reg signed [7:0] A [0:{N-1}][0:{N-1}];
    reg signed [7:0] B [0:{N-1}][0:{N-1}];

    reg signed [7:0] a_feed [0:{N-1}];
    reg signed [7:0] b_feed [0:{N-1}];

    integer i;
    integer j;
    integer k;

    localparam IDLE  = 3'd0;
    localparam CLEAR = 3'd1;
    localparam RUN   = 3'd2;
    localparam DONE  = 3'd3;

"""

    text += "    always @(*) begin\n"
    for r in range(N):
        for c in range(N):
            text += f"        A[{r}][{c}] = a{r}{c};\n"
    text += "\n"
    for r in range(N):
        for c in range(N):
            text += f"        B[{r}][{c}] = b{r}{c};\n"

    text += f"""
        for (i = 0; i < {N}; i = i + 1) begin
            a_feed[i] = 8'sd0;
            b_feed[i] = 8'sd0;
        end

        for (i = 0; i < {N}; i = i + 1) begin
            k = cycle - i;
            if (k >= 0 && k < {N}) begin
                a_feed[i] = A[i][k];
            end
        end

        for (j = 0; j < {N}; j = j + 1) begin
            k = cycle - j;
            if (k >= 0 && k < {N}) begin
                b_feed[j] = B[k][j];
            end
        end
    end

    {ARRAY_NAME} array (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .clear(clear),

"""

    for i in range(N):
        text += f"        .a{i}_in(a_feed[{i}]),\n"
    text += "\n"
    for j in range(N):
        text += f"        .b{j}_in(b_feed[{j}]),\n"
    text += "\n"
    for r in range(N):
        for c in range(N):
            comma = "," if not (r == N-1 and c == N-1) else ""
            text += f"        .c{r}{c}(c{r}{c}){comma}\n"

    text += f"""    );

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state  <= IDLE;
            cycle  <= 6'd0;

            enable <= 1'b0;
            clear  <= 1'b0;

            busy   <= 1'b0;
            done   <= 1'b0;
            valid  <= 1'b0;
        end else begin
            case (state)

                IDLE: begin
                    enable <= 1'b0;
                    clear  <= 1'b0;
                    busy   <= 1'b0;
                    done   <= 1'b0;

                    if (start) begin
                        valid  <= 1'b0;
                        busy   <= 1'b1;
                        clear  <= 1'b1;
                        cycle  <= 6'd0;
                        state  <= CLEAR;
                    end
                end

                CLEAR: begin
                    clear  <= 1'b0;
                    enable <= 1'b1;
                    busy   <= 1'b1;
                    done   <= 1'b0;
                    valid  <= 1'b0;
                    cycle  <= 6'd0;
                    state  <= RUN;
                end

                RUN: begin
                    enable <= 1'b1;
                    clear  <= 1'b0;
                    busy   <= 1'b1;
                    done   <= 1'b0;
                    valid  <= 1'b0;

                    if (cycle == 6'd{3*N-3}) begin
                        state <= DONE;
                    end else begin
                        cycle <= cycle + 6'd1;
                    end
                end

                DONE: begin
                    enable <= 1'b0;
                    clear  <= 1'b0;
                    busy   <= 1'b0;
                    done   <= 1'b1;
                    valid  <= 1'b1;
                    state  <= IDLE;
                end

                default: begin
                    state  <= IDLE;
                    cycle  <= 6'd0;
                    enable <= 1'b0;
                    clear  <= 1'b0;
                    busy   <= 1'b0;
                    done   <= 1'b0;
                    valid  <= 1'b0;
                end

            endcase
        end
    end

endmodule
"""
    path.write_text(text)

def generate_tb():
    path = TB / f"{CORE_NAME}_tb.sv"

    rng = np.random.default_rng(777)
    A = rng.integers(-8, 9, size=(N, N), dtype=np.int32)
    B = rng.integers(-8, 9, size=(N, N), dtype=np.int32)
    C = A @ B

    text = f"""`timescale 1ns/1ps

module {TB_NAME};

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

"""

    text += f"    {CORE_NAME} dut (\n"
    text += "        .clk(clk),\n        .reset(reset),\n        .start(start),\n\n"

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
        $dumpfile("waves/tsa_systolic_8x8_core_i8.vcd");
        $dumpvars(0, tsa_systolic_8x8_core_i8_tb);

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

        $display("TSA-2 SYSTOLIC 8x8 INT8 CORE test started");

"""

    for r in range(N):
        for c in range(N):
            val = int(A[r, c])
            if val < 0:
                text += f"        a{r}{c} = -8'sd{abs(val)};\n"
            else:
                text += f"        a{r}{c} = 8'sd{val};\n"

    text += "\n"

    for r in range(N):
        for c in range(N):
            val = int(B[r, c])
            if val < 0:
                text += f"        b{r}{c} = -8'sd{abs(val)};\n"
            else:
                text += f"        b{r}{c} = 8'sd{val};\n"

    text += """
        #10;
        start = 1;
        #10;
        start = 0;

        wait(valid == 1'b1);
        #1;

        $display("Output C:");
"""

    for r in range(N):
        row = ", ".join([f"c{r}{c}" for c in range(N)])
        fmt = " ".join(["%d"] * N)
        text += f'        $display("{fmt}", {row});\n'

    text += """
        $display("Expected:");
"""

    for r in range(N):
        row = " ".join(str(int(C[r, c])) for c in range(N))
        text += f'        $display("{row}");\n'

    checks = []
    for r in range(N):
        for c in range(N):
            val = int(C[r, c])
            if val < 0:
                checks.append(f"c{r}{c} == -32'sd{abs(val)}")
            else:
                checks.append(f"c{r}{c} == 32'sd{val}")

    text += "\n        if (\n            "
    text += " &&\n            ".join(checks)
    text += """
        ) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end

        #20;
        $finish;
    end

endmodule
"""
    path.write_text(text)

    np.save(ROOT / "reports" / "tsa_8x8_A.npy", A)
    np.save(ROOT / "reports" / "tsa_8x8_B.npy", B)
    np.save(ROOT / "reports" / "tsa_8x8_C_expected.npy", C)

def main():
    generate_array()
    generate_core()
    generate_tb()
    print(f"Generated {ARRAY_NAME}, {CORE_NAME}, and testbench.")
    print(f"PE count: {N*N}")
    print(f"Run cycles: 0..{3*N-3}")

if __name__ == "__main__":
    main()
