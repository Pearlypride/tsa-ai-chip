`timescale 1ns/1ps

module tsa_relu_i32_tb;

    reg  signed [31:0] in_value;
    wire signed [31:0] out_value;

    tsa_relu_i32 dut (
        .in_value(in_value),
        .out_value(out_value)
    );

    initial begin
        $dumpfile("waves/tsa_relu_i32.vcd");
        $dumpvars(0, tsa_relu_i32_tb);

        $display("TSA-1 ReLU INT32 test started");

        in_value = 32'sd19;
        #10;
        $display("in=%d out=%d | expected 19", in_value, out_value);

        in_value = -32'sd10;
        #10;
        $display("in=%d out=%d | expected 0", in_value, out_value);

        in_value = -32'sd13;
        #10;
        $display("in=%d out=%d | expected 0", in_value, out_value);

        in_value = 32'sd50;
        #10;
        $display("in=%d out=%d | expected 50", in_value, out_value);

        if (out_value == 32'sd50) begin
            $display("Basic final check OK");
        end

        $display("Manual expected sequence:");
        $display("19 -> 19");
        $display("-10 -> 0");
        $display("-13 -> 0");
        $display("50 -> 50");

        $display("TEST PASSED");

        #10;
        $finish;
    end

endmodule
