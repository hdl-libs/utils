// +FHEADER-------------------------------------------------------------------------------
// Copyright (c) 2024 john_tito. All rights reserved.
// ---------------------------------------------------------------------------------------
// Author        : john_tito
// Module Name   : util_trafic_generator
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

module util_trafic_generator #(
    parameter CLK_FREQ   = 64'd150_000_000,  // Hz
    parameter SPEED      = 64'd150_000_000,  // Hz
    parameter TBYTE_NUM  = 64'd16,
    parameter ID_WIDTH   = 5,
    parameter DEST_WIDTH = 5
) (
    input  wire                       clk,
    input  wire                       rst,
    input  wire                       en,
    output reg                        m_axis_tvalid,
    input  wire                       m_axis_tready,
    output reg  [(TBYTE_NUM*8-1) : 0] m_axis_tdata,
    output reg  [  (TBYTE_NUM-1) : 0] m_axis_tkeep,
    output wire                       m_axis_tlast,
    output reg  [   (ID_WIDTH-1) : 0] m_axis_tid,
    output reg  [ (DEST_WIDTH-1) : 0] m_axis_tdest
);

    localparam DIV = (CLK_FREQ / SPEED) ? (CLK_FREQ / SPEED - 1) : 0;

    wire        active = m_axis_tvalid & m_axis_tready;

    reg  [31:0] cnt = 0;
    reg         pulse;
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
            m_axis_tvalid <= 1'b0;
        end else begin
            if (pulse) begin
                m_axis_tvalid <= 1'b1;
            end else if (m_axis_tready) begin
                m_axis_tvalid <= 1'b0;
            end else begin
                m_axis_tvalid <= m_axis_tvalid;
            end
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            m_axis_tdata <= 0;
        end else begin
            if (active) begin
                m_axis_tdata <= m_axis_tdata + 1;
            end else begin
                m_axis_tdata <= m_axis_tdata;
            end
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            m_axis_tid <= 0;
        end else begin
            m_axis_tid <= 0;
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            m_axis_tdest <= 0;
        end else begin
            m_axis_tdest <= 0;
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            m_axis_tkeep <= 0;
        end else begin
            m_axis_tkeep <= {TBYTE_NUM{1'b1}};
        end
    end

    assign m_axis_tlast = 1'b0;

endmodule

// verilog_format: off
`resetall
// verilog_format: on
