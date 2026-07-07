module tsa_dot4 (
    input  wire        clk,
    input  wire        reset,
    input  wire        enable,

    input  wire [7:0]  a0,
    input  wire [7:0]  a1,
    input  wire [7:0]  a2,
    input  wire [7:0]  a3,

    input  wire [7:0]  b0,
    input  wire [7:0]  b1,
    input  wire [7:0]  b2,
    input  wire [7:0]  b3,

    output reg  [31:0] result
);

    wire [15:0] p0;
    wire [15:0] p1;
    wire [15:0] p2;
    wire [15:0] p3;

    wire [31:0] sum;

    assign p0 = a0 * b0;
    assign p1 = a1 * b1;
    assign p2 = a2 * b2;
    assign p3 = a3 * b3;

    assign sum = p0 + p1 + p2 + p3;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            result <= 32'd0;
        end else if (enable) begin
            result <= sum;
        end
    end

endmodule
