`timescale 1ns/1ps

module tsa_fpga_top_mem_i8_tb;

    reg clk;
    reg reset;

    reg        bus_valid;
    reg        bus_we;
    reg [7:0]  bus_addr;
    reg [31:0] bus_wdata;

    wire [31:0] bus_rdata;
    wire        bus_ready;
    wire        irq_valid;

    integer csv_fd;

    reg signed [31:0] rdata;
    reg signed [31:0] c [0:15];

    tsa_fpga_top_mem_i8 dut (
        .clk(clk),
        .reset(reset),

        .bus_valid(bus_valid),
        .bus_we(bus_we),
        .bus_addr(bus_addr),
        .bus_wdata(bus_wdata),

        .bus_rdata(bus_rdata),
        .bus_ready(bus_ready),

        .irq_valid(irq_valid)
    );

    always begin
        #5 clk = ~clk;
    end

    task mmio_write;
        input [7:0] addr;
        input [31:0] data;
        begin
            @(posedge clk);
            bus_addr  <= addr;
            bus_wdata <= data;
            bus_we    <= 1'b1;
            bus_valid <= 1'b1;

            @(posedge clk);
            bus_valid <= 1'b0;
            bus_we    <= 1'b0;
            bus_addr  <= 8'd0;
            bus_wdata <= 32'd0;
        end
    endtask

    task mmio_read;
        input  [7:0] addr;
        output signed [31:0] data;
        begin
            @(posedge clk);
            bus_addr  <= addr;
            bus_we    <= 1'b0;
            bus_valid <= 1'b1;

            @(posedge clk);
            #1;
            data = bus_rdata;

            bus_valid <= 1'b0;
            bus_addr  <= 8'd0;
        end
    endtask

    task log_csv;
        begin
            $fwrite(csv_fd, "%0t,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d\n",
                $time,
                reset,
                bus_valid,
                bus_we,
                bus_addr,
                bus_wdata,
                bus_rdata,
                irq_valid,
                dut.core_busy,
                dut.done_latched,
                dut.core_valid,
                dut.start_pulse,
                dut.core.cycle,
                dut.core.enable,
                dut.core.clear
            );
        end
    endtask

    always @(posedge clk) begin
        if (csv_fd != 0) begin
            log_csv();
        end
    end

    initial begin
        $dumpfile("waves/tsa_fpga_top_mem_i8.vcd");
        $dumpvars(0, tsa_fpga_top_mem_i8_tb);

        csv_fd = $fopen("reports/tsa_fpga_mem_timeline.csv", "w");
        $fwrite(csv_fd, "time_ps,reset,bus_valid,bus_we,bus_addr,bus_wdata,bus_rdata,irq_valid,core_busy,done_latched,core_valid,start_pulse,cycle,enable,clear\n");

        clk = 0;
        reset = 1;

        bus_valid = 0;
        bus_we = 0;
        bus_addr = 0;
        bus_wdata = 0;

        #20;
        reset = 0;

        $display("TSA-1 FPGA MEMORY TOP test started");

        // Write A buffer: 0x10..0x1F
        mmio_write(8'h10, 32'sd1);
        mmio_write(8'h11, -32'sd2);
        mmio_write(8'h12, 32'sd3);
        mmio_write(8'h13, 32'sd4);

        mmio_write(8'h14, 32'sd5);
        mmio_write(8'h15, 32'sd6);
        mmio_write(8'h16, -32'sd7);
        mmio_write(8'h17, 32'sd8);

        mmio_write(8'h18, -32'sd1);
        mmio_write(8'h19, 32'sd2);
        mmio_write(8'h1A, 32'sd3);
        mmio_write(8'h1B, -32'sd4);

        mmio_write(8'h1C, 32'sd9);
        mmio_write(8'h1D, -32'sd8);
        mmio_write(8'h1E, 32'sd7);
        mmio_write(8'h1F, 32'sd6);

        // Write B buffer: 0x20..0x2F
        mmio_write(8'h20, 32'sd1);
        mmio_write(8'h21, 32'sd2);
        mmio_write(8'h22, -32'sd3);
        mmio_write(8'h23, 32'sd4);

        mmio_write(8'h24, -32'sd5);
        mmio_write(8'h25, 32'sd6);
        mmio_write(8'h26, 32'sd7);
        mmio_write(8'h27, -32'sd8);

        mmio_write(8'h28, 32'sd9);
        mmio_write(8'h29, -32'sd10);
        mmio_write(8'h2A, 32'sd11);
        mmio_write(8'h2B, 32'sd12);

        mmio_write(8'h2C, 32'sd13);
        mmio_write(8'h2D, 32'sd14);
        mmio_write(8'h2E, -32'sd15);
        mmio_write(8'h2F, 32'sd16);

        // Start compute
        mmio_write(8'h00, 32'd1);

        // Poll STATUS until done_latched bit 1 = 1
        // STATUS:
        // bit0 = busy
        // bit1 = done_latched
        // bit2 = valid_latched
        // bit3 = irq
        rdata = 0;
        while (rdata[1] == 1'b0) begin
            mmio_read(8'h01, rdata);
        end

        $display("STATUS = %b", rdata[3:0]);

        if (rdata[1] != 1'b1) begin
            $display("STATUS TEST FAILED: done_latched is not set");
        end

        if (rdata[3] != 1'b1) begin
            $display("STATUS TEST FAILED: irq is not set");
        end

        // Read C buffer: 0x30..0x3F
        mmio_read(8'h30, c[0]);
        mmio_read(8'h31, c[1]);
        mmio_read(8'h32, c[2]);
        mmio_read(8'h33, c[3]);

        mmio_read(8'h34, c[4]);
        mmio_read(8'h35, c[5]);
        mmio_read(8'h36, c[6]);
        mmio_read(8'h37, c[7]);

        mmio_read(8'h38, c[8]);
        mmio_read(8'h39, c[9]);
        mmio_read(8'h3A, c[10]);
        mmio_read(8'h3B, c[11]);

        mmio_read(8'h3C, c[12]);
        mmio_read(8'h3D, c[13]);
        mmio_read(8'h3E, c[14]);
        mmio_read(8'h3F, c[15]);

        $display("Read C from local C memory:");
        $display("%d %d %d %d", c[0], c[1], c[2], c[3]);
        $display("%d %d %d %d", c[4], c[5], c[6], c[7]);
        $display("%d %d %d %d", c[8], c[9], c[10], c[11]);
        $display("%d %d %d %d", c[12], c[13], c[14], c[15]);

        if (
            c[0]  == 32'sd90   && c[1]  == 32'sd16   && c[2]  == -32'sd44   && c[3]  == 32'sd120 &&
            c[4]  == 32'sd16   && c[5]  == 32'sd228  && c[6]  == -32'sd170  && c[7]  == 32'sd16  &&
            c[8]  == -32'sd36  && c[9]  == -32'sd76  && c[10] == 32'sd110   && c[11] == -32'sd48 &&
            c[12] == 32'sd190  && c[13] == -32'sd16  && c[14] == -32'sd96   && c[15] == 32'sd280
        ) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end

        #50;
        $fclose(csv_fd);
        $finish;
    end

endmodule
