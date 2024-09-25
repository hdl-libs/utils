// +FHEADER-------------------------------------------------------------------------------
// Copyright (c) 2024 john_tito. All rights reserved.
// ---------------------------------------------------------------------------------------
// Author        : john_tito
// Module Name   : util_reset_controller
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

module util_reset_controller #(
    parameter RST_HOLD_CNT = 2000,
    parameter RST_RELEASE_CNT = 6000
) (
    input  wire clk,    //
    input  wire rst,   //
    output reg  reset,
    input  wire locked
);
    reg [31:0] reset_cnt;

    always @(posedge clk) begin
        if (rst) begin
            reset_cnt <= 0;
        end else if ((reset_cnt >= RST_RELEASE_CNT) && (!locked)) begin
            reset_cnt <= 0;
        end else begin
            if (reset_cnt < RST_RELEASE_CNT) begin
                reset_cnt <= reset_cnt + 16'd1;
            end
        end
    end
    always @(posedge clk) begin
        if (rst) begin
            reset = 1'b1;
        end else if ((reset_cnt > 0) && (reset_cnt < RST_HOLD_CNT)) begin
            reset = 1'b1;
        end else begin
            reset = 1'b0;
        end
    end
endmodule

// verilog_format: off
`resetall
// verilog_format: on