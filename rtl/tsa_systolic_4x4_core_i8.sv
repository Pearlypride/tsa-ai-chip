module tsa_systolic_4x4_core_i8 (
    input  wire                    clk,
    input  wire                    reset,
    input  wire                    start,

    input  wire signed [7:0]       a00, a01, a02, a03,
    input  wire signed [7:0]       a10, a11, a12, a13,
    input  wire signed [7:0]       a20, a21, a22, a23,
    input  wire signed [7:0]       a30, a31, a32, a33,

    input  wire signed [7:0]       b00, b01, b02, b03,
    input  wire signed [7:0]       b10, b11, b12, b13,
    input  wire signed [7:0]       b20, b21, b22, b23,
    input  wire signed [7:0]       b30, b31, b32, b33,

    output wire signed [31:0]      c00, c01, c02, c03,
    output wire signed [31:0]      c10, c11, c12, c13,
    output wire signed [31:0]      c20, c21, c22, c23,
    output wire signed [31:0]      c30, c31, c32, c33,

    output reg                     busy,
    output reg                     done,
    output reg                     valid
);

    reg enable;
    reg clear;

    reg [3:0] cycle;
    reg [2:0] state;

    reg signed [7:0] A [0:3][0:3];
    reg signed [7:0] B [0:3][0:3];

    reg signed [7:0] a_feed [0:3];
    reg signed [7:0] b_feed [0:3];

    integer i;
    integer j;
    integer k;

    localparam IDLE  = 3'd0;
    localparam CLEAR = 3'd1;
    localparam RUN   = 3'd2;
    localparam DONE  = 3'd3;

    always @(*) begin
        A[0][0] = a00; A[0][1] = a01; A[0][2] = a02; A[0][3] = a03;
        A[1][0] = a10; A[1][1] = a11; A[1][2] = a12; A[1][3] = a13;
        A[2][0] = a20; A[2][1] = a21; A[2][2] = a22; A[2][3] = a23;
        A[3][0] = a30; A[3][1] = a31; A[3][2] = a32; A[3][3] = a33;

        B[0][0] = b00; B[0][1] = b01; B[0][2] = b02; B[0][3] = b03;
        B[1][0] = b10; B[1][1] = b11; B[1][2] = b12; B[1][3] = b13;
        B[2][0] = b20; B[2][1] = b21; B[2][2] = b22; B[2][3] = b23;
        B[3][0] = b30; B[3][1] = b31; B[3][2] = b32; B[3][3] = b33;

        for (i = 0; i < 4; i = i + 1) begin
            a_feed[i] = 8'sd0;
            b_feed[i] = 8'sd0;
        end

        for (i = 0; i < 4; i = i + 1) begin
            k = cycle - i;
            if (k >= 0 && k < 4) begin
                a_feed[i] = A[i][k];
            end
        end

        for (j = 0; j < 4; j = j + 1) begin
            k = cycle - j;
            if (k >= 0 && k < 4) begin
                b_feed[j] = B[k][j];
            end
        end
    end

    tsa_systolic_4x4_i8 array (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .clear(clear),

        .a0_in(a_feed[0]),
        .a1_in(a_feed[1]),
        .a2_in(a_feed[2]),
        .a3_in(a_feed[3]),

        .b0_in(b_feed[0]),
        .b1_in(b_feed[1]),
        .b2_in(b_feed[2]),
        .b3_in(b_feed[3]),

        .c00(c00), .c01(c01), .c02(c02), .c03(c03),
        .c10(c10), .c11(c11), .c12(c12), .c13(c13),
        .c20(c20), .c21(c21), .c22(c22), .c23(c23),
        .c30(c30), .c31(c31), .c32(c32), .c33(c33)
    );

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state  <= IDLE;
            cycle  <= 4'd0;

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
                        cycle  <= 4'd0;
                        state  <= CLEAR;
                    end
                end

                CLEAR: begin
                    clear  <= 1'b0;
                    enable <= 1'b1;
                    busy   <= 1'b1;
                    done   <= 1'b0;
                    valid  <= 1'b0;
                    cycle  <= 4'd0;
                    state  <= RUN;
                end

                RUN: begin
                    enable <= 1'b1;
                    clear  <= 1'b0;
                    busy   <= 1'b1;
                    done   <= 1'b0;
                    valid  <= 1'b0;

                    if (cycle == 4'd9) begin
                        state <= DONE;
                    end else begin
                        cycle <= cycle + 4'd1;
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
                    cycle  <= 4'd0;
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
