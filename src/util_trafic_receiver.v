// +FHEADER-------------------------------------------------------------------------------
// Copyright (c) 2024 john_tito. All rights reserved.
// ---------------------------------------------------------------------------------------
// Author        : john_tito
// Module Name   : util_trafic_receiver
// ---------------------------------------------------------------------------------------
// Revision      : 1.0
// Description   : add description here
// Revision 1.00 - File Created
// ---------------------------------------------------------------------------------------
// Reuse Issue   :
// Synthesizable : Yes
// Instantiations: add dependencies here
// Clock Domains : clk
// Reset Strategy: Sync Reset, Active High Level
// Other :
// -FHEADER-------------------------------------------------------------------------------

// verilog_format: off
`resetall
`timescale 1ns / 1ps
`default_nettype none
// verilog_format: on

module util_trafic_receiver #(
    parameter CLK_FREQ   = 64'd150_000_000,  // Hz
    parameter SPEED      = 64'd150_000_000,  // Hz
    parameter TBYTE_NUM  = 64'd16,
    parameter ID_WIDTH   = 5,
    parameter DEST_WIDTH = 5
) (
                                              input  wire                       clk,
                                              input  wire                       rst,
                                              input  wire                       en,
    (* dont_touch="true" *) (* keep="true" *) input  wire                       s_axis_tvalid,
    (* dont_touch="true" *) (* keep="true" *) output reg                        s_axis_tready,
    (* dont_touch="true" *) (* keep="true" *) input  wire [(TBYTE_NUM*8-1) : 0] s_axis_tdata,
    (* dont_touch="true" *) (* keep="true" *) input  wire [  (TBYTE_NUM-1) : 0] s_axis_tkeep,
    (* dont_touch="true" *) (* keep="true" *) input  wire                       s_axis_tlast,
    (* dont_touch="true" *) (* keep="true" *) input  wire [   (ID_WIDTH-1) : 0] s_axis_tid,
    (* dont_touch="true" *) (* keep="true" *) input  wire [ (DEST_WIDTH-1) : 0] s_axis_tdest,

    output reg error
);

    localparam DIV = (CLK_FREQ / SPEED) ? (CLK_FREQ / SPEED - 1) : 0;

    wire                       active = s_axis_tvalid & s_axis_tready;

    reg  [               31:0] cnt = 0;
    reg                        pulse;

    reg  [(TBYTE_NUM*8-1) : 0] last_data;

    always @(posedge clk) begin
        if (rst) begin
            error     <= 1'b0;
            last_data <= 0;
        end else begin
            if (active) begin
                last_data <= s_axis_tdata;
                error     <= (last_data + 8'h01) != s_axis_tdata;
            end
        end
    end


    always @(posedge clk) begin
        if (rst) begin
            cnt   <= 0;
            pulse <= 1'b0;
        end else begin
            if (en) begin
                if (cnt < DIV) begin
                    cnt   <= cnt + 1;
                    pulse <= 1'b0;
                end else begin
                    cnt   <= 0;
                    pulse <= 1'b1;
                end
            end else begin
                cnt   <= 0;
                pulse <= 1'b0;
            end
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            s_axis_tready <= 1'b0;
        end else begin
            if (en) begin
                if (pulse) begin
                    s_axis_tready <= 1'b1;
                end else if (s_axis_tvalid) begin
                    s_axis_tready <= 1'b0;
                end else begin
                    s_axis_tready <= s_axis_tready;
                end
            end else begin
                s_axis_tready <= 1'b0;
            end
        end
    end

endmodule
// verilog_format: off
`resetall
// verilog_format: on
