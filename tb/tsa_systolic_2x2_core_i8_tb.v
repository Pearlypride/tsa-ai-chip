`timescale 1ns/1ps

module tsa_systolic_2x2_core_i8_tb;

    reg clk;
    reg reset;
    reg start;

    reg signed [7:0] a00;
    reg signed [7:0] a01;
    reg signed [7:0] a10;
    reg signed [7:0] a11;

    reg signed [7:0] b00;
    reg signed [7:0] b01;
    reg signed [7:0] b10;
    reg signed [7:0] b11;

    wire signed [31:0] c00;
    wire signed [31:0] c01;
    wire signed [31:0] c10;
    wire signed [31:0] c11;

    wire busy;
    wire done;
    wire valid;

    tsa_systolic_2x2_core_i8 dut (
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

        .c00(c00),
        .c01(c01),
        .c10(c10),
        .c11(c11),

        .busy(busy),
        .done(done),
        .valid(valid)
    );

    always begin
        #5 clk = ~clk;
    end

    initial begin
        $dumpfile("waves/tsa_systolic_2x2_core_i8.vcd");
        $dumpvars(0, tsa_systolic_2x2_core_i8_tb);

        clk = 0;
        reset = 1;
        start = 0;

        a00 = 0; a01 = 0; a10 = 0; a11 = 0;
        b00 = 0; b01 = 0; b10 = 0; b11 = 0;

        #10;
        reset = 0;

        $display("TSA-1 SIGNED INT8 SYSTOLIC 2x2 CORE test started");

        // A = |  1  -2 |
        //     |  3   4 |
        a00 = 8'sd1;
        a01 = -8'sd2;
        a10 = 8'sd3;
        a11 = 8'sd4;

        // B = |  5   6 |
        //     | -7   8 |
        b00 = 8'sd5;
        b01 = 8'sd6;
        b10 = -8'sd7;
        b11 = 8'sd8;

        #10;
        start = 1;
        #10;
        start = 0;

        wait(valid == 1'b1);

        #1;

        $display("busy  = %b", busy);
        $display("done  = %b", done);
        $display("valid = %b", valid);

        $display("c00=%d | expected 19", c00);
        $display("c01=%d | expected -10", c01);
        $display("c10=%d | expected -13", c10);
        $display("c11=%d | expected 50", c11);

        if (
            c00 == 32'sd19 &&
            c01 == -32'sd10 &&
            c10 == -32'sd13 &&
            c11 == 32'sd50 &&
            valid == 1'b1
        ) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end

        #20;
        $finish;
    end

endmodule
