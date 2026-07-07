`timescale 1ns/1ps

module tsa_axi_lite_top_i8_tb;

    reg ACLK;
    reg ARESETN;

    reg  [31:0] S_AXI_AWADDR;
    reg         S_AXI_AWVALID;
    wire        S_AXI_AWREADY;

    reg  [31:0] S_AXI_WDATA;
    reg  [3:0]  S_AXI_WSTRB;
    reg         S_AXI_WVALID;
    wire        S_AXI_WREADY;

    wire [1:0]  S_AXI_BRESP;
    wire        S_AXI_BVALID;
    reg         S_AXI_BREADY;

    reg  [31:0] S_AXI_ARADDR;
    reg         S_AXI_ARVALID;
    wire        S_AXI_ARREADY;

    wire [31:0] S_AXI_RDATA;
    wire [1:0]  S_AXI_RRESP;
    wire        S_AXI_RVALID;
    reg         S_AXI_RREADY;

    wire irq;

    reg signed [31:0] rdata;
    reg signed [31:0] c [0:15];

    integer csv_fd;

    tsa_axi_lite_top_i8 dut (
        .ACLK(ACLK),
        .ARESETN(ARESETN),

        .S_AXI_AWADDR(S_AXI_AWADDR),
        .S_AXI_AWVALID(S_AXI_AWVALID),
        .S_AXI_AWREADY(S_AXI_AWREADY),

        .S_AXI_WDATA(S_AXI_WDATA),
        .S_AXI_WSTRB(S_AXI_WSTRB),
        .S_AXI_WVALID(S_AXI_WVALID),
        .S_AXI_WREADY(S_AXI_WREADY),

        .S_AXI_BRESP(S_AXI_BRESP),
        .S_AXI_BVALID(S_AXI_BVALID),
        .S_AXI_BREADY(S_AXI_BREADY),

        .S_AXI_ARADDR(S_AXI_ARADDR),
        .S_AXI_ARVALID(S_AXI_ARVALID),
        .S_AXI_ARREADY(S_AXI_ARREADY),

        .S_AXI_RDATA(S_AXI_RDATA),
        .S_AXI_RRESP(S_AXI_RRESP),
        .S_AXI_RVALID(S_AXI_RVALID),
        .S_AXI_RREADY(S_AXI_RREADY),

        .irq(irq)
    );

    always begin
        #5 ACLK = ~ACLK;
    end

    task axi_write;
        input [31:0] addr;
        input [31:0] data;
        begin
            @(posedge ACLK);

            S_AXI_AWADDR  <= addr;
            S_AXI_AWVALID <= 1'b1;

            S_AXI_WDATA   <= data;
            S_AXI_WSTRB   <= 4'hF;
            S_AXI_WVALID  <= 1'b1;

            S_AXI_BREADY  <= 1'b1;

            wait(S_AXI_AWREADY && S_AXI_WREADY);

            @(posedge ACLK);
            S_AXI_AWVALID <= 1'b0;
            S_AXI_WVALID  <= 1'b0;

            wait(S_AXI_BVALID);

            @(posedge ACLK);
            S_AXI_BREADY <= 1'b0;
        end
    endtask

    task axi_read;
        input  [31:0] addr;
        output signed [31:0] data;
        begin
            @(posedge ACLK);

            S_AXI_ARADDR  <= addr;
            S_AXI_ARVALID <= 1'b1;
            S_AXI_RREADY  <= 1'b1;

            wait(S_AXI_ARREADY);

            @(posedge ACLK);
            S_AXI_ARVALID <= 1'b0;

            wait(S_AXI_RVALID);

            #1;
            data = S_AXI_RDATA;

            @(posedge ACLK);
            S_AXI_RREADY <= 1'b0;
        end
    endtask

    task log_csv;
        begin
            $fwrite(csv_fd, "%0t,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d\n",
                $time,
                ARESETN,
                S_AXI_AWVALID,
                S_AXI_AWREADY,
                S_AXI_WVALID,
                S_AXI_WREADY,
                S_AXI_BVALID,
                S_AXI_ARVALID,
                S_AXI_ARREADY,
                S_AXI_RVALID,
                irq,
                dut.core_busy,
                dut.done_latched,
                dut.valid_latched,
                dut.core.cycle,
                dut.start_pulse
            );
        end
    endtask

    always @(posedge ACLK) begin
        if (csv_fd != 0) begin
            log_csv();
        end
    end

    initial begin
        $dumpfile("waves/tsa_axi_lite_top_i8.vcd");
        $dumpvars(0, tsa_axi_lite_top_i8_tb);

        csv_fd = $fopen("reports/tsa_axi_lite_timeline.csv", "w");
        $fwrite(csv_fd, "time_ps,ARESETN,AWVALID,AWREADY,WVALID,WREADY,BVALID,ARVALID,ARREADY,RVALID,irq,core_busy,done_latched,valid_latched,cycle,start_pulse\n");

        ACLK = 0;
        ARESETN = 0;

        S_AXI_AWADDR = 0;
        S_AXI_AWVALID = 0;
        S_AXI_WDATA = 0;
        S_AXI_WSTRB = 4'hF;
        S_AXI_WVALID = 0;
        S_AXI_BREADY = 0;

        S_AXI_ARADDR = 0;
        S_AXI_ARVALID = 0;
        S_AXI_RREADY = 0;

        #50;
        ARESETN = 1;

        $display("TSA-1 AXI-LITE TOP test started");

        // A base = 0x40, each element spaced by 4 bytes
        axi_write(32'h40, 32'sd1);
        axi_write(32'h44, -32'sd2);
        axi_write(32'h48, 32'sd3);
        axi_write(32'h4C, 32'sd4);

        axi_write(32'h50, 32'sd5);
        axi_write(32'h54, 32'sd6);
        axi_write(32'h58, -32'sd7);
        axi_write(32'h5C, 32'sd8);

        axi_write(32'h60, -32'sd1);
        axi_write(32'h64, 32'sd2);
        axi_write(32'h68, 32'sd3);
        axi_write(32'h6C, -32'sd4);

        axi_write(32'h70, 32'sd9);
        axi_write(32'h74, -32'sd8);
        axi_write(32'h78, 32'sd7);
        axi_write(32'h7C, 32'sd6);

        // B base = 0x80
        axi_write(32'h80, 32'sd1);
        axi_write(32'h84, 32'sd2);
        axi_write(32'h88, -32'sd3);
        axi_write(32'h8C, 32'sd4);

        axi_write(32'h90, -32'sd5);
        axi_write(32'h94, 32'sd6);
        axi_write(32'h98, 32'sd7);
        axi_write(32'h9C, -32'sd8);

        axi_write(32'hA0, 32'sd9);
        axi_write(32'hA4, -32'sd10);
        axi_write(32'hA8, 32'sd11);
        axi_write(32'hAC, 32'sd12);

        axi_write(32'hB0, 32'sd13);
        axi_write(32'hB4, 32'sd14);
        axi_write(32'hB8, -32'sd15);
        axi_write(32'hBC, 32'sd16);

        // CTRL.start = 1
        axi_write(32'h00, 32'd1);

        // Poll STATUS bit1 = done_latched
        rdata = 0;
        while (rdata[1] == 1'b0) begin
            axi_read(32'h04, rdata);
        end

        $display("STATUS = %b", rdata[3:0]);

        axi_read(32'hC0, c[0]);
        axi_read(32'hC4, c[1]);
        axi_read(32'hC8, c[2]);
        axi_read(32'hCC, c[3]);

        axi_read(32'hD0, c[4]);
        axi_read(32'hD4, c[5]);
        axi_read(32'hD8, c[6]);
        axi_read(32'hDC, c[7]);

        axi_read(32'hE0, c[8]);
        axi_read(32'hE4, c[9]);
        axi_read(32'hE8, c[10]);
        axi_read(32'hEC, c[11]);

        axi_read(32'hF0, c[12]);
        axi_read(32'hF4, c[13]);
        axi_read(32'hF8, c[14]);
        axi_read(32'hFC, c[15]);

        $display("Read C through AXI-Lite:");
        $display("%d %d %d %d", c[0], c[1], c[2], c[3]);
        $display("%d %d %d %d", c[4], c[5], c[6], c[7]);
        $display("%d %d %d %d", c[8], c[9], c[10], c[11]);
        $display("%d %d %d %d", c[12], c[13], c[14], c[15]);

        if (
            c[0]  == 32'sd90   && c[1]  == 32'sd16   && c[2]  == -32'sd44   && c[3]  == 32'sd120 &&
            c[4]  == 32'sd16   && c[5]  == 32'sd228  && c[6]  == -32'sd170  && c[7]  == 32'sd16  &&
            c[8]  == -32'sd36  && c[9]  == -32'sd76  && c[10] == 32'sd110   && c[11] == -32'sd48 &&
            c[12] == 32'sd190  && c[13] == -32'sd16  && c[14] == -32'sd96   && c[15] == 32'sd280 &&
            rdata[1] == 1'b1 &&
            irq == 1'b1
        ) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end

        // Clear done via W1C CTRL bit1
        axi_write(32'h00, 32'd2);
        axi_read(32'h04, rdata);
        $display("STATUS after clear = %b", rdata[3:0]);

        #50;
        $fclose(csv_fd);
        csv_fd = 0;
        $finish;
    end

endmodule
