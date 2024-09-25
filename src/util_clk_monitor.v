// +FHEADER-------------------------------------------------------------------------------
// Copyright (c) 2024 john_tito. All rights reserved.
// ---------------------------------------------------------------------------------------
// Author        : john_tito
// Module Name   : util_clk_monitor
// ---------------------------------------------------------------------------------------
// Revision      : 1.0
// Description   : add description here
// Revision 1.00 - File Created
// ---------------------------------------------------------------------------------------
// Reuse Issue   :
// Synthesizable : Yes
// Instantiations: add dependencies here
// Clock Domains : clk
// Reset Strategy: sync reset
// Other :
// -FHEADER-------------------------------------------------------------------------------

// verilog_format: off
`resetall
`timescale 1ns / 1ps
`default_nettype none
// verilog_format: on

module util_clk_monitor #(
    parameter integer PRESCALER_CNT_VALUE = 1000,
    parameter integer EXT_CLK_FREQ        = 200_000_000,
    parameter integer USER_CLK_FREQ       = 100_000_000,
    parameter integer SLACK               = 32,
    parameter         IN_SIM              = "false"
) (
    input  wire rst,           //
    input  wire clk,
    //
    input  wire ext_clk_rstn,  //
    input  wire ext_clk,
    //
    output wire state          //
);
    // Threshold after expansion by a factor of two
    localparam [95:0] ALARM_THRESHOLD = (PRESCALER_CNT_VALUE * (USER_CLK_FREQ / 1000_000)) / (EXT_CLK_FREQ / 1000_000) + SLACK;

    // ***********************************************************************************
    // convert high frequency clock to low frequency signal by counter divider
    // ***********************************************************************************
    reg [31:0] clk_div_cnt = 0;

    always @(posedge ext_clk) begin
        if (!ext_clk_rstn) begin
            clk_div_cnt <= 0;
        end else begin
            if (clk_div_cnt < PRESCALER_CNT_VALUE - 1) begin
                clk_div_cnt <= clk_div_cnt + 1;
            end else begin
                clk_div_cnt <= 0;
            end

        end
    end

    reg adc_clk_div_gate = 1'b0;
    always @(posedge ext_clk) begin
        if (!ext_clk_rstn) begin
            adc_clk_div_gate <= 1'b0;
        end else begin
            if (clk_div_cnt >= PRESCALER_CNT_VALUE / 2) begin
                adc_clk_div_gate <= 1'b1;
            end else begin
                adc_clk_div_gate <= 1'b0;
            end
        end
    end

    // ***********************************************************************************
    // sync signal from frequency clock to low frequency user clock
    // ***********************************************************************************
    wire adc_clk_div_gate_cdc;
    generate
        if (IN_SIM == "true") begin
            assign adc_clk_div_gate_cdc = adc_clk_div_gate;

        end else begin
            xpm_cdc_single #(
                .DEST_SYNC_FF  (4),
                .INIT_SYNC_FF  (0),
                .SIM_ASSERT_CHK(0),
                .SRC_INPUT_REG (1)
            ) xpm_cdc_single_inst (
                .src_clk (ext_clk),
                .src_in  (adc_clk_div_gate),
                .dest_clk(clk),
                .dest_out(adc_clk_div_gate_cdc)
            );
        end
    endgenerate

    // ***********************************************************************************
    // convert the signal to pulse
    // ***********************************************************************************
    wire adc_clk_div_gate_cdc_pulse;
    util_metastable #(
        .C_EDGE_TYPE   ("both"),
        .MAINTAIN_CYCLE(1)
    ) util_metastable_inst (
        .clk (clk),
        .rst (rst),
        .din (adc_clk_div_gate_cdc),
        .dout(adc_clk_div_gate_cdc_pulse)
    );

    // ***********************************************************************************
    // monitor the pulse
    // ***********************************************************************************
    util_watch_dog util_watch_dog_inst (
        .clk       (clk),
        .rst       (rst),
        .en        (1'b1),
        .preset    (ALARM_THRESHOLD),
        .monitor_in(adc_clk_div_gate_cdc_pulse),
        .cnt_pulse (1'b1),
        .state     (state)
    );

endmodule

// verilog_format: off
`resetall
// verilog_format: on
