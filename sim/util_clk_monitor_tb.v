// verilog_format: off
`resetall
`timescale 1ns / 1ps
`default_nettype none
// verilog_format: on

module util_clk_monitor_tb;

    // Parameters
    localparam PRESCALER_CNT_VALUE = 150;
    localparam EXT_CLK_FREQ = 150_000_000;
    localparam USER_CLK_FREQ = 200_000_000;
    localparam TIMEPERIOD = 1000_000_000 / USER_CLK_FREQ;
    localparam EXT_TIMEPERIOD = 1000_000_000 / EXT_CLK_FREQ;
    localparam SLACK = 1;
    localparam IN_SIM = "true";

    // Ports
    reg  rstn = 0;
    reg  clk = 0;
    reg  ext_clk_rstn = 0;
    reg  ext_clk = 0;
    wire state;

    util_clk_monitor #(
        .PRESCALER_CNT_VALUE(PRESCALER_CNT_VALUE),
        .EXT_CLK_FREQ       (EXT_CLK_FREQ),
        .USER_CLK_FREQ      (USER_CLK_FREQ),
        .SLACK              (SLACK),
        .IN_SIM             (IN_SIM)
    ) util_clk_monitor_inst (
        .rstn        (rstn),
        .clk         (clk),
        .ext_clk_rstn(ext_clk_rstn),
        .ext_clk     (ext_clk),
        .state       (state)
    );

    initial begin
        begin
            ext_clk_rstn = 1'b0;
            #300;
            ext_clk_rstn = 1'b1;
            #100000;
            $finish;
        end
    end

    always #(EXT_TIMEPERIOD / 2) ext_clk = !ext_clk;

    // ***********************************************************************************
    // clock block
    always #(TIMEPERIOD / 2) clk = !clk;

    // reset block
    initial begin
        begin
            rstn = 1'b0;
            #(TIMEPERIOD * 30);
            rstn = 1'b1;
        end
    end

    // record block
    initial begin
        begin
            $dumpfile("sim/test_tb.lxt");
            $dumpvars(0, util_clk_monitor_inst);
        end
    end
endmodule


// verilog_format: off
`resetall
// verilog_format: on
