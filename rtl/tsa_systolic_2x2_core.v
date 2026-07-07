module tsa_systolic_2x2_core (
    input  wire        clk,
    input  wire        reset,
    input  wire        start,

    input  wire [7:0]  a00,
    input  wire [7:0]  a01,
    input  wire [7:0]  a10,
    input  wire [7:0]  a11,

    input  wire [7:0]  b00,
    input  wire [7:0]  b01,
    input  wire [7:0]  b10,
    input  wire [7:0]  b11,

    output wire [31:0] c00,
    output wire [31:0] c01,
    output wire [31:0] c10,
    output wire [31:0] c11,

    output reg         busy,
    output reg         done,
    output reg         valid
);

    reg enable;
    reg clear;

    reg [2:0] cycle;
    reg [2:0] state;

    reg [7:0] a0_feed;
    reg [7:0] a1_feed;
    reg [7:0] b0_feed;
    reg [7:0] b1_feed;

    localparam IDLE  = 3'd0;
    localparam CLEAR = 3'd1;
    localparam RUN   = 3'd2;
    localparam DONE  = 3'd3;

    tsa_systolic_2x2 array (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .clear(clear),

        .a0_in(a0_feed),
        .a1_in(a1_feed),
        .b0_in(b0_feed),
        .b1_in(b1_feed),

        .c00(c00),
        .c01(c01),
        .c10(c10),
        .c11(c11)
    );

    always @(*) begin
        a0_feed = 8'd0;
        a1_feed = 8'd0;
        b0_feed = 8'd0;
        b1_feed = 8'd0;

        case (cycle)

            3'd0: begin
                // Cycle 1:
                // a00 and b00 enter first.
                a0_feed = a00;
                a1_feed = 8'd0;
                b0_feed = b00;
                b1_feed = 8'd0;
            end

            3'd1: begin
                // Cycle 2:
                // a01, a10, b10, b01.
                a0_feed = a01;
                a1_feed = a10;
                b0_feed = b10;
                b1_feed = b01;
            end

            3'd2: begin
                // Cycle 3:
                // a11 and b11.
                a0_feed = 8'd0;
                a1_feed = a11;
                b0_feed = 8'd0;
                b1_feed = b11;
            end

            3'd3: begin
                // Cycle 4:
                // flush.
                a0_feed = 8'd0;
                a1_feed = 8'd0;
                b0_feed = 8'd0;
                b1_feed = 8'd0;
            end

            default: begin
                a0_feed = 8'd0;
                a1_feed = 8'd0;
                b0_feed = 8'd0;
                b1_feed = 8'd0;
            end

        endcase
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state  <= IDLE;
            cycle  <= 3'd0;

            enable <= 1'b0;
            clear  <= 1'b0;

            busy   <= 1'b0;
            done   <= 1'b0;
            valid  <= 1'b0;
        end else begin
            case (state)

                IDLE: begin
                    enable <= 1'b0;
                    clear  <= 1'b0;
                    busy   <= 1'b0;
                    done   <= 1'b0;

                    if (start) begin
                        valid  <= 1'b0;
                        busy   <= 1'b1;
                        clear  <= 1'b1;
                        cycle  <= 3'd0;
                        state  <= CLEAR;
                    end
                end

                CLEAR: begin
                    clear  <= 1'b0;
                    enable <= 1'b1;
                    busy   <= 1'b1;
                    done   <= 1'b0;
                    valid  <= 1'b0;
                    cycle  <= 3'd0;
                    state  <= RUN;
                end

                RUN: begin
                    enable <= 1'b1;
                    clear  <= 1'b0;
                    busy   <= 1'b1;
                    done   <= 1'b0;
                    valid  <= 1'b0;

                    if (cycle == 3'd3) begin
                        state <= DONE;
                    end else begin
                        cycle <= cycle + 3'd1;
                    end
                end

                DONE: begin
                    enable <= 1'b0;
                    clear  <= 1'b0;
                    busy   <= 1'b0;
                    done   <= 1'b1;
                    valid  <= 1'b1;
                    state  <= IDLE;
                end

                default: begin
                    state  <= IDLE;
                    cycle  <= 3'd0;
                    enable <= 1'b0;
                    clear  <= 1'b0;
                    busy   <= 1'b0;
                    done   <= 1'b0;
                    valid  <= 1'b0;
                end

            endcase
        end
    end

endmodule
