module tsa_systolic_8x8_core_i8 (
    input  wire                    clk,
    input  wire                    reset,
    input  wire                    start,

    input  wire signed [7:0]       a00,
    input  wire signed [7:0]       a01,
    input  wire signed [7:0]       a02,
    input  wire signed [7:0]       a03,
    input  wire signed [7:0]       a04,
    input  wire signed [7:0]       a05,
    input  wire signed [7:0]       a06,
    input  wire signed [7:0]       a07,
    input  wire signed [7:0]       a10,
    input  wire signed [7:0]       a11,
    input  wire signed [7:0]       a12,
    input  wire signed [7:0]       a13,
    input  wire signed [7:0]       a14,
    input  wire signed [7:0]       a15,
    input  wire signed [7:0]       a16,
    input  wire signed [7:0]       a17,
    input  wire signed [7:0]       a20,
    input  wire signed [7:0]       a21,
    input  wire signed [7:0]       a22,
    input  wire signed [7:0]       a23,
    input  wire signed [7:0]       a24,
    input  wire signed [7:0]       a25,
    input  wire signed [7:0]       a26,
    input  wire signed [7:0]       a27,
    input  wire signed [7:0]       a30,
    input  wire signed [7:0]       a31,
    input  wire signed [7:0]       a32,
    input  wire signed [7:0]       a33,
    input  wire signed [7:0]       a34,
    input  wire signed [7:0]       a35,
    input  wire signed [7:0]       a36,
    input  wire signed [7:0]       a37,
    input  wire signed [7:0]       a40,
    input  wire signed [7:0]       a41,
    input  wire signed [7:0]       a42,
    input  wire signed [7:0]       a43,
    input  wire signed [7:0]       a44,
    input  wire signed [7:0]       a45,
    input  wire signed [7:0]       a46,
    input  wire signed [7:0]       a47,
    input  wire signed [7:0]       a50,
    input  wire signed [7:0]       a51,
    input  wire signed [7:0]       a52,
    input  wire signed [7:0]       a53,
    input  wire signed [7:0]       a54,
    input  wire signed [7:0]       a55,
    input  wire signed [7:0]       a56,
    input  wire signed [7:0]       a57,
    input  wire signed [7:0]       a60,
    input  wire signed [7:0]       a61,
    input  wire signed [7:0]       a62,
    input  wire signed [7:0]       a63,
    input  wire signed [7:0]       a64,
    input  wire signed [7:0]       a65,
    input  wire signed [7:0]       a66,
    input  wire signed [7:0]       a67,
    input  wire signed [7:0]       a70,
    input  wire signed [7:0]       a71,
    input  wire signed [7:0]       a72,
    input  wire signed [7:0]       a73,
    input  wire signed [7:0]       a74,
    input  wire signed [7:0]       a75,
    input  wire signed [7:0]       a76,
    input  wire signed [7:0]       a77,

    input  wire signed [7:0]       b00,
    input  wire signed [7:0]       b01,
    input  wire signed [7:0]       b02,
    input  wire signed [7:0]       b03,
    input  wire signed [7:0]       b04,
    input  wire signed [7:0]       b05,
    input  wire signed [7:0]       b06,
    input  wire signed [7:0]       b07,
    input  wire signed [7:0]       b10,
    input  wire signed [7:0]       b11,
    input  wire signed [7:0]       b12,
    input  wire signed [7:0]       b13,
    input  wire signed [7:0]       b14,
    input  wire signed [7:0]       b15,
    input  wire signed [7:0]       b16,
    input  wire signed [7:0]       b17,
    input  wire signed [7:0]       b20,
    input  wire signed [7:0]       b21,
    input  wire signed [7:0]       b22,
    input  wire signed [7:0]       b23,
    input  wire signed [7:0]       b24,
    input  wire signed [7:0]       b25,
    input  wire signed [7:0]       b26,
    input  wire signed [7:0]       b27,
    input  wire signed [7:0]       b30,
    input  wire signed [7:0]       b31,
    input  wire signed [7:0]       b32,
    input  wire signed [7:0]       b33,
    input  wire signed [7:0]       b34,
    input  wire signed [7:0]       b35,
    input  wire signed [7:0]       b36,
    input  wire signed [7:0]       b37,
    input  wire signed [7:0]       b40,
    input  wire signed [7:0]       b41,
    input  wire signed [7:0]       b42,
    input  wire signed [7:0]       b43,
    input  wire signed [7:0]       b44,
    input  wire signed [7:0]       b45,
    input  wire signed [7:0]       b46,
    input  wire signed [7:0]       b47,
    input  wire signed [7:0]       b50,
    input  wire signed [7:0]       b51,
    input  wire signed [7:0]       b52,
    input  wire signed [7:0]       b53,
    input  wire signed [7:0]       b54,
    input  wire signed [7:0]       b55,
    input  wire signed [7:0]       b56,
    input  wire signed [7:0]       b57,
    input  wire signed [7:0]       b60,
    input  wire signed [7:0]       b61,
    input  wire signed [7:0]       b62,
    input  wire signed [7:0]       b63,
    input  wire signed [7:0]       b64,
    input  wire signed [7:0]       b65,
    input  wire signed [7:0]       b66,
    input  wire signed [7:0]       b67,
    input  wire signed [7:0]       b70,
    input  wire signed [7:0]       b71,
    input  wire signed [7:0]       b72,
    input  wire signed [7:0]       b73,
    input  wire signed [7:0]       b74,
    input  wire signed [7:0]       b75,
    input  wire signed [7:0]       b76,
    input  wire signed [7:0]       b77,

    output wire signed [31:0]      c00,
    output wire signed [31:0]      c01,
    output wire signed [31:0]      c02,
    output wire signed [31:0]      c03,
    output wire signed [31:0]      c04,
    output wire signed [31:0]      c05,
    output wire signed [31:0]      c06,
    output wire signed [31:0]      c07,
    output wire signed [31:0]      c10,
    output wire signed [31:0]      c11,
    output wire signed [31:0]      c12,
    output wire signed [31:0]      c13,
    output wire signed [31:0]      c14,
    output wire signed [31:0]      c15,
    output wire signed [31:0]      c16,
    output wire signed [31:0]      c17,
    output wire signed [31:0]      c20,
    output wire signed [31:0]      c21,
    output wire signed [31:0]      c22,
    output wire signed [31:0]      c23,
    output wire signed [31:0]      c24,
    output wire signed [31:0]      c25,
    output wire signed [31:0]      c26,
    output wire signed [31:0]      c27,
    output wire signed [31:0]      c30,
    output wire signed [31:0]      c31,
    output wire signed [31:0]      c32,
    output wire signed [31:0]      c33,
    output wire signed [31:0]      c34,
    output wire signed [31:0]      c35,
    output wire signed [31:0]      c36,
    output wire signed [31:0]      c37,
    output wire signed [31:0]      c40,
    output wire signed [31:0]      c41,
    output wire signed [31:0]      c42,
    output wire signed [31:0]      c43,
    output wire signed [31:0]      c44,
    output wire signed [31:0]      c45,
    output wire signed [31:0]      c46,
    output wire signed [31:0]      c47,
    output wire signed [31:0]      c50,
    output wire signed [31:0]      c51,
    output wire signed [31:0]      c52,
    output wire signed [31:0]      c53,
    output wire signed [31:0]      c54,
    output wire signed [31:0]      c55,
    output wire signed [31:0]      c56,
    output wire signed [31:0]      c57,
    output wire signed [31:0]      c60,
    output wire signed [31:0]      c61,
    output wire signed [31:0]      c62,
    output wire signed [31:0]      c63,
    output wire signed [31:0]      c64,
    output wire signed [31:0]      c65,
    output wire signed [31:0]      c66,
    output wire signed [31:0]      c67,
    output wire signed [31:0]      c70,
    output wire signed [31:0]      c71,
    output wire signed [31:0]      c72,
    output wire signed [31:0]      c73,
    output wire signed [31:0]      c74,
    output wire signed [31:0]      c75,
    output wire signed [31:0]      c76,
    output wire signed [31:0]      c77,

    output reg                     busy,
    output reg                     done,
    output reg                     valid
);

    reg enable;
    reg clear;

    reg [5:0] cycle;
    reg [2:0] state;

    reg signed [7:0] A [0:7][0:7];
    reg signed [7:0] B [0:7][0:7];

    reg signed [7:0] a_feed [0:7];
    reg signed [7:0] b_feed [0:7];

    integer i;
    integer j;
    integer k;

    localparam IDLE  = 3'd0;
    localparam CLEAR = 3'd1;
    localparam RUN   = 3'd2;
    localparam DONE  = 3'd3;

    always @(*) begin
        A[0][0] = a00;
        A[0][1] = a01;
        A[0][2] = a02;
        A[0][3] = a03;
        A[0][4] = a04;
        A[0][5] = a05;
        A[0][6] = a06;
        A[0][7] = a07;
        A[1][0] = a10;
        A[1][1] = a11;
        A[1][2] = a12;
        A[1][3] = a13;
        A[1][4] = a14;
        A[1][5] = a15;
        A[1][6] = a16;
        A[1][7] = a17;
        A[2][0] = a20;
        A[2][1] = a21;
        A[2][2] = a22;
        A[2][3] = a23;
        A[2][4] = a24;
        A[2][5] = a25;
        A[2][6] = a26;
        A[2][7] = a27;
        A[3][0] = a30;
        A[3][1] = a31;
        A[3][2] = a32;
        A[3][3] = a33;
        A[3][4] = a34;
        A[3][5] = a35;
        A[3][6] = a36;
        A[3][7] = a37;
        A[4][0] = a40;
        A[4][1] = a41;
        A[4][2] = a42;
        A[4][3] = a43;
        A[4][4] = a44;
        A[4][5] = a45;
        A[4][6] = a46;
        A[4][7] = a47;
        A[5][0] = a50;
        A[5][1] = a51;
        A[5][2] = a52;
        A[5][3] = a53;
        A[5][4] = a54;
        A[5][5] = a55;
        A[5][6] = a56;
        A[5][7] = a57;
        A[6][0] = a60;
        A[6][1] = a61;
        A[6][2] = a62;
        A[6][3] = a63;
        A[6][4] = a64;
        A[6][5] = a65;
        A[6][6] = a66;
        A[6][7] = a67;
        A[7][0] = a70;
        A[7][1] = a71;
        A[7][2] = a72;
        A[7][3] = a73;
        A[7][4] = a74;
        A[7][5] = a75;
        A[7][6] = a76;
        A[7][7] = a77;

        B[0][0] = b00;
        B[0][1] = b01;
        B[0][2] = b02;
        B[0][3] = b03;
        B[0][4] = b04;
        B[0][5] = b05;
        B[0][6] = b06;
        B[0][7] = b07;
        B[1][0] = b10;
        B[1][1] = b11;
        B[1][2] = b12;
        B[1][3] = b13;
        B[1][4] = b14;
        B[1][5] = b15;
        B[1][6] = b16;
        B[1][7] = b17;
        B[2][0] = b20;
        B[2][1] = b21;
        B[2][2] = b22;
        B[2][3] = b23;
        B[2][4] = b24;
        B[2][5] = b25;
        B[2][6] = b26;
        B[2][7] = b27;
        B[3][0] = b30;
        B[3][1] = b31;
        B[3][2] = b32;
        B[3][3] = b33;
        B[3][4] = b34;
        B[3][5] = b35;
        B[3][6] = b36;
        B[3][7] = b37;
        B[4][0] = b40;
        B[4][1] = b41;
        B[4][2] = b42;
        B[4][3] = b43;
        B[4][4] = b44;
        B[4][5] = b45;
        B[4][6] = b46;
        B[4][7] = b47;
        B[5][0] = b50;
        B[5][1] = b51;
        B[5][2] = b52;
        B[5][3] = b53;
        B[5][4] = b54;
        B[5][5] = b55;
        B[5][6] = b56;
        B[5][7] = b57;
        B[6][0] = b60;
        B[6][1] = b61;
        B[6][2] = b62;
        B[6][3] = b63;
        B[6][4] = b64;
        B[6][5] = b65;
        B[6][6] = b66;
        B[6][7] = b67;
        B[7][0] = b70;
        B[7][1] = b71;
        B[7][2] = b72;
        B[7][3] = b73;
        B[7][4] = b74;
        B[7][5] = b75;
        B[7][6] = b76;
        B[7][7] = b77;

        for (i = 0; i < 8; i = i + 1) begin
            a_feed[i] = 8'sd0;
            b_feed[i] = 8'sd0;
        end

        for (i = 0; i < 8; i = i + 1) begin
            k = cycle - i;
            if (k >= 0 && k < 8) begin
                a_feed[i] = A[i][k];
            end
        end

        for (j = 0; j < 8; j = j + 1) begin
            k = cycle - j;
            if (k >= 0 && k < 8) begin
                b_feed[j] = B[k][j];
            end
        end
    end

    tsa_systolic_8x8_i8 array (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .clear(clear),

        .a0_in(a_feed[0]),
        .a1_in(a_feed[1]),
        .a2_in(a_feed[2]),
        .a3_in(a_feed[3]),
        .a4_in(a_feed[4]),
        .a5_in(a_feed[5]),
        .a6_in(a_feed[6]),
        .a7_in(a_feed[7]),

        .b0_in(b_feed[0]),
        .b1_in(b_feed[1]),
        .b2_in(b_feed[2]),
        .b3_in(b_feed[3]),
        .b4_in(b_feed[4]),
        .b5_in(b_feed[5]),
        .b6_in(b_feed[6]),
        .b7_in(b_feed[7]),

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
        .c77(c77)
    );

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

                    if (cycle == 6'd21) begin
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
