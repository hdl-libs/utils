// +FHEADER-------------------------------------------------------------------------------
// Copyright (c) 2024 john_tito. All rights reserved.
// ---------------------------------------------------------------------------------------
// Author        : john_tito
// Module Name   : util_sequences_generator
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

module util_sequences_generator #(
    parameter                                    CLK_FREQ       = 64'd100_000_000,              // Hz
    parameter                                    SPEED          = 64'd1_000_000,                // Hz
    parameter                                    TDATA_WIDTH    = 8,
    parameter                                    SEQUENCES_LEN  = 4,
    parameter [               (TDATA_WIDTH-1):0] ERR_PATTERN    = 8'hEE,
    parameter [(TDATA_WIDTH*SEQUENCES_LEN -1):0] SEQUENCES_PACK = {8'h00, 8'h00, 8'h00, 8'h00}
) (
    input  wire                     clk,
    input  wire                     en,
    input  wire                     err_ins,
    input  wire                     pause,
    output reg                      m_axis_tvalid,
    output reg  [(TDATA_WIDTH-1):0] m_axis_tdata,
    input  wire                     m_axis_tready
);

    localparam PERIOD_DIV = (CLK_FREQ / SPEED) ? (CLK_FREQ / SPEED - 1) : 0;

    wire [(TDATA_WIDTH-1):0] SEQUENCES_UNPACK[(SEQUENCES_LEN-1):0];

    wire                     active;
    reg  [              7:0] cnt;

    reg  [              1:0] err_ins_l;
    reg                      err_ins_req;

    reg  [             31:0] period_cnt = 0;
    reg                      period_pulse;

    generate
        genvar ii;
        for (ii = 0; ii < SEQUENCES_LEN; ii = ii + 1) begin
            assign SEQUENCES_UNPACK[ii] = SEQUENCES_PACK[ii*TDATA_WIDTH+:TDATA_WIDTH];
        end
    endgenerate

    assign active = m_axis_tvalid & m_axis_tready;

    always @(posedge clk) begin
        if (en) begin
            if (period_cnt < PERIOD_DIV) begin
                if (pause) begin
                    period_cnt   <= period_cnt;
                    period_pulse <= 1'b0;
                end else begin
                    period_cnt   <= period_cnt + 1;
                    period_pulse <= 1'b0;
                end
            end else begin
                period_cnt   <= 0;
                period_pulse <= 1'b1;
            end
        end else begin
            period_cnt   <= 0;
            period_pulse <= 1'b0;
        end
    end

    always @(posedge clk) begin
        if (en) begin
            err_ins_l <= {err_ins_l[0], err_ins};

            if (err_ins_l[0] & ~err_ins_l[1]) begin
                err_ins_req <= 1'b1;
            end else if (active) begin
                err_ins_req <= 1'b0;
            end

        end else begin
            err_ins_l   <= 2'b00;
            err_ins_req <= 1'b0;
        end
    end

    always @(posedge clk) begin
        if (en) begin
            if (period_pulse & (~m_axis_tvalid | m_axis_tready)) begin
                m_axis_tvalid <= 1'b1;
                m_axis_tdata  <= SEQUENCES_UNPACK[cnt];
            end else if (m_axis_tready) begin
                m_axis_tvalid <= 1'b0;
                m_axis_tdata  <= m_axis_tdata;
            end else begin
                m_axis_tvalid <= m_axis_tvalid;
                m_axis_tdata  <= m_axis_tdata;
            end
        end else begin
            m_axis_tdata  <= 0;
            m_axis_tvalid <= 1'b0;
        end
    end

    always @(posedge clk) begin
        if (en) begin
            if (active) begin
                if (cnt + 1 < SEQUENCES_LEN) begin
                    cnt <= cnt + 1;
                end else begin
                    cnt <= 0;
                end
            end
        end else begin
            cnt <= 0;
        end
    end

endmodule

// verilog_format: off
`resetall
// verilog_format: on
