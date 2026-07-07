module tsa_pe (
    input  wire        clk,
    input  wire        reset,
    input  wire        enable,
    input  wire        clear,

    input  wire [7:0]  a_in,
    input  wire [7:0]  b_in,

    output reg  [7:0]  a_out,
    output reg  [7:0]  b_out,

    output reg  [31:0] acc
);

    wire [15:0] product;

    assign product = a_in * b_in;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            a_out <= 8'd0;
            b_out <= 8'd0;
            acc   <= 32'd0;
        end else begin
            if (clear) begin
                acc <= 32'd0;
            end

            if (enable) begin
                a_out <= a_in;
                b_out <= b_in;
                acc   <= acc + product;
            end
        end
    end

endmodule
