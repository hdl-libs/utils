// +FHEADER-------------------------------------------------------------------------------
// Copyright (c) 2024 john_tito. All rights reserved.
// ---------------------------------------------------------------------------------------
// Author        : john_tito
// Module Name   : util_led_blink
// ---------------------------------------------------------------------------------------
// Revision      : 1.0
// Description   : add description here
// Revision 1.00 - File Created
// ---------------------------------------------------------------------------------------
// Reuse Issue   :
// Synthesizable : Yes
// Instantiations: add dependencies here
// Clock Domains : clk
// Reset Strategy: Sync Reset
// Other :
// -FHEADER-------------------------------------------------------------------------------

// verilog_format: off
`resetall
`timescale 1ns / 1ps
`default_nettype none
// verilog_format: on

module util_led_blink #(
    parameter         DEFAULT_LEVEL = 1'b1,
    parameter         ACTIVE_LEVEL  = 1'b0,
    parameter integer INACTIVE_CLKS = 10,
    parameter integer ACTIVE_CLKS   = 20
) (
    input  wire       clk,
    input  wire       rst,
    input  wire       en,
    input  wire [1:0] mode,
    output reg        led
);

    // verilog_format: off
    localparam [1:0] INACTIVE       = 2'b00;
    localparam [1:0] ACTIVE         = 2'b01;
    localparam [1:0] BLINK_INACTIVE = 2'b10;
    localparam [1:0] BLINK_ACTIVE   = 2'b11;
    // verilog_format: on

    wire        blink;
    wire        state;

    reg         active = 1'b0;
    reg  [31:0] active_cnt = 32'd0;
    reg  [31:0] inactive_cnt = 32'd0;

    assign {blink, state} = mode;

    always @(posedge clk) begin
        if (en) begin
            if (blink) begin
                active <= (active_cnt > 0);
            end else begin
                active <= state;
            end
        end else begin
            active <= 1'b0;
        end
    end

    always @(posedge clk) begin
        case ({
            en, active
        })
            2'b10:   led <= ~ACTIVE_LEVEL;
            2'b11:   led <= ACTIVE_LEVEL;
            default: led <= DEFAULT_LEVEL;
        endcase
    end

    always @(posedge clk) begin
        if (rst) begin
            active_cnt   <= 32'd0;
            inactive_cnt <= 32'd0;
        end else begin

            if (en & blink) begin

                if (inactive_cnt) begin
                    inactive_cnt <= inactive_cnt - 1;
                end else if (active_cnt <= 1) begin
                    if (state) begin
                        inactive_cnt <= ACTIVE_CLKS;
                    end else begin
                        inactive_cnt <= INACTIVE_CLKS;
                    end
                end

                if (active_cnt) begin
                    active_cnt <= active_cnt - 1;
                end else if (inactive_cnt == 1) begin
                    if (state) begin
                        active_cnt <= ACTIVE_CLKS;
                    end else begin
                        active_cnt <= INACTIVE_CLKS;
                    end
                end

            end else begin
                active_cnt   <= 32'd0;
                inactive_cnt <= 32'd0;
            end
        end
    end

endmodule


// verilog_format: off
`resetall
// verilog_format: on
