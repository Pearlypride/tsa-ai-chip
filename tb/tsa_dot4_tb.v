`timescale 1ns/1ps

module tsa_dot4_tb;

    reg clk;
    reg reset;
    reg enable;

    reg [7:0] a0, a1, a2, a3;
    reg [7:0] b0, b1, b2, b3;

    wire [31:0] result;

    tsa_dot4 dut (
        .clk(clk),
        .reset(reset),
        .enable(enable),

        .a0(a0),
        .a1(a1),
        .a2(a2),
        .a3(a3),

        .b0(b0),
        .b1(b1),
        .b2(b2),
        .b3(b3),

        .result(result)
    );

    always begin
        #5 clk = ~clk;
    end

    initial begin
        $dumpfile("waves/tsa_dot4.vcd");
        $dumpvars(0, tsa_dot4_tb);

        clk = 0;
        reset = 1;
        enable = 0;

        a0 = 0; a1 = 0; a2 = 0; a3 = 0;
        b0 = 0; b1 = 0; b2 = 0; b3 = 0;

        #10;
        reset = 0;
        enable = 1;

        $display("TSA-1 DOT4 test started");

        a0 = 8'd1;
        a1 = 8'd2;
        a2 = 8'd3;
        a3 = 8'd4;

        b0 = 8'd10;
        b1 = 8'd20;
        b2 = 8'd30;
        b3 = 8'd40;

        #10;

        $display("DOT4 result = %d", result);
        $display("Expected    = 300");

        if (result == 32'd300) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end

        #10;
        $finish;
    end

endmodule
