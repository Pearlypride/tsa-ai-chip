from pathlib import Path
import numpy as np

ROOT = Path.home() / "tsa-ai-chip"
RTL = ROOT / "rtl"
TB = ROOT / "tb"
REPORTS = ROOT / "reports"

N = 8
TOP = "tsa_axi_lite_top_8x8_i8"
CORE = "tsa_systolic_8x8_core_i8"
TBMOD = "tsa_axi_lite_top_8x8_i8_tb"

A_BASE = 0x100
B_BASE = 0x200
C_BASE = 0x300

def sv_i8(x):
    return f"-8'sd{abs(x)}" if x < 0 else f"8'sd{x}"

def sv_i32(x):
    return f"-32'sd{abs(x)}" if x < 0 else f"32'sd{x}"

def generate_top():
    path = RTL / f"{TOP}.sv"

    core_a_ports = []
    core_b_ports = []
    core_c_ports = []

    for r in range(N):
        for c in range(N):
            idx = r * N + c
            core_a_ports.append(f"        .a{r}{c}(mem_a[{idx}]),")
            core_b_ports.append(f"        .b{r}{c}(mem_b[{idx}]),")
            core_c_ports.append(f"        .c{r}{c}(c{r}{c}),")

    c_wires = []
    for r in range(N):
        for c in range(N):
            c_wires.append(f"    wire signed [31:0] c{r}{c};")

    mem_c_copy = []
    for r in range(N):
        for c in range(N):
            idx = r * N + c
            mem_c_copy.append(f"                mem_c[{idx}] <= c{r}{c};")

    text = f"""module {TOP} (
    input  wire                    ACLK,
    input  wire                    ARESETN,

    input  wire [31:0]             S_AXI_AWADDR,
    input  wire                    S_AXI_AWVALID,
    output reg                     S_AXI_AWREADY,

    input  wire [31:0]             S_AXI_WDATA,
    input  wire [3:0]              S_AXI_WSTRB,
    input  wire                    S_AXI_WVALID,
    output reg                     S_AXI_WREADY,

    output reg  [1:0]              S_AXI_BRESP,
    output reg                     S_AXI_BVALID,
    input  wire                    S_AXI_BREADY,

    input  wire [31:0]             S_AXI_ARADDR,
    input  wire                    S_AXI_ARVALID,
    output reg                     S_AXI_ARREADY,

    output reg  [31:0]             S_AXI_RDATA,
    output reg  [1:0]              S_AXI_RRESP,
    output reg                     S_AXI_RVALID,
    input  wire                    S_AXI_RREADY,

    output wire                    irq
);

    wire reset;
    assign reset = ~ARESETN;

    localparam [11:0] ADDR_CTRL   = 12'h000;
    localparam [11:0] ADDR_STATUS = 12'h004;

    localparam [11:0] ADDR_A_BASE = 12'h100;
    localparam [11:0] ADDR_B_BASE = 12'h200;
    localparam [11:0] ADDR_C_BASE = 12'h300;

    reg signed [7:0]  mem_a [0:{N*N-1}];
    reg signed [7:0]  mem_b [0:{N*N-1}];
    reg signed [31:0] mem_c [0:{N*N-1}];

{chr(10).join(c_wires)}

    wire core_busy;
    wire core_done;
    wire core_valid;

    reg start_pulse;
    reg done_latched;
    reg valid_latched;

    reg aw_pending;
    reg w_pending;

    reg [31:0] awaddr_buf;
    reg [31:0] wdata_buf;
    reg [3:0]  wstrb_buf;

    integer i;

    assign irq = done_latched;

    {CORE} core (
        .clk(ACLK),
        .reset(reset),
        .start(start_pulse),

{chr(10).join(core_a_ports)}

{chr(10).join(core_b_ports)}

{chr(10).join(core_c_ports)}

        .busy(core_busy),
        .done(core_done),
        .valid(core_valid)
    );

    function [31:0] sign_extend_i8;
        input signed [7:0] value;
        begin
            sign_extend_i8 = {{{{24{{value[7]}}}}, value}};
        end
    endfunction

    function is_a_addr;
        input [11:0] addr;
        begin
            is_a_addr = (addr >= ADDR_A_BASE && addr < ADDR_A_BASE + 12'd{N*N*4} && addr[1:0] == 2'b00);
        end
    endfunction

    function is_b_addr;
        input [11:0] addr;
        begin
            is_b_addr = (addr >= ADDR_B_BASE && addr < ADDR_B_BASE + 12'd{N*N*4} && addr[1:0] == 2'b00);
        end
    endfunction

    function is_c_addr;
        input [11:0] addr;
        begin
            is_c_addr = (addr >= ADDR_C_BASE && addr < ADDR_C_BASE + 12'd{N*N*4} && addr[1:0] == 2'b00);
        end
    endfunction

    task write_register;
        input [31:0] addr;
        input [31:0] data;
        reg [11:0] local_addr;
        integer idx;
        begin
            local_addr = addr[11:0];

            if (local_addr == ADDR_CTRL) begin
                // CTRL bit0: start
                if (data[0] && !core_busy) begin
                    start_pulse   <= 1'b1;
                    done_latched  <= 1'b0;
                    valid_latched <= 1'b0;
                end

                // CTRL bit1: W1C clear done/valid/irq
                if (data[1]) begin
                    done_latched  <= 1'b0;
                    valid_latched <= 1'b0;
                end
            end else if (is_a_addr(local_addr)) begin
                idx = (local_addr - ADDR_A_BASE) >> 2;
                mem_a[idx] <= data[7:0];
            end else if (is_b_addr(local_addr)) begin
                idx = (local_addr - ADDR_B_BASE) >> 2;
                mem_b[idx] <= data[7:0];
            end
        end
    endtask

    function [31:0] read_register;
        input [31:0] addr;
        reg [11:0] local_addr;
        integer idx;
        begin
            local_addr = addr[11:0];

            if (local_addr == ADDR_CTRL) begin
                read_register = 32'd0;
            end else if (local_addr == ADDR_STATUS) begin
                // bit0 = busy
                // bit1 = done_latched
                // bit2 = valid_latched
                // bit3 = irq
                read_register = {{
                    28'd0,
                    irq,
                    valid_latched,
                    done_latched,
                    core_busy
                }};
            end else if (is_a_addr(local_addr)) begin
                idx = (local_addr - ADDR_A_BASE) >> 2;
                read_register = sign_extend_i8(mem_a[idx]);
            end else if (is_b_addr(local_addr)) begin
                idx = (local_addr - ADDR_B_BASE) >> 2;
                read_register = sign_extend_i8(mem_b[idx]);
            end else if (is_c_addr(local_addr)) begin
                idx = (local_addr - ADDR_C_BASE) >> 2;
                read_register = mem_c[idx];
            end else begin
                read_register = 32'hDEAD_BEEF;
            end
        end
    endfunction

    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            S_AXI_AWREADY <= 1'b0;
            S_AXI_WREADY  <= 1'b0;
            S_AXI_BRESP   <= 2'b00;
            S_AXI_BVALID  <= 1'b0;

            S_AXI_ARREADY <= 1'b0;
            S_AXI_RDATA   <= 32'd0;
            S_AXI_RRESP   <= 2'b00;
            S_AXI_RVALID  <= 1'b0;

            aw_pending <= 1'b0;
            w_pending  <= 1'b0;

            awaddr_buf <= 32'd0;
            wdata_buf  <= 32'd0;
            wstrb_buf  <= 4'd0;

            start_pulse   <= 1'b0;
            done_latched  <= 1'b0;
            valid_latched <= 1'b0;

            for (i = 0; i < {N*N}; i = i + 1) begin
                mem_a[i] <= 8'sd0;
                mem_b[i] <= 8'sd0;
                mem_c[i] <= 32'sd0;
            end
        end else begin
            start_pulse <= 1'b0;

            if (core_done) begin
                done_latched  <= 1'b1;
                valid_latched <= 1'b1;

{chr(10).join(mem_c_copy)}
            end

            S_AXI_AWREADY <= (!aw_pending && !S_AXI_BVALID);
            S_AXI_WREADY  <= (!w_pending  && !S_AXI_BVALID);

            if (S_AXI_AWVALID && S_AXI_AWREADY) begin
                aw_pending <= 1'b1;
                awaddr_buf <= S_AXI_AWADDR;
            end

            if (S_AXI_WVALID && S_AXI_WREADY) begin
                w_pending <= 1'b1;
                wdata_buf <= S_AXI_WDATA;
                wstrb_buf <= S_AXI_WSTRB;
            end

            if (aw_pending && w_pending && !S_AXI_BVALID) begin
                write_register(awaddr_buf, wdata_buf);
                aw_pending <= 1'b0;
                w_pending  <= 1'b0;
                S_AXI_BVALID <= 1'b1;
                S_AXI_BRESP  <= 2'b00;
            end else if (S_AXI_BVALID && S_AXI_BREADY) begin
                S_AXI_BVALID <= 1'b0;
            end

            if (!S_AXI_RVALID) begin
                S_AXI_ARREADY <= 1'b1;
            end

            if (S_AXI_ARVALID && S_AXI_ARREADY) begin
                S_AXI_ARREADY <= 1'b0;
                S_AXI_RDATA   <= read_register(S_AXI_ARADDR);
                S_AXI_RRESP   <= 2'b00;
                S_AXI_RVALID  <= 1'b1;
            end

            if (S_AXI_RVALID && S_AXI_RREADY) begin
                S_AXI_RVALID <= 1'b0;
            end
        end
    end

endmodule
"""
    path.write_text(text)

