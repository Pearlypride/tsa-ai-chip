`timescale 1ns/1ps

module tsa_mat2x2_tb;

    reg clk;
    reg reset;
    reg enable;

    reg [7:0] a00, a01, a10, a11;
    reg [7:0] b00, b01, b10, b11;

    wire [31:0] c00, c01, c10, c11;

    tsa_mat2x2 dut (
        .clk(clk),
        .reset(reset),
        .enable(enable),

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
        .c11(c11)
    );

    always begin
        #5 clk = ~clk;
    end

    initial begin
        $dumpfile("waves/tsa_mat2x2.vcd");
        $dumpvars(0, tsa_mat2x2_tb);

        clk = 0;
        reset = 1;
        enable = 0;

        a00 = 0; a01 = 0; a10 = 0; a11 = 0;
        b00 = 0; b01 = 0; b10 = 0; b11 = 0;

        #10;
        reset = 0;
        enable = 1;

        $display("TSA-1 MAT2x2 test started");

        // A = [ [1, 2],
        //       [3, 4] ]
        a00 = 8'd1;
        a01 = 8'd2;
        a10 = 8'd3;
        a11 = 8'd4;

        // B = [ [5, 6],
        //       [7, 8] ]
        b00 = 8'd5;
        b01 = 8'd6;
        b10 = 8'd7;
        b11 = 8'd8;

        #10;

        $display("C00 = %d | Expected 19", c00);
        $display("C01 = %d | Expected 22", c01);
        $display("C10 = %d | Expected 43", c10);
        $display("C11 = %d | Expected 50", c11);

        if (
            c00 == 32'd19 &&
            c01 == 32'd22 &&
            c10 == 32'd43 &&
            c11 == 32'd50
        ) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end

        #10;
        $finish;
    end

endmodule
