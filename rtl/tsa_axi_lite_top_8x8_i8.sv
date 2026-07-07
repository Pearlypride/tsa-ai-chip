module tsa_axi_lite_top_8x8_i8 (
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

    reg signed [7:0]  mem_a [0:63];
    reg signed [7:0]  mem_b [0:63];
    reg signed [31:0] mem_c [0:63];

    wire signed [31:0] c00;
    wire signed [31:0] c01;
    wire signed [31:0] c02;
    wire signed [31:0] c03;
    wire signed [31:0] c04;
    wire signed [31:0] c05;
    wire signed [31:0] c06;
    wire signed [31:0] c07;
    wire signed [31:0] c10;
    wire signed [31:0] c11;
    wire signed [31:0] c12;
    wire signed [31:0] c13;
    wire signed [31:0] c14;
    wire signed [31:0] c15;
    wire signed [31:0] c16;
    wire signed [31:0] c17;
    wire signed [31:0] c20;
    wire signed [31:0] c21;
    wire signed [31:0] c22;
    wire signed [31:0] c23;
    wire signed [31:0] c24;
    wire signed [31:0] c25;
    wire signed [31:0] c26;
    wire signed [31:0] c27;
    wire signed [31:0] c30;
    wire signed [31:0] c31;
    wire signed [31:0] c32;
    wire signed [31:0] c33;
    wire signed [31:0] c34;
    wire signed [31:0] c35;
    wire signed [31:0] c36;
    wire signed [31:0] c37;
    wire signed [31:0] c40;
    wire signed [31:0] c41;
    wire signed [31:0] c42;
    wire signed [31:0] c43;
    wire signed [31:0] c44;
    wire signed [31:0] c45;
    wire signed [31:0] c46;
    wire signed [31:0] c47;
    wire signed [31:0] c50;
    wire signed [31:0] c51;
    wire signed [31:0] c52;
    wire signed [31:0] c53;
    wire signed [31:0] c54;
    wire signed [31:0] c55;
    wire signed [31:0] c56;
    wire signed [31:0] c57;
    wire signed [31:0] c60;
    wire signed [31:0] c61;
    wire signed [31:0] c62;
    wire signed [31:0] c63;
    wire signed [31:0] c64;
    wire signed [31:0] c65;
    wire signed [31:0] c66;
    wire signed [31:0] c67;
    wire signed [31:0] c70;
    wire signed [31:0] c71;
    wire signed [31:0] c72;
    wire signed [31:0] c73;
    wire signed [31:0] c74;
    wire signed [31:0] c75;
    wire signed [31:0] c76;
    wire signed [31:0] c77;

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

    tsa_systolic_8x8_core_i8 core (
        .clk(ACLK),
        .reset(reset),
        .start(start_pulse),

        .a00(mem_a[0]),
        .a01(mem_a[1]),
        .a02(mem_a[2]),
        .a03(mem_a[3]),
        .a04(mem_a[4]),
        .a05(mem_a[5]),
        .a06(mem_a[6]),
        .a07(mem_a[7]),
        .a10(mem_a[8]),
        .a11(mem_a[9]),
        .a12(mem_a[10]),
        .a13(mem_a[11]),
        .a14(mem_a[12]),
        .a15(mem_a[13]),
        .a16(mem_a[14]),
        .a17(mem_a[15]),
        .a20(mem_a[16]),
        .a21(mem_a[17]),
        .a22(mem_a[18]),
        .a23(mem_a[19]),
        .a24(mem_a[20]),
        .a25(mem_a[21]),
        .a26(mem_a[22]),
        .a27(mem_a[23]),
        .a30(mem_a[24]),
        .a31(mem_a[25]),
        .a32(mem_a[26]),
        .a33(mem_a[27]),
        .a34(mem_a[28]),
        .a35(mem_a[29]),
        .a36(mem_a[30]),
        .a37(mem_a[31]),
        .a40(mem_a[32]),
        .a41(mem_a[33]),
        .a42(mem_a[34]),
        .a43(mem_a[35]),
        .a44(mem_a[36]),
        .a45(mem_a[37]),
        .a46(mem_a[38]),
        .a47(mem_a[39]),
        .a50(mem_a[40]),
        .a51(mem_a[41]),
        .a52(mem_a[42]),
        .a53(mem_a[43]),
        .a54(mem_a[44]),
        .a55(mem_a[45]),
        .a56(mem_a[46]),
        .a57(mem_a[47]),
        .a60(mem_a[48]),
        .a61(mem_a[49]),
        .a62(mem_a[50]),
        .a63(mem_a[51]),
        .a64(mem_a[52]),
        .a65(mem_a[53]),
        .a66(mem_a[54]),
        .a67(mem_a[55]),
        .a70(mem_a[56]),
        .a71(mem_a[57]),
        .a72(mem_a[58]),
        .a73(mem_a[59]),
        .a74(mem_a[60]),
        .a75(mem_a[61]),
        .a76(mem_a[62]),
        .a77(mem_a[63]),

        .b00(mem_b[0]),
        .b01(mem_b[1]),
        .b02(mem_b[2]),
        .b03(mem_b[3]),
        .b04(mem_b[4]),
        .b05(mem_b[5]),
        .b06(mem_b[6]),
        .b07(mem_b[7]),
        .b10(mem_b[8]),
        .b11(mem_b[9]),
        .b12(mem_b[10]),
        .b13(mem_b[11]),
        .b14(mem_b[12]),
        .b15(mem_b[13]),
        .b16(mem_b[14]),
        .b17(mem_b[15]),
        .b20(mem_b[16]),
        .b21(mem_b[17]),
        .b22(mem_b[18]),
        .b23(mem_b[19]),
        .b24(mem_b[20]),
        .b25(mem_b[21]),
        .b26(mem_b[22]),
        .b27(mem_b[23]),
        .b30(mem_b[24]),
        .b31(mem_b[25]),
        .b32(mem_b[26]),
        .b33(mem_b[27]),
        .b34(mem_b[28]),
        .b35(mem_b[29]),
        .b36(mem_b[30]),
        .b37(mem_b[31]),
        .b40(mem_b[32]),
        .b41(mem_b[33]),
        .b42(mem_b[34]),
        .b43(mem_b[35]),
        .b44(mem_b[36]),
        .b45(mem_b[37]),
        .b46(mem_b[38]),
        .b47(mem_b[39]),
        .b50(mem_b[40]),
        .b51(mem_b[41]),
        .b52(mem_b[42]),
        .b53(mem_b[43]),
        .b54(mem_b[44]),
        .b55(mem_b[45]),
        .b56(mem_b[46]),
        .b57(mem_b[47]),
        .b60(mem_b[48]),
        .b61(mem_b[49]),
        .b62(mem_b[50]),
        .b63(mem_b[51]),
        .b64(mem_b[52]),
        .b65(mem_b[53]),
        .b66(mem_b[54]),
        .b67(mem_b[55]),
        .b70(mem_b[56]),
        .b71(mem_b[57]),
        .b72(mem_b[58]),
        .b73(mem_b[59]),
        .b74(mem_b[60]),
        .b75(mem_b[61]),
        .b76(mem_b[62]),
        .b77(mem_b[63]),

        .c00(c00),
        .c01(c01),
        .c02(c02),
        .c03(c03),
        .c04(c04),
        .c05(c05),
        .c06(c06),
        .c07(c07),
        .c10(c10),
        .c11(c11),
        .c12(c12),
        .c13(c13),
        .c14(c14),
        .c15(c15),
        .c16(c16),
        .c17(c17),
        .c20(c20),
        .c21(c21),
        .c22(c22),
        .c23(c23),
        .c24(c24),
        .c25(c25),
        .c26(c26),
        .c27(c27),
        .c30(c30),
        .c31(c31),
        .c32(c32),
        .c33(c33),
        .c34(c34),
        .c35(c35),
        .c36(c36),
        .c37(c37),
        .c40(c40),
        .c41(c41),
        .c42(c42),
        .c43(c43),
        .c44(c44),
        .c45(c45),
        .c46(c46),
        .c47(c47),
        .c50(c50),
        .c51(c51),
        .c52(c52),
        .c53(c53),
        .c54(c54),
        .c55(c55),
        .c56(c56),
        .c57(c57),
        .c60(c60),
        .c61(c61),
        .c62(c62),
        .c63(c63),
        .c64(c64),
        .c65(c65),
        .c66(c66),
        .c67(c67),
        .c70(c70),
        .c71(c71),
        .c72(c72),
        .c73(c73),
        .c74(c74),
        .c75(c75),
        .c76(c76),
        .c77(c77),

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

    function is_a_addr;
        input [11:0] addr;
        begin
            is_a_addr = (addr >= ADDR_A_BASE && addr < ADDR_A_BASE + 12'd256 && addr[1:0] == 2'b00);
        end
    endfunction

    function is_b_addr;
        input [11:0] addr;
        begin
            is_b_addr = (addr >= ADDR_B_BASE && addr < ADDR_B_BASE + 12'd256 && addr[1:0] == 2'b00);
        end
    endfunction

    function is_c_addr;
        input [11:0] addr;
        begin
            is_c_addr = (addr >= ADDR_C_BASE && addr < ADDR_C_BASE + 12'd256 && addr[1:0] == 2'b00);
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
                read_register = {
                    28'd0,
                    irq,
                    valid_latched,
                    done_latched,
                    core_busy
                };
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

            for (i = 0; i < 64; i = i + 1) begin
                mem_a[i] <= 8'sd0;
                mem_b[i] <= 8'sd0;
                mem_c[i] <= 32'sd0;
            end
        end else begin
            start_pulse <= 1'b0;

            if (core_done) begin
                done_latched  <= 1'b1;
                valid_latched <= 1'b1;

                mem_c[0] <= c00;
                mem_c[1] <= c01;
                mem_c[2] <= c02;
                mem_c[3] <= c03;
                mem_c[4] <= c04;
                mem_c[5] <= c05;
                mem_c[6] <= c06;
                mem_c[7] <= c07;
                mem_c[8] <= c10;
                mem_c[9] <= c11;
                mem_c[10] <= c12;
                mem_c[11] <= c13;
                mem_c[12] <= c14;
                mem_c[13] <= c15;
                mem_c[14] <= c16;
                mem_c[15] <= c17;
                mem_c[16] <= c20;
                mem_c[17] <= c21;
                mem_c[18] <= c22;
                mem_c[19] <= c23;
                mem_c[20] <= c24;
                mem_c[21] <= c25;
                mem_c[22] <= c26;
                mem_c[23] <= c27;
                mem_c[24] <= c30;
                mem_c[25] <= c31;
                mem_c[26] <= c32;
                mem_c[27] <= c33;
                mem_c[28] <= c34;
                mem_c[29] <= c35;
                mem_c[30] <= c36;
                mem_c[31] <= c37;
                mem_c[32] <= c40;
                mem_c[33] <= c41;
                mem_c[34] <= c42;
                mem_c[35] <= c43;
                mem_c[36] <= c44;
                mem_c[37] <= c45;
                mem_c[38] <= c46;
                mem_c[39] <= c47;
                mem_c[40] <= c50;
                mem_c[41] <= c51;
                mem_c[42] <= c52;
                mem_c[43] <= c53;
                mem_c[44] <= c54;
                mem_c[45] <= c55;
                mem_c[46] <= c56;
                mem_c[47] <= c57;
                mem_c[48] <= c60;
                mem_c[49] <= c61;
                mem_c[50] <= c62;
                mem_c[51] <= c63;
                mem_c[52] <= c64;
                mem_c[53] <= c65;
                mem_c[54] <= c66;
                mem_c[55] <= c67;
                mem_c[56] <= c70;
                mem_c[57] <= c71;
                mem_c[58] <= c72;
                mem_c[59] <= c73;
                mem_c[60] <= c74;
                mem_c[61] <= c75;
                mem_c[62] <= c76;
                mem_c[63] <= c77;
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
