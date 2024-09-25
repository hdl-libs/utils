// +FHEADER-------------------------------------------------------------------------------
// Copyright (c) 2024 john_tito. All rights reserved.
// ---------------------------------------------------------------------------------------
// Author        : john_tito
// Module Name   : util_filter
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

module util_filter (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] cfg_high_time,
    input  wire [31:0] cfg_low_time,
    input  wire        filter_i,
    output reg         filter_o
);

    reg [31:0] high_cnt = 32'hFFFFFFFF;
    reg [31:0] low_cnt = 32'hFFFFFFFF;

    always @(posedge clk) begin
        if (rst) begin
            high_cnt <= cfg_high_time;
            low_cnt  <= cfg_low_time;
        end else begin
            if (filter_o) begin
                if (~filter_i && (low_cnt > 0)) begin
                    low_cnt <= low_cnt - 1;
                end else begin
                    low_cnt <= cfg_low_time;
                end
                high_cnt <= cfg_high_time;
            end else begin
                if (filter_i && (high_cnt > 0)) begin
                    high_cnt <= high_cnt - 1;
                end else begin
                    high_cnt <= cfg_high_time;
                end
                low_cnt <= cfg_low_time;
            end

        end
    end

    always @(posedge clk) begin
        if (rst) begin
            filter_o <= filter_i;
        end else begin
            if ((filter_o == 1'b1) && (low_cnt == 0)) begin
                filter_o <= 1'b0;
            end else if ((filter_o == 1'b0) && (high_cnt == 0)) begin
                filter_o <= 1'b1;
            end else begin
                filter_o <= filter_o;
            end
        end
    end

endmodule

// verilog_format: off
`resetall
// verilog_format: on
