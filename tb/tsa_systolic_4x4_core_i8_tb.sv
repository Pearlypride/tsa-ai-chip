`timescale 1ns/1ps

module tsa_systolic_4x4_core_i8_tb;

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

    integer csv_fd;

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

    task write_csv_row;
        begin
            $fwrite(csv_fd, "%0t", $time);

            $fwrite(csv_fd, ",%0d", reset);
            $fwrite(csv_fd, ",%0d", start);
            $fwrite(csv_fd, ",%0d", busy);
            $fwrite(csv_fd, ",%0d", done);
            $fwrite(csv_fd, ",%0d", valid);
            $fwrite(csv_fd, ",%0d", dut.cycle);

            $fwrite(csv_fd, ",%0d", c00);
            $fwrite(csv_fd, ",%0d", c01);
            $fwrite(csv_fd, ",%0d", c02);
            $fwrite(csv_fd, ",%0d", c03);

            $fwrite(csv_fd, ",%0d", c10);
            $fwrite(csv_fd, ",%0d", c11);
            $fwrite(csv_fd, ",%0d", c12);
            $fwrite(csv_fd, ",%0d", c13);

            $fwrite(csv_fd, ",%0d", c20);
            $fwrite(csv_fd, ",%0d", c21);
            $fwrite(csv_fd, ",%0d", c22);
            $fwrite(csv_fd, ",%0d", c23);

            $fwrite(csv_fd, ",%0d", c30);
            $fwrite(csv_fd, ",%0d", c31);
            $fwrite(csv_fd, ",%0d", c32);
            $fwrite(csv_fd, ",%0d", c33);

            $fwrite(csv_fd, ",%0d", dut.enable);
            $fwrite(csv_fd, ",%0d", dut.clear);
            $fwrite(csv_fd, ",%0d", dut.state);

            $fwrite(csv_fd, "\n");
        end
    endtask

    always @(posedge clk) begin
        if (csv_fd != 0) begin
            write_csv_row();
        end
    end

    initial begin
        $dumpfile("waves/tsa_systolic_4x4_core_i8.vcd");
        $dumpvars(0, tsa_systolic_4x4_core_i8_tb);

        csv_fd = $fopen("reports/tsa_4x4_timeline.csv", "w");
        $fwrite(csv_fd, "time_ps,reset,start,busy,done,valid,cycle,c00,c01,c02,c03,c10,c11,c12,c13,c20,c21,c22,c23,c30,c31,c32,c33,enable,clear,state\n");

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

        $display("TSA-1 SYSTOLIC 4x4 INT8 CORE test started");

        a00 = 8'sd1;   a01 = -8'sd2;  a02 = 8'sd3;   a03 = 8'sd4;
        a10 = 8'sd5;   a11 = 8'sd6;   a12 = -8'sd7;  a13 = 8'sd8;
        a20 = -8'sd1;  a21 = 8'sd2;   a22 = 8'sd3;   a23 = -8'sd4;
        a30 = 8'sd9;   a31 = -8'sd8;  a32 = 8'sd7;   a33 = 8'sd6;

        b00 = 8'sd1;   b01 = 8'sd2;    b02 = -8'sd3;   b03 = 8'sd4;
        b10 = -8'sd5;  b11 = 8'sd6;    b12 = 8'sd7;    b13 = -8'sd8;
        b20 = 8'sd9;   b21 = -8'sd10;  b22 = 8'sd11;   b23 = 8'sd12;
        b30 = 8'sd13;  b31 = 8'sd14;   b32 = -8'sd15;  b33 = 8'sd16;

        #10;
        start = 1;
        #10;
        start = 0;

        wait(valid == 1'b1);

        #1;

        $display("Output C:");
        $display("%d %d %d %d", c00, c01, c02, c03);
        $display("%d %d %d %d", c10, c11, c12, c13);
        $display("%d %d %d %d", c20, c21, c22, c23);
        $display("%d %d %d %d", c30, c31, c32, c33);

        $display("Expected:");
        $display("90 16 -44 120");
        $display("16 228 -170 16");
        $display("-36 -76 110 -48");
        $display("190 -16 -96 280");

        if (
            c00 == 32'sd90   && c01 == 32'sd16   && c02 == -32'sd44   && c03 == 32'sd120 &&
            c10 == 32'sd16   && c11 == 32'sd228  && c12 == -32'sd170  && c13 == 32'sd16  &&
            c20 == -32'sd36  && c21 == -32'sd76  && c22 == 32'sd110   && c23 == -32'sd48 &&
            c30 == 32'sd190  && c31 == -32'sd16  && c32 == -32'sd96   && c33 == 32'sd280 &&
            valid == 1'b1
        ) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end

        #20;
        write_csv_row();
        $fclose(csv_fd);
        $finish;
    end

endmodule
