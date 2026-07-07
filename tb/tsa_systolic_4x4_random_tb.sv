`timescale 1ns/1ps

module tsa_systolic_4x4_random_tb;

    reg clk;
    reg reset;
    reg start;

    reg signed [7:0] a00, a01, a02, a03;
    reg signed [7:0] a10, a11, a12, a13;
    reg signed [7:0] a20, a21, a22, a23;
    reg signed [7:0] a30, a31, a32, a33;

    reg signed [7:0] b00, b01, b02, b03;
    reg signed [7:0] b10, b11, b12, b13;
    reg signed [7:0] b20, b21, b22, b23;
    reg signed [7:0] b30, b31, b32, b33;

    wire signed [31:0] c00, c01, c02, c03;
    wire signed [31:0] c10, c11, c12, c13;
    wire signed [31:0] c20, c21, c22, c23;
    wire signed [31:0] c30, c31, c32, c33;

    wire busy;
    wire done;
    wire valid;

    tsa_systolic_4x4_core_i8 dut (
        .clk(clk),
        .reset(reset),
        .start(start),

        .a00(a00), .a01(a01), .a02(a02), .a03(a03),
        .a10(a10), .a11(a11), .a12(a12), .a13(a13),
        .a20(a20), .a21(a21), .a22(a22), .a23(a23),
        .a30(a30), .a31(a31), .a32(a32), .a33(a33),

        .b00(b00), .b01(b01), .b02(b02), .b03(b03),
        .b10(b10), .b11(b11), .b12(b12), .b13(b13),
        .b20(b20), .b21(b21), .b22(b22), .b23(b23),
        .b30(b30), .b31(b31), .b32(b32), .b33(b33),

        .c00(c00), .c01(c01), .c02(c02), .c03(c03),
        .c10(c10), .c11(c11), .c12(c12), .c13(c13),
        .c20(c20), .c21(c21), .c22(c22), .c23(c23),
        .c30(c30), .c31(c31), .c32(c32), .c33(c33),

        .busy(busy),
        .done(done),
        .valid(valid)
    );

    always begin
        #5 clk = ~clk;
    end

    initial begin
        clk = 0;
        reset = 1;
        start = 0;

        a00 = 0; a01 = 0; a02 = 0; a03 = 0;
        a10 = 0; a11 = 0; a12 = 0; a13 = 0;
        a20 = 0; a21 = 0; a22 = 0; a23 = 0;
        a30 = 0; a31 = 0; a32 = 0; a33 = 0;

        b00 = 0; b01 = 0; b02 = 0; b03 = 0;
        b10 = 0; b11 = 0; b12 = 0; b13 = 0;
        b20 = 0; b21 = 0; b22 = 0; b23 = 0;
        b30 = 0; b31 = 0; b32 = 0; b33 = 0;

        #10;
        reset = 0;

        a00 = 8'sd7;
        a01 = 8'sd8;
        a02 = -8'sd7;
        a03 = -8'sd2;
        a10 = 8'sd4;
        a11 = 8'sd5;
        a12 = -8'sd6;
        a13 = -8'sd3;
        a20 = 8'sd1;
        a21 = 8'sd5;
        a22 = -8'sd7;
        a23 = 8'sd2;
        a30 = -8'sd3;
        a31 = -8'sd5;
        a32 = 8'sd0;
        a33 = -8'sd1;

        b00 = 8'sd2;
        b01 = -8'sd3;
        b02 = 8'sd5;
        b03 = -8'sd7;
        b10 = 8'sd6;
        b11 = -8'sd8;
        b12 = 8'sd4;
        b13 = -8'sd3;
        b20 = -8'sd2;
        b21 = -8'sd8;
        b22 = 8'sd3;
        b23 = -8'sd6;
        b30 = 8'sd3;
        b31 = 8'sd4;
        b32 = 8'sd6;
        b33 = 8'sd4;

        #10;
        start = 1;
        #10;
        start = 0;

        wait(valid == 1'b1);
        #1;

        if (
            c00 == 32'sd70 &&
            c01 == -32'sd37 &&
            c02 == 32'sd34 &&
            c03 == -32'sd39 &&
            c10 == 32'sd41 &&
            c11 == -32'sd16 &&
            c12 == 32'sd4 &&
            c13 == -32'sd19 &&
            c20 == 32'sd52 &&
            c21 == 32'sd21 &&
            c22 == 32'sd16 &&
            c23 == 32'sd28 &&
            c30 == -32'sd39 &&
            c31 == 32'sd45 &&
            c32 == -32'sd41 &&
            c33 == 32'sd32 &&
            valid == 1'b1
        ) begin
            $display("RANDOM TEST 49: PASS");
        end else begin
            $display("RANDOM TEST 49: FAIL");

            $display("Output:");
            $display("%d %d %d %d", c00, c01, c02, c03);
            $display("%d %d %d %d", c10, c11, c12, c13);
            $display("%d %d %d %d", c20, c21, c22, c23);
            $display("%d %d %d %d", c30, c31, c32, c33);

            $display("Expected:");
            $display("70 -37 34 -39");
            $display("41 -16 4 -19");
            $display("52 21 16 28");
            $display("-39 45 -41 32");
        end

        #20;
        $finish;
    end

endmodule
