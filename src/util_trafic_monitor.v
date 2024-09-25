// +FHEADER-------------------------------------------------------------------------------
// Copyright (c) 2024 john_tito. All rights reserved.
// ---------------------------------------------------------------------------------------
// Author        : john_tito
// Module Name   : util_trafic_monitor
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

module util_trafic_monitor #(
    parameter CLK_FREQ    = 64'd150_000_000,  // Hz
    parameter REPORT_TIME = 64'd1_000_000,    // ns
    parameter TBYTE_NUM   = 64'd16,
    parameter ID_WIDTH    = 1,
    parameter DEST_WIDTH  = 1
) (
    input  wire                       clk,
    input  wire                       rst,
    input  wire                       en,
    output reg  [               31:0] trafic_flow,
    input  wire                       s_axis_tvalid,
    output wire                       s_axis_tready,
    input  wire [(TBYTE_NUM*8-1) : 0] s_axis_tdata,
    input  wire [  (TBYTE_NUM-1) : 0] s_axis_tkeep,
    input  wire                       s_axis_tlast,
    input  wire [   (ID_WIDTH-1) : 0] s_axis_tid,
    input  wire [ (DEST_WIDTH-1) : 0] s_axis_tdest,

    output wire                       m_axis_tvalid,
    input  wire                       m_axis_tready,
    output wire [(TBYTE_NUM*8-1) : 0] m_axis_tdata,
    output wire [  (TBYTE_NUM-1) : 0] m_axis_tkeep,
    output wire                       m_axis_tlast,
    output wire [   (ID_WIDTH-1) : 0] m_axis_tid,
    output wire [ (DEST_WIDTH-1) : 0] m_axis_tdest
);

    localparam SECOND_DIV = REPORT_TIME * CLK_FREQ / 64'd1_000_000_000;

    wire        active = m_axis_tvalid & m_axis_tready;

    reg  [63:0] trafic_flow_i;
    reg  [31:0] trans_cnt;
    wire        second_pulse;
    reg  [31:0] second_cnt;

    assign s_axis_tready = m_axis_tready;
    assign m_axis_tvalid = s_axis_tvalid;
    assign m_axis_tdata  = s_axis_tdata;
    assign m_axis_tkeep  = s_axis_tkeep;
    assign m_axis_tlast  = s_axis_tlast;
    assign m_axis_tid    = s_axis_tid;
    assign m_axis_tdest  = s_axis_tdest;


    always @(posedge clk) begin
        if (rst) begin
            trans_cnt <= 0;
        end else begin
            if (en) begin
                if (second_pulse) begin
                    trans_cnt <= 0;
                end else if (active) begin
                    trans_cnt <= trans_cnt + 1;
                end else begin
                    trans_cnt <= trans_cnt;
                end
            end else begin
                trans_cnt <= 0;
            end
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            second_cnt = 0;
        end else begin
            if (en && (second_cnt < SECOND_DIV - 1)) begin
                second_cnt <= second_cnt + 1;
            end else begin
                second_cnt <= 0;
            end
        end
    end

    assign second_pulse = (second_cnt == SECOND_DIV - 1);

    always @(posedge clk) begin
        if (rst) begin
            trafic_flow_i <= 0;
        end else begin
            if (en) begin
                if (second_pulse) begin
                    if (active) begin
                        trafic_flow_i <= (trans_cnt + 1) * TBYTE_NUM * (64'd1_000_000_000 / REPORT_TIME);
                    end else begin
                        trafic_flow_i <= trans_cnt * TBYTE_NUM * (64'd1_000_000_000 / REPORT_TIME);
                    end
                end
            end else begin
                trafic_flow_i <= 0;
            end
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            trafic_flow <= 0;
        end else begin
            if (en) begin
                trafic_flow <= trafic_flow_i >> 10;
            end else begin
                trafic_flow <= 0;
            end
        end
    end

endmodule

// verilog_format: off
`resetall
// verilog_format: on
