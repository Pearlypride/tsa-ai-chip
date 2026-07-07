`timescale 1ns/1ps

module tsa_ai_layer_2x2_i8_tb;

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

    wire signed [31:0] raw_c00;
    wire signed [31:0] raw_c01;
    wire signed [31:0] raw_c10;
    wire signed [31:0] raw_c11;

    wire signed [31:0] act_c00;
    wire signed [31:0] act_c01;
    wire signed [31:0] act_c10;
    wire signed [31:0] act_c11;

    wire busy;
    wire done;
    wire valid;

    tsa_ai_layer_2x2_i8 dut (
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

        .raw_c00(raw_c00),
        .raw_c01(raw_c01),
        .raw_c10(raw_c10),
        .raw_c11(raw_c11),

        .act_c00(act_c00),
        .act_c01(act_c01),
        .act_c10(act_c10),
        .act_c11(act_c11),

        .busy(busy),
        .done(done),
        .valid(valid)
    );

    always begin
        #5 clk = ~clk;
    end

    initial begin
        $dumpfile("waves/tsa_ai_layer_2x2_i8.vcd");
        $dumpvars(0, tsa_ai_layer_2x2_i8_tb);

        clk = 0;
        reset = 1;
        start = 0;

        a00 = 0; a01 = 0; a10 = 0; a11 = 0;
        b00 = 0; b01 = 0; b10 = 0; b11 = 0;

        #10;
        reset = 0;

        $display("TSA-1 AI LAYER 2x2 INT8 test started");

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

        $display("Raw output:");
        $display("raw_c00=%d | expected 19", raw_c00);
        $display("raw_c01=%d | expected -10", raw_c01);
        $display("raw_c10=%d | expected -13", raw_c10);
        $display("raw_c11=%d | expected 50", raw_c11);

        $display("Activated ReLU output:");
        $display("act_c00=%d | expected 19", act_c00);
        $display("act_c01=%d | expected 0", act_c01);
        $display("act_c10=%d | expected 0", act_c10);
        $display("act_c11=%d | expected 50", act_c11);

        if (
            raw_c00 == 32'sd19 &&
            raw_c01 == -32'sd10 &&
            raw_c10 == -32'sd13 &&
            raw_c11 == 32'sd50 &&

            act_c00 == 32'sd19 &&
            act_c01 == 32'sd0 &&
            act_c10 == 32'sd0 &&
            act_c11 == 32'sd50 &&

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
