module tsa_systolic_2x2 (
    input  wire        clk,
    input  wire        reset,
    input  wire        enable,
    input  wire        clear,

    input  wire [7:0]  a0_in,
    input  wire [7:0]  a1_in,

    input  wire [7:0]  b0_in,
    input  wire [7:0]  b1_in,

    output wire [31:0] c00,
    output wire [31:0] c01,
    output wire [31:0] c10,
    output wire [31:0] c11
);

    wire [7:0] a00_to_01;
    wire [7:0] a10_to_11;

    wire [7:0] b00_to_10;
    wire [7:0] b01_to_11;

    tsa_pe pe00 (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .clear(clear),
        .a_in(a0_in),
        .b_in(b0_in),
        .a_out(a00_to_01),
        .b_out(b00_to_10),
        .acc(c00)
    );

    tsa_pe pe01 (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .clear(clear),
        .a_in(a00_to_01),
        .b_in(b1_in),
        .a_out(),
        .b_out(b01_to_11),
        .acc(c01)
    );

    tsa_pe pe10 (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .clear(clear),
        .a_in(a1_in),
        .b_in(b00_to_10),
        .a_out(a10_to_11),
        .b_out(),
        .acc(c10)
    );

    tsa_pe pe11 (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .clear(clear),
        .a_in(a10_to_11),
        .b_in(b01_to_11),
        .a_out(),
        .b_out(),
        .acc(c11)
    );

endmodule
