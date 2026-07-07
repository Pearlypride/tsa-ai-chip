`timescale 1ns/1ps

module tsa_axi_lite_top_8x8_i8_tb;

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
    reg signed [31:0] c [0:63];

    integer i;

    tsa_axi_lite_top_8x8_i8 dut (
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

    initial begin
        $dumpfile("waves/tsa_axi_lite_top_8x8_i8.vcd");
        $dumpvars(0, tsa_axi_lite_top_8x8_i8_tb);

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

        $display("TSA-2 AXI-LITE 8x8 TOP test started");

        axi_write(32'h100, 32'sd5);
        axi_write(32'h104, 32'sd5);
        axi_write(32'h108, -32'sd6);
        axi_write(32'h10C, -32'sd6);
        axi_write(32'h110, -32'sd5);
        axi_write(32'h114, 32'sd4);
        axi_write(32'h118, -32'sd7);
        axi_write(32'h11C, 32'sd4);
        axi_write(32'h120, -32'sd6);
        axi_write(32'h124, -32'sd6);
        axi_write(32'h128, -32'sd6);
        axi_write(32'h12C, 32'sd7);
        axi_write(32'h130, -32'sd7);
        axi_write(32'h134, -32'sd6);
        axi_write(32'h138, 32'sd7);
        axi_write(32'h13C, 32'sd2);
        axi_write(32'h140, 32'sd2);
        axi_write(32'h144, 32'sd7);
        axi_write(32'h148, 32'sd2);
        axi_write(32'h14C, -32'sd5);
        axi_write(32'h150, -32'sd8);
        axi_write(32'h154, 32'sd1);
        axi_write(32'h158, 32'sd8);
        axi_write(32'h15C, 32'sd2);
        axi_write(32'h160, -32'sd3);
        axi_write(32'h164, 32'sd0);
        axi_write(32'h168, -32'sd3);
        axi_write(32'h16C, 32'sd2);
        axi_write(32'h170, -32'sd6);
        axi_write(32'h174, 32'sd0);
        axi_write(32'h178, 32'sd1);
        axi_write(32'h17C, -32'sd4);
        axi_write(32'h180, -32'sd7);
        axi_write(32'h184, -32'sd8);
        axi_write(32'h188, -32'sd7);
        axi_write(32'h18C, -32'sd5);
        axi_write(32'h190, -32'sd7);
        axi_write(32'h194, -32'sd4);
        axi_write(32'h198, 32'sd5);
        axi_write(32'h19C, 32'sd4);
        axi_write(32'h1A0, 32'sd3);
        axi_write(32'h1A4, 32'sd0);
        axi_write(32'h1A8, -32'sd4);
        axi_write(32'h1AC, -32'sd6);
        axi_write(32'h1B0, -32'sd3);
        axi_write(32'h1B4, -32'sd1);
        axi_write(32'h1B8, 32'sd4);
        axi_write(32'h1BC, -32'sd2);
        axi_write(32'h1C0, 32'sd6);
        axi_write(32'h1C4, -32'sd1);
        axi_write(32'h1C8, -32'sd8);
        axi_write(32'h1CC, 32'sd3);
        axi_write(32'h1D0, 32'sd5);
        axi_write(32'h1D4, -32'sd3);
        axi_write(32'h1D8, -32'sd2);
        axi_write(32'h1DC, -32'sd2);
        axi_write(32'h1E0, 32'sd8);
        axi_write(32'h1E4, 32'sd1);
        axi_write(32'h1E8, 32'sd0);
        axi_write(32'h1EC, -32'sd8);
        axi_write(32'h1F0, -32'sd4);
        axi_write(32'h1F4, -32'sd2);
        axi_write(32'h1F8, -32'sd3);
        axi_write(32'h1FC, 32'sd4);

        axi_write(32'h200, 32'sd8);
        axi_write(32'h204, 32'sd8);
        axi_write(32'h208, 32'sd2);
        axi_write(32'h20C, -32'sd6);
        axi_write(32'h210, -32'sd3);
        axi_write(32'h214, 32'sd1);
        axi_write(32'h218, 32'sd1);
        axi_write(32'h21C, 32'sd2);
        axi_write(32'h220, -32'sd8);
        axi_write(32'h224, 32'sd4);
        axi_write(32'h228, 32'sd7);
        axi_write(32'h22C, 32'sd8);
        axi_write(32'h230, 32'sd5);
        axi_write(32'h234, -32'sd3);
        axi_write(32'h238, -32'sd8);
        axi_write(32'h23C, -32'sd6);
        axi_write(32'h240, 32'sd7);
        axi_write(32'h244, 32'sd2);
        axi_write(32'h248, -32'sd5);
        axi_write(32'h24C, 32'sd6);
        axi_write(32'h250, 32'sd2);
        axi_write(32'h254, 32'sd8);
        axi_write(32'h258, -32'sd5);
        axi_write(32'h25C, 32'sd0);
        axi_write(32'h260, -32'sd5);
        axi_write(32'h264, -32'sd7);
        axi_write(32'h268, -32'sd7);
        axi_write(32'h26C, 32'sd8);
        axi_write(32'h270, -32'sd6);
        axi_write(32'h274, 32'sd5);
        axi_write(32'h278, 32'sd2);
        axi_write(32'h27C, 32'sd1);
        axi_write(32'h280, -32'sd1);
        axi_write(32'h284, -32'sd8);
        axi_write(32'h288, 32'sd1);
        axi_write(32'h28C, 32'sd4);
        axi_write(32'h290, -32'sd6);
        axi_write(32'h294, -32'sd5);
        axi_write(32'h298, 32'sd2);
        axi_write(32'h29C, 32'sd4);
        axi_write(32'h2A0, 32'sd7);
        axi_write(32'h2A4, 32'sd2);
        axi_write(32'h2A8, -32'sd7);
        axi_write(32'h2AC, 32'sd6);
        axi_write(32'h2B0, 32'sd2);
        axi_write(32'h2B4, -32'sd2);
        axi_write(32'h2B8, -32'sd5);
        axi_write(32'h2BC, 32'sd0);
        axi_write(32'h2C0, 32'sd4);
        axi_write(32'h2C4, 32'sd2);
        axi_write(32'h2C8, -32'sd1);
        axi_write(32'h2CC, 32'sd7);
        axi_write(32'h2D0, -32'sd6);
        axi_write(32'h2D4, 32'sd6);
        axi_write(32'h2D8, -32'sd4);
        axi_write(32'h2DC, -32'sd5);
        axi_write(32'h2E0, 32'sd3);
        axi_write(32'h2E4, 32'sd4);
        axi_write(32'h2E8, -32'sd6);
        axi_write(32'h2EC, -32'sd4);
        axi_write(32'h2F0, -32'sd1);
        axi_write(32'h2F4, 32'sd6);
        axi_write(32'h2F8, -32'sd5);
        axi_write(32'h2FC, 32'sd7);

        axi_write(32'h000, 32'd1);

        rdata = 0;
        while (rdata[1] == 1'b0) begin
            axi_read(32'h004, rdata);
        end

        $display("STATUS = %b", rdata[3:0]);

        axi_read(32'h300, c[0]);
        axi_read(32'h304, c[1]);
        axi_read(32'h308, c[2]);
        axi_read(32'h30C, c[3]);
        axi_read(32'h310, c[4]);
        axi_read(32'h314, c[5]);
        axi_read(32'h318, c[6]);
        axi_read(32'h31C, c[7]);
        axi_read(32'h320, c[8]);
        axi_read(32'h324, c[9]);
        axi_read(32'h328, c[10]);
        axi_read(32'h32C, c[11]);
        axi_read(32'h330, c[12]);
        axi_read(32'h334, c[13]);
        axi_read(32'h338, c[14]);
        axi_read(32'h33C, c[15]);
        axi_read(32'h340, c[16]);
        axi_read(32'h344, c[17]);
        axi_read(32'h348, c[18]);
        axi_read(32'h34C, c[19]);
        axi_read(32'h350, c[20]);
        axi_read(32'h354, c[21]);
        axi_read(32'h358, c[22]);
        axi_read(32'h35C, c[23]);
        axi_read(32'h360, c[24]);
        axi_read(32'h364, c[25]);
        axi_read(32'h368, c[26]);
        axi_read(32'h36C, c[27]);
        axi_read(32'h370, c[28]);
        axi_read(32'h374, c[29]);
        axi_read(32'h378, c[30]);
        axi_read(32'h37C, c[31]);
        axi_read(32'h380, c[32]);
        axi_read(32'h384, c[33]);
        axi_read(32'h388, c[34]);
        axi_read(32'h38C, c[35]);
        axi_read(32'h390, c[36]);
        axi_read(32'h394, c[37]);
        axi_read(32'h398, c[38]);
        axi_read(32'h39C, c[39]);
        axi_read(32'h3A0, c[40]);
        axi_read(32'h3A4, c[41]);
        axi_read(32'h3A8, c[42]);
        axi_read(32'h3AC, c[43]);
        axi_read(32'h3B0, c[44]);
        axi_read(32'h3B4, c[45]);
        axi_read(32'h3B8, c[46]);
        axi_read(32'h3BC, c[47]);
        axi_read(32'h3C0, c[48]);
        axi_read(32'h3C4, c[49]);
        axi_read(32'h3C8, c[50]);
        axi_read(32'h3CC, c[51]);
        axi_read(32'h3D0, c[52]);
        axi_read(32'h3D4, c[53]);
        axi_read(32'h3D8, c[54]);
        axi_read(32'h3DC, c[55]);
        axi_read(32'h3E0, c[56]);
        axi_read(32'h3E4, c[57]);
        axi_read(32'h3E8, c[58]);
        axi_read(32'h3EC, c[59]);
        axi_read(32'h3F0, c[60]);
        axi_read(32'h3F4, c[61]);
        axi_read(32'h3F8, c[62]);
        axi_read(32'h3FC, c[63]);

        $display("Read C through AXI-Lite 8x8:");
        $display("%d %d %d %d %d %d %d %d", c[0], c[1], c[2], c[3], c[4], c[5], c[6], c[7]);
        $display("%d %d %d %d %d %d %d %d", c[8], c[9], c[10], c[11], c[12], c[13], c[14], c[15]);
        $display("%d %d %d %d %d %d %d %d", c[16], c[17], c[18], c[19], c[20], c[21], c[22], c[23]);
        $display("%d %d %d %d %d %d %d %d", c[24], c[25], c[26], c[27], c[28], c[29], c[30], c[31]);
        $display("%d %d %d %d %d %d %d %d", c[32], c[33], c[34], c[35], c[36], c[37], c[38], c[39]);
        $display("%d %d %d %d %d %d %d %d", c[40], c[41], c[42], c[43], c[44], c[45], c[46], c[47]);
        $display("%d %d %d %d %d %d %d %d", c[48], c[49], c[50], c[51], c[52], c[53], c[54], c[55]);
        $display("%d %d %d %d %d %d %d %d", c[56], c[57], c[58], c[59], c[60], c[61], c[62], c[63]);

        $display("Expected:");
        $display("5 140 67 -135 110 -89 -39 17");
        $display("-78 -67 -57 -15 -80 100 64 -18");
        $display("52 173 43 38 63 70 -137 -101");
        $display("-57 -10 12 15 25 -5 20 -61");
        $display("-5 7 -8 -137 -3 33 48 4");
        $display("32 80 80 -72 13 -30 4 -46");
        $display("-55 -51 64 -72 -79 -83 103 37");
        $display("86 162 68 -169 63 -5 -22 29");

        if (
            c[0] == 32'sd5 &&
            c[1] == 32'sd140 &&
            c[2] == 32'sd67 &&
            c[3] == -32'sd135 &&
            c[4] == 32'sd110 &&
            c[5] == -32'sd89 &&
            c[6] == -32'sd39 &&
            c[7] == 32'sd17 &&
            c[8] == -32'sd78 &&
            c[9] == -32'sd67 &&
            c[10] == -32'sd57 &&
            c[11] == -32'sd15 &&
            c[12] == -32'sd80 &&
            c[13] == 32'sd100 &&
            c[14] == 32'sd64 &&
            c[15] == -32'sd18 &&
            c[16] == 32'sd52 &&
            c[17] == 32'sd173 &&
            c[18] == 32'sd43 &&
            c[19] == 32'sd38 &&
            c[20] == 32'sd63 &&
            c[21] == 32'sd70 &&
            c[22] == -32'sd137 &&
            c[23] == -32'sd101 &&
            c[24] == -32'sd57 &&
            c[25] == -32'sd10 &&
            c[26] == 32'sd12 &&
            c[27] == 32'sd15 &&
            c[28] == 32'sd25 &&
            c[29] == -32'sd5 &&
            c[30] == 32'sd20 &&
            c[31] == -32'sd61 &&
            c[32] == -32'sd5 &&
            c[33] == 32'sd7 &&
            c[34] == -32'sd8 &&
            c[35] == -32'sd137 &&
            c[36] == -32'sd3 &&
            c[37] == 32'sd33 &&
            c[38] == 32'sd48 &&
            c[39] == 32'sd4 &&
            c[40] == 32'sd32 &&
            c[41] == 32'sd80 &&
            c[42] == 32'sd80 &&
            c[43] == -32'sd72 &&
            c[44] == 32'sd13 &&
            c[45] == -32'sd30 &&
            c[46] == 32'sd4 &&
            c[47] == -32'sd46 &&
            c[48] == -32'sd55 &&
            c[49] == -32'sd51 &&
            c[50] == 32'sd64 &&
            c[51] == -32'sd72 &&
            c[52] == -32'sd79 &&
            c[53] == -32'sd83 &&
            c[54] == 32'sd103 &&
            c[55] == 32'sd37 &&
            c[56] == 32'sd86 &&
            c[57] == 32'sd162 &&
            c[58] == 32'sd68 &&
            c[59] == -32'sd169 &&
            c[60] == 32'sd63 &&
            c[61] == -32'sd5 &&
            c[62] == -32'sd22 &&
            c[63] == 32'sd29
            && rdata[1] == 1'b1
            && irq == 1'b1
        ) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end

        axi_write(32'h000, 32'd2);
        axi_read(32'h004, rdata);
        $display("STATUS after clear = %b", rdata[3:0]);

        #50;
        $finish;
    end

endmodule
