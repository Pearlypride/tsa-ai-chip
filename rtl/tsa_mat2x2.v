module tsa_mat2x2 (
    input  wire        clk,
    input  wire        reset,
    input  wire        enable,

    input  wire [7:0]  a00,
    input  wire [7:0]  a01,
    input  wire [7:0]  a10,
    input  wire [7:0]  a11,

    input  wire [7:0]  b00,
    input  wire [7:0]  b01,
    input  wire [7:0]  b10,
    input  wire [7:0]  b11,

    output reg  [31:0] c00,
    output reg  [31:0] c01,
    output reg  [31:0] c10,
    output reg  [31:0] c11
);

    wire [31:0] sum00;
    wire [31:0] sum01;
    wire [31:0] sum10;
    wire [31:0] sum11;

    assign sum00 = (a00 * b00) + (a01 * b10);
    assign sum01 = (a00 * b01) + (a01 * b11);
    assign sum10 = (a10 * b00) + (a11 * b10);
    assign sum11 = (a10 * b01) + (a11 * b11);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            c00 <= 32'd0;
            c01 <= 32'd0;
            c10 <= 32'd0;
            c11 <= 32'd0;
        end else if (enable) begin
            c00 <= sum00;
            c01 <= sum01;
            c10 <= sum10;
            c11 <= sum11;
        end
    end

endmodule