def generate_tb():
    path = TB / f"{TBMOD}.sv"

    rng = np.random.default_rng(999)
    A = rng.integers(-8, 9, size=(N, N), dtype=np.int32)
    B = rng.integers(-8, 9, size=(N, N), dtype=np.int32)
    C = A @ B

    REPORTS.mkdir(exist_ok=True)
    np.save(REPORTS / "tsa_axi8_A.npy", A)
    np.save(REPORTS / "tsa_axi8_B.npy", B)
    np.save(REPORTS / "tsa_axi8_C_expected.npy", C)

    text = f"""`timescale 1ns/1ps

module {TBMOD};

    reg ACLK;
    reg ARESETN;

    reg  [31:0] S_AXI_AWADDR;
    reg         S_AXI_AWVALID;
    wire        S_AXI_AWREADY;

    reg  [31:0] S_AXI_WDATA;
    reg  [3:0]  S_AXI_WSTRB;
    reg         S_AXI_WVALID;
    wire        S_AXI_WREADY;

    wire [1:0]  S_AXI_BRESP;
    wire        S_AXI_BVALID;
    reg         S_AXI_BREADY;

    reg  [31:0] S_AXI_ARADDR;
    reg         S_AXI_ARVALID;
    wire        S_AXI_ARREADY;

    wire [31:0] S_AXI_RDATA;
    wire [1:0]  S_AXI_RRESP;
    wire        S_AXI_RVALID;
    reg         S_AXI_RREADY;

    wire irq;

    reg signed [31:0] rdata;
    reg signed [31:0] c [0:{N*N-1}];

    integer i;

    {TOP} dut (
        .ACLK(ACLK),
        .ARESETN(ARESETN),

        .S_AXI_AWADDR(S_AXI_AWADDR),
        .S_AXI_AWVALID(S_AXI_AWVALID),
        .S_AXI_AWREADY(S_AXI_AWREADY),

        .S_AXI_WDATA(S_AXI_WDATA),
        .S_AXI_WSTRB(S_AXI_WSTRB),
        .S_AXI_WVALID(S_AXI_WVALID),
        .S_AXI_WREADY(S_AXI_WREADY),

        .S_AXI_BRESP(S_AXI_BRESP),
        .S_AXI_BVALID(S_AXI_BVALID),
        .S_AXI_BREADY(S_AXI_BREADY),

        .S_AXI_ARADDR(S_AXI_ARADDR),
        .S_AXI_ARVALID(S_AXI_ARVALID),
        .S_AXI_ARREADY(S_AXI_ARREADY),

        .S_AXI_RDATA(S_AXI_RDATA),
        .S_AXI_RRESP(S_AXI_RRESP),
        .S_AXI_RVALID(S_AXI_RVALID),
        .S_AXI_RREADY(S_AXI_RREADY),

        .irq(irq)
    );

    always begin
        #5 ACLK = ~ACLK;
    end

    task axi_write;
        input [31:0] addr;
        input [31:0] data;
        begin
            @(posedge ACLK);

            S_AXI_AWADDR  <= addr;
            S_AXI_AWVALID <= 1'b1;

            S_AXI_WDATA   <= data;
            S_AXI_WSTRB   <= 4'hF;
            S_AXI_WVALID  <= 1'b1;

            S_AXI_BREADY  <= 1'b1;

            wait(S_AXI_AWREADY && S_AXI_WREADY);

            @(posedge ACLK);
            S_AXI_AWVALID <= 1'b0;
            S_AXI_WVALID  <= 1'b0;

            wait(S_AXI_BVALID);

            @(posedge ACLK);
            S_AXI_BREADY <= 1'b0;
        end
    endtask

    task axi_read;
        input  [31:0] addr;
        output signed [31:0] data;
        begin
            @(posedge ACLK);

            S_AXI_ARADDR  <= addr;
            S_AXI_ARVALID <= 1'b1;
            S_AXI_RREADY  <= 1'b1;

            wait(S_AXI_ARREADY);

            @(posedge ACLK);
            S_AXI_ARVALID <= 1'b0;

            wait(S_AXI_RVALID);

            #1;
            data = S_AXI_RDATA;

            @(posedge ACLK);
            S_AXI_RREADY <= 1'b0;
        end
    endtask

    initial begin
        $dumpfile("waves/tsa_axi_lite_top_8x8_i8.vcd");
        $dumpvars(0, {TBMOD});

        ACLK = 0;
        ARESETN = 0;

        S_AXI_AWADDR = 0;
        S_AXI_AWVALID = 0;
        S_AXI_WDATA = 0;
        S_AXI_WSTRB = 4'hF;
        S_AXI_WVALID = 0;
        S_AXI_BREADY = 0;

        S_AXI_ARADDR = 0;
        S_AXI_ARVALID = 0;
        S_AXI_RREADY = 0;

        #50;
        ARESETN = 1;

        $display("TSA-2 AXI-LITE 8x8 TOP test started");

"""

    for idx in range(N*N):
        r = idx // N
        c = idx % N
        addr = A_BASE + idx * 4
        val = int(A[r, c])
        text += f"        axi_write(32'h{addr:03X}, {sv_i32(val)});\n"

    text += "\n"

    for idx in range(N*N):
        r = idx // N
        c = idx % N
        addr = B_BASE + idx * 4
        val = int(B[r, c])
        text += f"        axi_write(32'h{addr:03X}, {sv_i32(val)});\n"

    text += """
        axi_write(32'h000, 32'd1);

        rdata = 0;
        while (rdata[1] == 1'b0) begin
            axi_read(32'h004, rdata);
        end

        $display("STATUS = %b", rdata[3:0]);

"""

    for idx in range(N*N):
        addr = C_BASE + idx * 4
        text += f"        axi_read(32'h{addr:03X}, c[{idx}]);\n"

    text += """
        $display("Read C through AXI-Lite 8x8:");
"""

    for r in range(N):
        fmt = " ".join(["%d"] * N)
        args = ", ".join([f"c[{r*N+c}]" for c in range(N)])
        text += f'        $display("{fmt}", {args});\n'

    text += """
        $display("Expected:");
"""

    for r in range(N):
        row = " ".join(str(int(C[r, c])) for c in range(N))
        text += f'        $display("{row}");\n'

    checks = []
    for idx in range(N*N):
        r = idx // N
        c = idx % N
        checks.append(f"c[{idx}] == {sv_i32(int(C[r, c]))}")

    text += "\n        if (\n            "
    text += " &&\n            ".join(checks)
    text += """
            && rdata[1] == 1'b1
            && irq == 1'b1
        ) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end

        axi_write(32'h000, 32'd2);
        axi_read(32'h004, rdata);
        $display("STATUS after clear = %b", rdata[3:0]);

        #50;
        $finish;
    end

endmodule
"""
    path.write_text(text)

def main():
    generate_top()
    generate_tb()
    print("Generated TSA-2 AXI-Lite 8x8 top and testbench.")
    print("AXI map:")
    print("  CTRL   0x000")
    print("  STATUS 0x004")
    print("  A      0x100..0x1FC")
    print("  B      0x200..0x2FC")
    print("  C      0x300..0x3FC")
    print("PE count: 64")

if __name__ == "__main__":
    main()
