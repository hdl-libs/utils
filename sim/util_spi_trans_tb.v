// verilog_format: off
`resetall
`timescale 1ns / 1ps
`default_nettype none
// verilog_format: on

module util_spi_trans_tb;

    // Parameters
    localparam real TIMEPERIOD = 5;
    localparam SLAVE_NUM = 4;
    localparam CPOL = 1'b0;

    // Ports

    wire                 spi_mosi_i;
    wire                 spi_mosi_o;
    reg                  spi_mosi_t = 0;

    wire                 spi_miso_i;
    reg                  spi_miso_o = 0;
    reg                  spi_miso_t = 0;

    wire                 spi_clk_i;
    wire                 spi_clk_o;
    reg                  spi_clk_t = 0;

    wire [SLAVE_NUM-1:0] spi_cs_i;
    reg  [SLAVE_NUM-1:0] spi_cs_o;
    reg                  spi_cs_t = 0;

    wire [SLAVE_NUM-1:0] cs;
    wire [SLAVE_NUM-1:0] sclk;
    reg  [SLAVE_NUM-1:0] miso = 0;
    wire [SLAVE_NUM-1:0] mosi;

    util_spi_trans #(
        .SLAVE_NUM(SLAVE_NUM),
        .CPOL     (CPOL)
    ) dut (
        .spi_mosi_i(spi_mosi_i),
        .spi_mosi_o(spi_mosi_o),
        .spi_mosi_t(spi_mosi_t),
        .spi_miso_i(spi_miso_i),
        .spi_miso_o(spi_miso_o),
        .spi_miso_t(spi_miso_t),
        .spi_clk_i (spi_clk_i),
        .spi_clk_o (spi_clk_o),
        .spi_clk_t (spi_clk_t),
        .spi_cs_i  (spi_cs_i),
        .spi_cs_o  (spi_cs_o),
        .spi_cs_t  (spi_cs_t),
        .cs        (cs),
        .sclk      (sclk),
        .miso      (miso),
        .mosi      (mosi)
    );

    initial begin
        begin
            spi_miso_o = 0;
            spi_miso_t = 0;
            #1000;
            spi_miso_o = 0;
            spi_miso_t = 1'b1;
            #1000;
        end
    end

    initial begin
        begin
            spi_cs_o = 4'b1111;
            spi_cs_t = 1;
            #1000;
            spi_cs_o = 4'b1110;
            #1000;
            spi_cs_o = 4'b1101;
            #1000;
            spi_cs_o = 4'b1011;
            #1000;
            spi_cs_o = 4'b0111;
            #1000;
            $finish;
        end
    end

    reg [7:0] cnt = 0;
    always @(posedge spi_clk_t) begin
        cnt <= cnt + 1;
        if (cnt == 7) begin
            cnt <= 0;
        end
    end

    always @(posedge spi_clk_t) begin
        if (cnt == 7) begin
            miso <= miso + 1;
        end
    end

    assign spi_clk_o = 1'b1;
    always #(TIMEPERIOD / 2) spi_clk_t = !spi_clk_t;

    assign spi_mosi_o = 1'b1;
    always #(TIMEPERIOD * 2) spi_mosi_t = !spi_mosi_t;

    // record block
    initial begin
        $dumpfile("sim/test_tb.vcd");
        $dumpvars(0, util_spi_trans_tb);
    end


endmodule

// verilog_format: off
`resetall
// verilog_format: on
