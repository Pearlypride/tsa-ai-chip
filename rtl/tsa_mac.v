module tsa_mac (
    input  wire        clk,
    input  wire        reset,
    input  wire        enable,

    input  wire [7:0]  a,
    input  wire [7:0]  b,

    output reg  [31:0] acc
);

    wire [15:0] product;

    assign product = a * b;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            acc <= 32'd0;
        end else begin
            if (enable) begin
                acc <= acc + product;
            end
        end
    end

endmodule
