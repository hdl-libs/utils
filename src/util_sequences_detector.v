// +FHEADER-------------------------------------------------------------------------------
// Copyright (c) 2024 john_tito. All rights reserved.
// ---------------------------------------------------------------------------------------
// Author        : john_tito
// Module Name   : util_sequences_detector
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

module util_sequences_detector #(
    parameter                                    TDATA_WIDTH    = 8,
    parameter                                    SEQUENCES_LEN  = 4,
    parameter [(TDATA_WIDTH*SEQUENCES_LEN -1):0] SEQUENCES_PACK = {8'h00, 8'h00, 8'h00, 8'h00}
) (
    input  wire                     clk,
    input  wire                     en,
    input  wire                     s_axis_tvalid,
    input  wire [(TDATA_WIDTH-1):0] s_axis_tdata,
    output wire                     s_axis_tready,
    output wire                     m_axis_tvalid,
    output wire [(TDATA_WIDTH-1):0] m_axis_tdata,
    input  wire                     m_axis_tready,
    output wire                     error
);

    genvar ii;

    reg  [               31:0] loop_index;

    wire [  (TDATA_WIDTH-1):0] SEQUENCES_UNPACK   [(SEQUENCES_LEN-1):0];

    wire                       active;
    reg  [  (TDATA_WIDTH-1):0] tdata_l            [(SEQUENCES_LEN-1):0];
    reg  [(SEQUENCES_LEN-1):0] sequences_progress;
    wire [(SEQUENCES_LEN-1):0] sequences_chk;
    reg                        sequences_err;

    assign active        = s_axis_tvalid & s_axis_tready;
    assign s_axis_tready = m_axis_tready;
    assign m_axis_tvalid = s_axis_tvalid;
    assign m_axis_tdata  = s_axis_tdata;

    assign error         = sequences_err;

    always @(posedge clk) begin
        if (en) begin
            if (active) begin
                tdata_l[SEQUENCES_LEN-1] <= s_axis_tdata;
                for (loop_index = 0; loop_index < SEQUENCES_LEN - 1; loop_index = loop_index + 1) begin
                    tdata_l[loop_index] <= tdata_l[loop_index+1];
                end
            end
        end else begin
            for (loop_index = 0; loop_index < SEQUENCES_LEN; loop_index = loop_index + 1) begin
                tdata_l[loop_index] <= 0;
            end
        end
    end

    // 错误检测逻辑
    always @(posedge clk) begin
        if (en) begin
            if (active) begin
                if (&sequences_chk) begin
                    sequences_progress <= 'h1;
                end else begin
                    if (sequences_progress < SEQUENCES_LEN) begin
                        sequences_progress <= sequences_progress + 1;
                    end else begin
                        sequences_progress <= 'h1;
                    end
                end
            end else begin
                if (&sequences_chk) begin
                    sequences_progress <= 'h0;
                end
            end
        end else begin
            sequences_progress <= 'h0;
        end
    end

    generate
        for (ii = 0; ii < SEQUENCES_LEN; ii = ii + 1) begin
            assign SEQUENCES_UNPACK[ii] = SEQUENCES_PACK[ii*TDATA_WIDTH+:TDATA_WIDTH];
            assign sequences_chk[ii]    = tdata_l[ii] == SEQUENCES_UNPACK[ii];
        end
    endgenerate

    always @(posedge clk) begin
        if (en) begin
            if ((sequences_progress == SEQUENCES_LEN)) begin
                sequences_err <= ~(&sequences_chk);
            end
        end else begin
            sequences_err <= 1'b0;
        end
    end

endmodule

// verilog_format: off
`resetall
// verilog_format: on
