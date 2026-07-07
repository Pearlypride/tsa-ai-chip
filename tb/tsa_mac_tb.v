`timescale 1ns/1ps

module tsa_mac_tb;

    reg         clk;
    reg         reset;
    reg         enable;
    reg  [7:0]  a;
    reg  [7:0]  b;
    wire [31:0] acc;

    tsa_mac dut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .a(a),
        .b(b),
        .acc(acc)
    );

    always begin
        #5 clk = ~clk;
    end

    initial begin
        $dumpfile("waves/tsa_mac.vcd");
        $dumpvars(0, tsa_mac_tb);

        clk = 0;
        reset = 1;
        enable = 0;
        a = 0;
        b = 0;

        #10;
        reset = 0;

        $display("TSA-1 MAC test started");

        enable = 1;

        a = 8'd3;
        b = 8'd4;
        #10;
        $display("Step 1: a=%d b=%d acc=%d", a, b, acc);

        a = 8'd5;
        b = 8'd6;
        #10;
        $display("Step 2: a=%d b=%d acc=%d", a, b, acc);

        a = 8'd2;
        b = 8'd10;
        #10;
        $display("Step 3: a=%d b=%d acc=%d", a, b, acc);

        enable = 0;

        a = 8'd100;
        b = 8'd100;
        #10;
        $display("Enable off: a=%d b=%d acc=%d", a, b, acc);

        enable = 1;

        a = 8'd1;
        b = 8'd255;
        #10;
        $display("Step 4: a=%d b=%d acc=%d", a, b, acc);

        $display("Expected final acc = 317");
        $display("Actual final acc   = %d", acc);

        if (acc == 32'd317) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end

        $finish;
    end

endmodule
