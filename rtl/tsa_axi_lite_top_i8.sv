module tsa_axi_lite_top_i8 (
    input  wire                    ACLK,
    input  wire                    ARESETN,

    input  wire [31:0]             S_AXI_AWADDR,
    input  wire                    S_AXI_AWVALID,
    output reg                     S_AXI_AWREADY,

    input  wire [31:0]             S_AXI_WDATA,
    input  wire [3:0]              S_AXI_WSTRB,
    input  wire                    S_AXI_WVALID,
    output reg                     S_AXI_WREADY,

    output reg  [1:0]              S_AXI_BRESP,
    output reg                     S_AXI_BVALID,
    input  wire                    S_AXI_BREADY,

    input  wire [31:0]             S_AXI_ARADDR,
    input  wire                    S_AXI_ARVALID,
    output reg                     S_AXI_ARREADY,

    output reg  [31:0]             S_AXI_RDATA,
    output reg  [1:0]              S_AXI_RRESP,
    output reg                     S_AXI_RVALID,
    input  wire                    S_AXI_RREADY,

    output wire                    irq
);

    wire reset;
    assign reset = ~ARESETN;

    localparam ADDR_CTRL   = 8'h00;
    localparam ADDR_STATUS = 8'h04;

    localparam ADDR_A_BASE = 8'h40;
    localparam ADDR_B_BASE = 8'h80;
    localparam ADDR_C_BASE = 8'hC0;

    reg signed [7:0]  mem_a [0:15];
    reg signed [7:0]  mem_b [0:15];
    reg signed [31:0] mem_c [0:15];

    wire signed [31:0] c00, c01, c02, c03;
    wire signed [31:0] c10, c11, c12, c13;
    wire signed [31:0] c20, c21, c22, c23;
    wire signed [31:0] c30, c31, c32, c33;

    wire core_busy;
    wire core_done;
    wire core_valid;

    reg start_pulse;
    reg done_latched;
    reg valid_latched;

    integer i;

    assign irq = done_latched;

    tsa_systolic_4x4_core_i8 core (
        .clk(ACLK),
        .reset(reset),
        .start(start_pulse),

        .a00(mem_a[0]),  .a01(mem_a[1]),  .a02(mem_a[2]),  .a03(mem_a[3]),
        .a10(mem_a[4]),  .a11(mem_a[5]),  .a12(mem_a[6]),  .a13(mem_a[7]),
        .a20(mem_a[8]),  .a21(mem_a[9]),  .a22(mem_a[10]), .a23(mem_a[11]),
        .a30(mem_a[12]), .a31(mem_a[13]), .a32(mem_a[14]), .a33(mem_a[15]),

        .b00(mem_b[0]),  .b01(mem_b[1]),  .b02(mem_b[2]),  .b03(mem_b[3]),
        .b10(mem_b[4]),  .b11(mem_b[5]),  .b12(mem_b[6]),  .b13(mem_b[7]),
        .b20(mem_b[8]),  .b21(mem_b[9]),  .b22(mem_b[10]), .b23(mem_b[11]),
        .b30(mem_b[12]), .b31(mem_b[13]), .b32(mem_b[14]), .b33(mem_b[15]),

        .c00(c00), .c01(c01), .c02(c02), .c03(c03),
        .c10(c10), .c11(c11), .c12(c12), .c13(c13),
        .c20(c20), .c21(c21), .c22(c22), .c23(c23),
        .c30(c30), .c31(c31), .c32(c32), .c33(c33),

        .busy(core_busy),
        .done(core_done),
        .valid(core_valid)
    );

    function [31:0] sign_extend_i8;
        input signed [7:0] value;
        begin
            sign_extend_i8 = {{24{value[7]}}, value};
        end
    endfunction

    function is_a_addr;
        input [7:0] addr;
        begin
            is_a_addr = (addr >= 8'h40 && addr <= 8'h7C && addr[1:0] == 2'b00);
        end
    endfunction

    function is_b_addr;
        input [7:0] addr;
        begin
            is_b_addr = (addr >= 8'h80 && addr <= 8'hBC && addr[1:0] == 2'b00);
        end
    endfunction

    function is_c_addr;
        input [7:0] addr;
        begin
            is_c_addr = (addr >= 8'hC0 && addr <= 8'hFC && addr[1:0] == 2'b00);
        end
    endfunction

    task write_register;
        input [31:0] addr;
        input [31:0] data;
        reg [3:0] idx;
        begin
            idx = addr[5:2];

            if (addr[7:0] == ADDR_CTRL) begin
                if (data[0] && !core_busy) begin
                    start_pulse   <= 1'b1;
                    done_latched  <= 1'b0;
                    valid_latched <= 1'b0;
                end

                if (data[1]) begin
                    done_latched  <= 1'b0;
                    valid_latched <= 1'b0;
                end
            end else if (is_a_addr(addr[7:0])) begin
                mem_a[idx] <= data[7:0];
            end else if (is_b_addr(addr[7:0])) begin
                mem_b[idx] <= data[7:0];
            end
        end
    endtask

    function [31:0] read_register;
        input [31:0] addr;
        reg [3:0] idx;
        begin
            idx = addr[5:2];

            if (addr[7:0] == ADDR_CTRL) begin
                read_register = 32'd0;
            end else if (addr[7:0] == ADDR_STATUS) begin
                read_register = {
                    28'd0,
                    irq,
                    valid_latched,
                    done_latched,
                    core_busy
                };
            end else if (is_a_addr(addr[7:0])) begin
                read_register = sign_extend_i8(mem_a[idx]);
            end else if (is_b_addr(addr[7:0])) begin
                read_register = sign_extend_i8(mem_b[idx]);
            end else if (is_c_addr(addr[7:0])) begin
                read_register = mem_c[idx];
            end else begin
                read_register = 32'hDEAD_BEEF;
            end
        end
    endfunction

    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            S_AXI_AWREADY <= 1'b0;
            S_AXI_WREADY  <= 1'b0;
            S_AXI_BRESP   <= 2'b00;
            S_AXI_BVALID  <= 1'b0;

            S_AXI_ARREADY <= 1'b0;
            S_AXI_RDATA   <= 32'd0;
            S_AXI_RRESP   <= 2'b00;
            S_AXI_RVALID  <= 1'b0;

            start_pulse   <= 1'b0;
            done_latched  <= 1'b0;
            valid_latched <= 1'b0;

            for (i = 0; i < 16; i = i + 1) begin
                mem_a[i] <= 8'sd0;
                mem_b[i] <= 8'sd0;
                mem_c[i] <= 32'sd0;
            end
        end else begin
            start_pulse <= 1'b0;

            if (core_done) begin
                done_latched  <= 1'b1;
                valid_latched <= 1'b1;

                mem_c[0]  <= c00;
                mem_c[1]  <= c01;
                mem_c[2]  <= c02;
                mem_c[3]  <= c03;

                mem_c[4]  <= c10;
                mem_c[5]  <= c11;
                mem_c[6]  <= c12;
                mem_c[7]  <= c13;

                mem_c[8]  <= c20;
                mem_c[9]  <= c21;
                mem_c[10] <= c22;
                mem_c[11] <= c23;

                mem_c[12] <= c30;
                mem_c[13] <= c31;
                mem_c[14] <= c32;
                mem_c[15] <= c33;
            end

            if (!S_AXI_AWREADY && !S_AXI_BVALID) begin
                S_AXI_AWREADY <= 1'b1;
            end else if (S_AXI_AWVALID && S_AXI_AWREADY) begin
                S_AXI_AWREADY <= 1'b0;
            end

            if (!S_AXI_WREADY && !S_AXI_BVALID) begin
                S_AXI_WREADY <= 1'b1;
            end else if (S_AXI_WVALID && S_AXI_WREADY) begin
                S_AXI_WREADY <= 1'b0;
            end

            if (S_AXI_AWVALID && S_AXI_AWREADY && S_AXI_WVALID && S_AXI_WREADY) begin
                write_register(S_AXI_AWADDR, S_AXI_WDATA);
                S_AXI_BVALID <= 1'b1;
                S_AXI_BRESP  <= 2'b00;
            end else if (S_AXI_BVALID && S_AXI_BREADY) begin
                S_AXI_BVALID <= 1'b0;
            end

            if (!S_AXI_ARREADY && !S_AXI_RVALID) begin
                S_AXI_ARREADY <= 1'b1;
            end else if (S_AXI_ARVALID && S_AXI_ARREADY) begin
                S_AXI_ARREADY <= 1'b0;
                S_AXI_RDATA   <= read_register(S_AXI_ARADDR);
                S_AXI_RRESP   <= 2'b00;
                S_AXI_RVALID  <= 1'b1;
            end

            if (S_AXI_RVALID && S_AXI_RREADY) begin
                S_AXI_RVALID <= 1'b0;
            end
        end
    end

endmodule
