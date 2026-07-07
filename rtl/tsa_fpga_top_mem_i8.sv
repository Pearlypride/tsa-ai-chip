module tsa_fpga_top_mem_i8 (
    input  wire                    clk,
    input  wire                    reset,

    input  wire                    bus_valid,
    input  wire                    bus_we,
    input  wire [7:0]              bus_addr,
    input  wire [31:0]             bus_wdata,

    output reg  [31:0]             bus_rdata,
    output reg                     bus_ready,

    output wire                    irq_valid
);

    localparam ADDR_CTRL   = 8'h00;
    localparam ADDR_STATUS = 8'h01;

    localparam ADDR_A_BASE = 8'h10;
    localparam ADDR_B_BASE = 8'h20;
    localparam ADDR_C_BASE = 8'h30;

    reg signed [7:0]  mem_a [0:15];
    reg signed [7:0]  mem_b [0:15];
    reg signed [31:0] mem_c [0:15];

    wire signed [31:0] c00, c01, c02, c03;
    wire signed [31:0] c10, c11, c12, c13;
    wire signed [31:0] c20, c21, c22, c23;
    wire signed [31:0] c30, c31, c32, c33;

    wire core_busy;
    wire core_done;
    wire core_valid;

    reg start_pulse;
    reg done_latched;
    reg valid_latched;

    integer i;

    assign irq_valid = done_latched;

    tsa_systolic_4x4_core_i8 core (
        .clk(clk),
        .reset(reset),
        .start(start_pulse),

        .a00(mem_a[0]),  .a01(mem_a[1]),  .a02(mem_a[2]),  .a03(mem_a[3]),
        .a10(mem_a[4]),  .a11(mem_a[5]),  .a12(mem_a[6]),  .a13(mem_a[7]),
        .a20(mem_a[8]),  .a21(mem_a[9]),  .a22(mem_a[10]), .a23(mem_a[11]),
        .a30(mem_a[12]), .a31(mem_a[13]), .a32(mem_a[14]), .a33(mem_a[15]),

        .b00(mem_b[0]),  .b01(mem_b[1]),  .b02(mem_b[2]),  .b03(mem_b[3]),
        .b10(mem_b[4]),  .b11(mem_b[5]),  .b12(mem_b[6]),  .b13(mem_b[7]),
        .b20(mem_b[8]),  .b21(mem_b[9]),  .b22(mem_b[10]), .b23(mem_b[11]),
        .b30(mem_b[12]), .b31(mem_b[13]), .b32(mem_b[14]), .b33(mem_b[15]),

        .c00(c00), .c01(c01), .c02(c02), .c03(c03),
        .c10(c10), .c11(c11), .c12(c12), .c13(c13),
        .c20(c20), .c21(c21), .c22(c22), .c23(c23),
        .c30(c30), .c31(c31), .c32(c32), .c33(c33),

        .busy(core_busy),
        .done(core_done),
        .valid(core_valid)
    );

    function [31:0] sign_extend_i8;
        input signed [7:0] value;
        begin
            sign_extend_i8 = {{24{value[7]}}, value};
        end
    endfunction

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            bus_rdata <= 32'd0;
            bus_ready <= 1'b0;

            start_pulse   <= 1'b0;
            done_latched  <= 1'b0;
            valid_latched <= 1'b0;

            for (i = 0; i < 16; i = i + 1) begin
                mem_a[i] <= 8'sd0;
                mem_b[i] <= 8'sd0;
                mem_c[i] <= 32'sd0;
            end
        end else begin
            bus_ready <= bus_valid;
            start_pulse <= 1'b0;

            if (core_valid) begin
                done_latched  <= 1'b1;
                valid_latched <= 1'b1;

                mem_c[0]  <= c00;
                mem_c[1]  <= c01;
                mem_c[2]  <= c02;
                mem_c[3]  <= c03;

                mem_c[4]  <= c10;
                mem_c[5]  <= c11;
                mem_c[6]  <= c12;
                mem_c[7]  <= c13;

                mem_c[8]  <= c20;
                mem_c[9]  <= c21;
                mem_c[10] <= c22;
                mem_c[11] <= c23;

                mem_c[12] <= c30;
                mem_c[13] <= c31;
                mem_c[14] <= c32;
                mem_c[15] <= c33;
            end

            if (bus_valid && bus_we) begin
                if (bus_addr == ADDR_CTRL) begin
                    // CTRL bit0: start
                    if (bus_wdata[0] && !core_busy) begin
                        start_pulse   <= 1'b1;
                        done_latched  <= 1'b0;
                        valid_latched <= 1'b0;
                    end

                    // CTRL bit1: W1C clear done/valid
                    if (bus_wdata[1]) begin
                        done_latched  <= 1'b0;
                        valid_latched <= 1'b0;
                    end
                end else if (bus_addr >= ADDR_A_BASE && bus_addr < ADDR_A_BASE + 8'd16) begin
                    mem_a[bus_addr[3:0]] <= bus_wdata[7:0];
                end else if (bus_addr >= ADDR_B_BASE && bus_addr < ADDR_B_BASE + 8'd16) begin
                    mem_b[bus_addr[3:0]] <= bus_wdata[7:0];
                end
            end

            if (bus_valid && !bus_we) begin
                if (bus_addr == ADDR_CTRL) begin
                    bus_rdata <= 32'd0;
                end else if (bus_addr == ADDR_STATUS) begin
                    // bit0 = busy
                    // bit1 = done_latched
                    // bit2 = valid_latched
                    // bit3 = irq
                    bus_rdata <= {
                        28'd0,
                        irq_valid,
                        valid_latched,
                        done_latched,
                        core_busy
                    };
                end else if (bus_addr >= ADDR_A_BASE && bus_addr < ADDR_A_BASE + 8'd16) begin
                    bus_rdata <= sign_extend_i8(mem_a[bus_addr[3:0]]);
                end else if (bus_addr >= ADDR_B_BASE && bus_addr < ADDR_B_BASE + 8'd16) begin
                    bus_rdata <= sign_extend_i8(mem_b[bus_addr[3:0]]);
                end else if (bus_addr >= ADDR_C_BASE && bus_addr < ADDR_C_BASE + 8'd16) begin
                    bus_rdata <= mem_c[bus_addr[3:0]];
                end else begin
                    bus_rdata <= 32'hDEAD_BEEF;
                end
            end
        end
    end

endmodule
