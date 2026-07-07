module tsa_systolic_4x4_i8 (
    input  wire                    clk,
    input  wire                    reset,
    input  wire                    enable,
    input  wire                    clear,

    input  wire signed [7:0]       a0_in,
    input  wire signed [7:0]       a1_in,
    input  wire signed [7:0]       a2_in,
    input  wire signed [7:0]       a3_in,

    input  wire signed [7:0]       b0_in,
    input  wire signed [7:0]       b1_in,
    input  wire signed [7:0]       b2_in,
    input  wire signed [7:0]       b3_in,

    output wire signed [31:0]      c00,
    output wire signed [31:0]      c01,
    output wire signed [31:0]      c02,
    output wire signed [31:0]      c03,

    output wire signed [31:0]      c10,
    output wire signed [31:0]      c11,
    output wire signed [31:0]      c12,
    output wire signed [31:0]      c13,

    output wire signed [31:0]      c20,
    output wire signed [31:0]      c21,
    output wire signed [31:0]      c22,
    output wire signed [31:0]      c23,

    output wire signed [31:0]      c30,
    output wire signed [31:0]      c31,
    output wire signed [31:0]      c32,
    output wire signed [31:0]      c33
);

    wire signed [7:0]  a_link [0:3][0:4];
    wire signed [7:0]  b_link [0:4][0:3];
    wire signed [31:0] acc    [0:3][0:3];

    assign a_link[0][0] = a0_in;
    assign a_link[1][0] = a1_in;
    assign a_link[2][0] = a2_in;
    assign a_link[3][0] = a3_in;

    assign b_link[0][0] = b0_in;
    assign b_link[0][1] = b1_in;
    assign b_link[0][2] = b2_in;
    assign b_link[0][3] = b3_in;

    genvar r;
    genvar col;

    generate
        for (r = 0; r < 4; r = r + 1) begin : ROWS
            for (col = 0; col < 4; col = col + 1) begin : COLS
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

    assign c10 = acc[1][0];
    assign c11 = acc[1][1];
    assign c12 = acc[1][2];
    assign c13 = acc[1][3];

    assign c20 = acc[2][0];
    assign c21 = acc[2][1];
    assign c22 = acc[2][2];
    assign c23 = acc[2][3];

    assign c30 = acc[3][0];
    assign c31 = acc[3][1];
    assign c32 = acc[3][2];
    assign c33 = acc[3][3];

endmodule
