`timescale 1ns/1ps

module tsa_systolic_2x2_tb;

    reg clk;
    reg reset;
    reg enable;
    reg clear;

    reg [7:0] a0_in;
    reg [7:0] a1_in;
    reg [7:0] b0_in;
    reg [7:0] b1_in;

    wire [31:0] c00;
    wire [31:0] c01;
    wire [31:0] c10;
    wire [31:0] c11;

    tsa_systolic_2x2 dut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .clear(clear),

        .a0_in(a0_in),
        .a1_in(a1_in),
        .b0_in(b0_in),
        .b1_in(b1_in),

        .c00(c00),
        .c01(c01),
        .c10(c10),
        .c11(c11)
    );

    always begin
        #5 clk = ~clk;
    end

    task print_state;
        input [127:0] label;
        begin
            $display("%s: c00=%d c01=%d c10=%d c11=%d", label, c00, c01, c10, c11);
        end
    endtask

    initial begin
        $dumpfile("waves/tsa_systolic_2x2.vcd");
        $dumpvars(0, tsa_systolic_2x2_tb);

        clk = 0;
        reset = 1;
        enable = 0;
        clear = 0;

        a0_in = 0;
        a1_in = 0;
        b0_in = 0;
        b1_in = 0;

        #10;
        reset = 0;

        $display("TSA-1 SYSTOLIC 2x2 MATRIX MULTIPLY test started");

        clear = 1;
        #10;
        clear = 0;

        enable = 1;

        // Matrix A:
        // | 1 2 |
        // | 3 4 |
        //
        // Matrix B:
        // | 5 6 |
        // | 7 8 |
        //
        // Expected C = A x B:
        // | 19 22 |
        // | 43 50 |

        // Cycle 1
        // Feed a00 and b00.
        // Other lanes receive zeros because of systolic alignment.
        a0_in = 8'd1;
        a1_in = 8'd0;
        b0_in = 8'd5;
        b1_in = 8'd0;
        #10;
        print_state("Cycle 1");

        // Cycle 2
        // Feed a01, a10, b10, b01.
        a0_in = 8'd2;
        a1_in = 8'd3;
        b0_in = 8'd7;
        b1_in = 8'd6;
        #10;
        print_state("Cycle 2");

        // Cycle 3
        // Feed a11 and b11.
        // Other lanes flush zeros.
        a0_in = 8'd0;
        a1_in = 8'd4;
        b0_in = 8'd0;
        b1_in = 8'd8;
        #10;
        print_state("Cycle 3");

        // Cycle 4
        // Flush final data through bottom-right PE.
        a0_in = 8'd0;
        a1_in = 8'd0;
        b0_in = 8'd0;
        b1_in = 8'd0;
        #10;
        print_state("Cycle 4");

        enable = 0;

        $display("Final:");
        $display("c00=%d | expected 19", c00);
        $display("c01=%d | expected 22", c01);
        $display("c10=%d | expected 43", c10);
        $display("c11=%d | expected 50", c11);

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
