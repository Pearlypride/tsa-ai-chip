module tsa_systolic_8x8_i8 (
    input  wire                    clk,
    input  wire                    reset,
    input  wire                    enable,
    input  wire                    clear,

    input  wire signed [7:0]       a0_in,
    input  wire signed [7:0]       a1_in,
    input  wire signed [7:0]       a2_in,
    input  wire signed [7:0]       a3_in,
    input  wire signed [7:0]       a4_in,
    input  wire signed [7:0]       a5_in,
    input  wire signed [7:0]       a6_in,
    input  wire signed [7:0]       a7_in,

    input  wire signed [7:0]       b0_in,
    input  wire signed [7:0]       b1_in,
    input  wire signed [7:0]       b2_in,
    input  wire signed [7:0]       b3_in,
    input  wire signed [7:0]       b4_in,
    input  wire signed [7:0]       b5_in,
    input  wire signed [7:0]       b6_in,
    input  wire signed [7:0]       b7_in,

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
    output wire signed [31:0]      c77
);

    wire signed [7:0]  a_link [0:7][0:8];
    wire signed [7:0]  b_link [0:8][0:7];
    wire signed [31:0] acc    [0:7][0:7];

    assign a_link[0][0] = a0_in;
    assign a_link[1][0] = a1_in;
    assign a_link[2][0] = a2_in;
    assign a_link[3][0] = a3_in;
    assign a_link[4][0] = a4_in;
    assign a_link[5][0] = a5_in;
    assign a_link[6][0] = a6_in;
    assign a_link[7][0] = a7_in;

    assign b_link[0][0] = b0_in;
    assign b_link[0][1] = b1_in;
    assign b_link[0][2] = b2_in;
    assign b_link[0][3] = b3_in;
    assign b_link[0][4] = b4_in;
    assign b_link[0][5] = b5_in;
    assign b_link[0][6] = b6_in;
    assign b_link[0][7] = b7_in;


    genvar r;
    genvar col;

    generate
        for (r = 0; r < 8; r = r + 1) begin : ROWS
            for (col = 0; col < 8; col = col + 1) begin : COLS
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

    assign c00 = acc[0][0];
    assign c01 = acc[0][1];
    assign c02 = acc[0][2];
    assign c03 = acc[0][3];
    assign c04 = acc[0][4];
    assign c05 = acc[0][5];
    assign c06 = acc[0][6];
    assign c07 = acc[0][7];
    assign c10 = acc[1][0];
    assign c11 = acc[1][1];
    assign c12 = acc[1][2];
    assign c13 = acc[1][3];
    assign c14 = acc[1][4];
    assign c15 = acc[1][5];
    assign c16 = acc[1][6];
    assign c17 = acc[1][7];
    assign c20 = acc[2][0];
    assign c21 = acc[2][1];
    assign c22 = acc[2][2];
    assign c23 = acc[2][3];
    assign c24 = acc[2][4];
    assign c25 = acc[2][5];
    assign c26 = acc[2][6];
    assign c27 = acc[2][7];
    assign c30 = acc[3][0];
    assign c31 = acc[3][1];
    assign c32 = acc[3][2];
    assign c33 = acc[3][3];
    assign c34 = acc[3][4];
    assign c35 = acc[3][5];
    assign c36 = acc[3][6];
    assign c37 = acc[3][7];
    assign c40 = acc[4][0];
    assign c41 = acc[4][1];
    assign c42 = acc[4][2];
    assign c43 = acc[4][3];
    assign c44 = acc[4][4];
    assign c45 = acc[4][5];
    assign c46 = acc[4][6];
    assign c47 = acc[4][7];
    assign c50 = acc[5][0];
    assign c51 = acc[5][1];
    assign c52 = acc[5][2];
    assign c53 = acc[5][3];
    assign c54 = acc[5][4];
    assign c55 = acc[5][5];
    assign c56 = acc[5][6];
    assign c57 = acc[5][7];
    assign c60 = acc[6][0];
    assign c61 = acc[6][1];
    assign c62 = acc[6][2];
    assign c63 = acc[6][3];
    assign c64 = acc[6][4];
    assign c65 = acc[6][5];
    assign c66 = acc[6][6];
    assign c67 = acc[6][7];
    assign c70 = acc[7][0];
    assign c71 = acc[7][1];
    assign c72 = acc[7][2];
    assign c73 = acc[7][3];
    assign c74 = acc[7][4];
    assign c75 = acc[7][5];
    assign c76 = acc[7][6];
    assign c77 = acc[7][7];

endmodule
