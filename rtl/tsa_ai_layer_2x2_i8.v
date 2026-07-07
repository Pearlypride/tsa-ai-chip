module tsa_ai_layer_2x2_i8 (
    input  wire                    clk,
    input  wire                    reset,
    input  wire                    start,

    input  wire signed [7:0]       a00,
    input  wire signed [7:0]       a01,
    input  wire signed [7:0]       a10,
    input  wire signed [7:0]       a11,

    input  wire signed [7:0]       b00,
    input  wire signed [7:0]       b01,
    input  wire signed [7:0]       b10,
    input  wire signed [7:0]       b11,

    output wire signed [31:0]      raw_c00,
    output wire signed [31:0]      raw_c01,
    output wire signed [31:0]      raw_c10,
    output wire signed [31:0]      raw_c11,

    output wire signed [31:0]      act_c00,
    output wire signed [31:0]      act_c01,
    output wire signed [31:0]      act_c10,
    output wire signed [31:0]      act_c11,

    output wire                    busy,
    output wire                    done,
    output wire                    valid
);

    tsa_systolic_2x2_core_i8 core (
        .clk(clk),
        .reset(reset),
        .start(start),

        .a00(a00),
        .a01(a01),
        .a10(a10),
        .a11(a11),

        .b00(b00),
        .b01(b01),
        .b10(b10),
        .b11(b11),

        .c00(raw_c00),
        .c01(raw_c01),
        .c10(raw_c10),
        .c11(raw_c11),

        .busy(busy),
        .done(done),
        .valid(valid)
    );

    tsa_relu_i32 relu00 (
        .in_value(raw_c00),
        .out_value(act_c00)
    );

    tsa_relu_i32 relu01 (
        .in_value(raw_c01),
        .out_value(act_c01)
    );

    tsa_relu_i32 relu10 (
        .in_value(raw_c10),
        .out_value(act_c10)
    );

    tsa_relu_i32 relu11 (
        .in_value(raw_c11),
        .out_value(act_c11)
    );

endmodule
