module tsa_fpga_top_mmio_i8 (
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

    wire core_busy;
    wire core_done;
    wire core_valid;

    reg start_pulse;
    reg done_latched;

    assign irq_valid = core_valid;

    tsa_systolic_4x4_core_i8 core (
        .clk(clk),
        .reset(reset),
        .start(start_pulse),

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

            start_pulse <= 1'b0;
            done_latched <= 1'b0;

            a00 <= 0; a01 <= 0; a02 <= 0; a03 <= 0;
            a10 <= 0; a11 <= 0; a12 <= 0; a13 <= 0;
            a20 <= 0; a21 <= 0; a22 <= 0; a23 <= 0;
            a30 <= 0; a31 <= 0; a32 <= 0; a33 <= 0;

            b00 <= 0; b01 <= 0; b02 <= 0; b03 <= 0;
            b10 <= 0; b11 <= 0; b12 <= 0; b13 <= 0;
            b20 <= 0; b21 <= 0; b22 <= 0; b23 <= 0;
            b30 <= 0; b31 <= 0; b32 <= 0; b33 <= 0;
        end else begin
            bus_ready <= bus_valid;
            start_pulse <= 1'b0;

            if (core_done) begin
                done_latched <= 1'b1;
            end

            if (bus_valid && bus_we) begin
                case (bus_addr)

                    ADDR_CTRL: begin
                        if (bus_wdata[0] && !core_busy) begin
                            start_pulse <= 1'b1;
                            done_latched <= 1'b0;
                        end

                        if (bus_wdata[1]) begin
                            done_latched <= 1'b0;
                        end
                    end

                    8'h10: a00 <= bus_wdata[7:0];
                    8'h11: a01 <= bus_wdata[7:0];
                    8'h12: a02 <= bus_wdata[7:0];
                    8'h13: a03 <= bus_wdata[7:0];

                    8'h14: a10 <= bus_wdata[7:0];
                    8'h15: a11 <= bus_wdata[7:0];
                    8'h16: a12 <= bus_wdata[7:0];
                    8'h17: a13 <= bus_wdata[7:0];

                    8'h18: a20 <= bus_wdata[7:0];
                    8'h19: a21 <= bus_wdata[7:0];
                    8'h1A: a22 <= bus_wdata[7:0];
                    8'h1B: a23 <= bus_wdata[7:0];

                    8'h1C: a30 <= bus_wdata[7:0];
                    8'h1D: a31 <= bus_wdata[7:0];
                    8'h1E: a32 <= bus_wdata[7:0];
                    8'h1F: a33 <= bus_wdata[7:0];

                    8'h20: b00 <= bus_wdata[7:0];
                    8'h21: b01 <= bus_wdata[7:0];
                    8'h22: b02 <= bus_wdata[7:0];
                    8'h23: b03 <= bus_wdata[7:0];

                    8'h24: b10 <= bus_wdata[7:0];
                    8'h25: b11 <= bus_wdata[7:0];
                    8'h26: b12 <= bus_wdata[7:0];
                    8'h27: b13 <= bus_wdata[7:0];

                    8'h28: b20 <= bus_wdata[7:0];
                    8'h29: b21 <= bus_wdata[7:0];
                    8'h2A: b22 <= bus_wdata[7:0];
                    8'h2B: b23 <= bus_wdata[7:0];

                    8'h2C: b30 <= bus_wdata[7:0];
                    8'h2D: b31 <= bus_wdata[7:0];
                    8'h2E: b32 <= bus_wdata[7:0];
                    8'h2F: b33 <= bus_wdata[7:0];

                    default: begin
                    end

                endcase
            end

            if (bus_valid && !bus_we) begin
                case (bus_addr)

                    ADDR_CTRL: begin
                        bus_rdata <= 32'd0;
                    end

                    ADDR_STATUS: begin
                        bus_rdata <= {
                            28'd0,
                            irq_valid,
                            core_valid,
                            done_latched,
                            core_busy
                        };
                    end

                    8'h10: bus_rdata <= sign_extend_i8(a00);
                    8'h11: bus_rdata <= sign_extend_i8(a01);
                    8'h12: bus_rdata <= sign_extend_i8(a02);
                    8'h13: bus_rdata <= sign_extend_i8(a03);

                    8'h14: bus_rdata <= sign_extend_i8(a10);
                    8'h15: bus_rdata <= sign_extend_i8(a11);
                    8'h16: bus_rdata <= sign_extend_i8(a12);
                    8'h17: bus_rdata <= sign_extend_i8(a13);

                    8'h18: bus_rdata <= sign_extend_i8(a20);
                    8'h19: bus_rdata <= sign_extend_i8(a21);
                    8'h1A: bus_rdata <= sign_extend_i8(a22);
                    8'h1B: bus_rdata <= sign_extend_i8(a23);

                    8'h1C: bus_rdata <= sign_extend_i8(a30);
                    8'h1D: bus_rdata <= sign_extend_i8(a31);
                    8'h1E: bus_rdata <= sign_extend_i8(a32);
                    8'h1F: bus_rdata <= sign_extend_i8(a33);

                    8'h20: bus_rdata <= sign_extend_i8(b00);
                    8'h21: bus_rdata <= sign_extend_i8(b01);
                    8'h22: bus_rdata <= sign_extend_i8(b02);
                    8'h23: bus_rdata <= sign_extend_i8(b03);

                    8'h24: bus_rdata <= sign_extend_i8(b10);
                    8'h25: bus_rdata <= sign_extend_i8(b11);
                    8'h26: bus_rdata <= sign_extend_i8(b12);
                    8'h27: bus_rdata <= sign_extend_i8(b13);

                    8'h28: bus_rdata <= sign_extend_i8(b20);
                    8'h29: bus_rdata <= sign_extend_i8(b21);
                    8'h2A: bus_rdata <= sign_extend_i8(b22);
                    8'h2B: bus_rdata <= sign_extend_i8(b23);

                    8'h2C: bus_rdata <= sign_extend_i8(b30);
                    8'h2D: bus_rdata <= sign_extend_i8(b31);
                    8'h2E: bus_rdata <= sign_extend_i8(b32);
                    8'h2F: bus_rdata <= sign_extend_i8(b33);

                    8'h30: bus_rdata <= c00;
                    8'h31: bus_rdata <= c01;
                    8'h32: bus_rdata <= c02;
                    8'h33: bus_rdata <= c03;

                    8'h34: bus_rdata <= c10;
                    8'h35: bus_rdata <= c11;
                    8'h36: bus_rdata <= c12;
                    8'h37: bus_rdata <= c13;

                    8'h38: bus_rdata <= c20;
                    8'h39: bus_rdata <= c21;
                    8'h3A: bus_rdata <= c22;
                    8'h3B: bus_rdata <= c23;

                    8'h3C: bus_rdata <= c30;
                    8'h3D: bus_rdata <= c31;
                    8'h3E: bus_rdata <= c32;
                    8'h3F: bus_rdata <= c33;

                    default: begin
                        bus_rdata <= 32'hDEAD_BEEF;
                    end

                endcase
            end
        end
    end

endmodule
