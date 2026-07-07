`timescale 1ns/1ps

module tsa_pe_tb;

    reg clk;
    reg reset;
    reg enable;
    reg clear;

    reg [7:0] a_in;
    reg [7:0] b_in;

    wire [7:0] a_out;
    wire [7:0] b_out;
    wire [31:0] acc;

    tsa_pe dut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .clear(clear),
        .a_in(a_in),
        .b_in(b_in),
        .a_out(a_out),
        .b_out(b_out),
        .acc(acc)
    );

    always begin
        #5 clk = ~clk;
    end

    initial begin
        $dumpfile("waves/tsa_pe.vcd");
        $dumpvars(0, tsa_pe_tb);

        clk = 0;
        reset = 1;
        enable = 0;
        clear = 0;
        a_in = 0;
        b_in = 0;

        #10;
        reset = 0;

        $display("TSA-1 PE test started");

        enable = 1;

        a_in = 8'd2;
        b_in = 8'd3;
        #10;
        $display("Step 1: acc=%d | expected 6", acc);

        a_in = 8'd4;
        b_in = 8'd5;
        #10;
        $display("Step 2: acc=%d | expected 26", acc);

        a_in = 8'd1;
        b_in = 8'd10;
        #10;
        $display("Step 3: acc=%d | expected 36", acc);

        if (acc == 32'd36 && a_out == 8'd1 && b_out == 8'd10) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end

        #10;
        $finish;
    end

endmodule
