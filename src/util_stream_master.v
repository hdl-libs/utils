// +FHEADER-------------------------------------------------------------------------------
// Copyright (c) 2024 john_tito. All rights reserved.
// ---------------------------------------------------------------------------------------
// Author        : john_tito
// Module Name   : util_stream_master
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

module util_stream_master #(
    parameter TBYTE_NUM  = 16,
    parameter DEST_WIDTH = 1,
    parameter ID_WIDTH   = 1
) (
    input wire clk,  //
    input wire rstn, //

    input wire [              4 : 0] pkt_dest,    //
    input wire [               31:0] pkt_gap,     //
    input wire [               31:0] pkt_num,     //
    input wire [               31:0] trans_len,   //
    input wire [               31:0] trans_gap,   //
    input wire [(TBYTE_NUM*8-1) : 0] start_from,  //
    input wire [(TBYTE_NUM*8-1) : 0] inc,         //
    input wire                       fix,         //

    input  wire stream_start,  //
    output reg  stream_busy,   //

    output reg                        m_axis_tvalid,
    input  wire                       m_axis_tready,
    output reg  [(TBYTE_NUM*8-1) : 0] m_axis_tdata,
    output reg  [  (TBYTE_NUM-1) : 0] m_axis_tkeep,
    output reg                        m_axis_tlast,
    output reg  [       ID_WIDTH-1:0] m_axis_tid,
    output reg  [     DEST_WIDTH-1:0] m_axis_tdest
);

    localparam FSM_IDLE = 8'h0;
    localparam FSM_PREPARE = 8'h1;
    localparam FSM_PKT = 8'h2;
    localparam FSM_TRANS_GAP = 8'h4;
    localparam FSM_PKT_LAST = 8'h8;
    localparam FSM_GAP = 8'h10;
    localparam FSM_END = 8'h20;

    reg  [              4 : 0] pkt_dest_int;
    reg  [               31:0] pkt_gap_int;
    reg  [               31:0] pkt_num_int;
    reg  [               31:0] trans_len_int;
    reg  [               31:0] trans_gap_int;
    reg  [(TBYTE_NUM*8-1) : 0] start_from_int;
    reg  [(TBYTE_NUM*8-1) : 0] inc_int;
    reg                        fix_int;

    reg  [                2:0] stream_start_d;

    reg  [               31:0] pkt_cnt;
    wire                       pkt_end;

    reg  [               31:0] pkt_gap_cnt;
    wire                       pkt_gap_end;

    reg  [               31:0] trans_cnt;
    wire                       trans_end;

    reg  [               31:0] trans_gap_cnt;
    wire                       trans_gap_end;

    reg  [                7:0] cstate;
    reg  [                7:0] nstate;

    wire                       active;

    assign active        = m_axis_tready & m_axis_tvalid;
    assign trans_end     = (trans_cnt + 2 >= trans_len_int) ? 1'b1 : 1'b0;
    assign pkt_end       = (pkt_cnt == (pkt_num_int - 1)) ? 1'b1 : 1'b0;
    assign pkt_gap_end   = (pkt_gap_cnt == (pkt_gap_int - 1)) ? 1'b1 : 1'b0;
    assign trans_gap_end = (trans_gap_cnt + 1 >= trans_gap_int) ? 1'b1 : 1'b0;

    always @(posedge clk) begin
        if (!rstn) begin
            pkt_dest_int   <= 0;
            pkt_gap_int    <= 0;
            pkt_num_int    <= 0;
            trans_len_int  <= 0;
            trans_gap_int  <= 0;
            start_from_int <= 0;
            inc_int        <= 0;
            fix_int        <= 0;
        end else begin
            case (nstate)
                FSM_IDLE: begin
                    if (stream_start) begin
                        pkt_dest_int   <= pkt_dest;
                        pkt_gap_int    <= pkt_gap;
                        pkt_num_int    <= pkt_num;
                        trans_gap_int  <= trans_gap;
                        trans_len_int  <= trans_len;
                        start_from_int <= start_from;
                        inc_int        <= inc;
                        fix_int        <= fix;
                    end
                end
                default: begin
                    pkt_dest_int   <= pkt_dest_int;
                    pkt_gap_int    <= pkt_gap_int;
                    pkt_num_int    <= pkt_num_int;
                    trans_len_int  <= trans_len_int;
                    trans_gap_int  <= trans_gap_int;
                    start_from_int <= start_from_int;
                    inc_int        <= inc_int;
                    fix_int        <= fix_int;
                end
            endcase
        end
    end

    always @(posedge clk) begin
        if (!rstn) begin
            cstate <= FSM_IDLE;
        end else begin
            cstate <= nstate;
        end
    end

    always @(posedge clk) begin
        if (!rstn) begin
            stream_start_d <= 3'b000;
        end else begin
            if (trans_len_int > 0 && pkt_num_int > 0 && pkt_gap > 0) begin
                stream_start_d <= {stream_start_d[0] & ~stream_start_d[1], stream_start_d[0], stream_start};
            end else begin
                stream_start_d <= 3'b000;
            end
        end
    end

    always @(*) begin
        if (!rstn) begin
            nstate = FSM_IDLE;
        end else begin
            case (cstate)
                FSM_IDLE: begin
                    if (stream_start_d[2]) begin
                        nstate = FSM_PREPARE;
                    end else begin
                        nstate = FSM_IDLE;
                    end
                end
                FSM_PREPARE: begin
                    if (trans_len_int < 2) begin
                        nstate = FSM_PKT_LAST;
                    end else begin
                        nstate = FSM_PKT;
                    end
                end
                FSM_PKT: begin
                    if (active) begin
                        if (trans_gap_end) begin
                            if (trans_end) begin
                                nstate = FSM_PKT_LAST;
                            end else begin
                                nstate = FSM_PKT;
                            end
                        end else begin
                            nstate = FSM_TRANS_GAP;
                        end
                    end
                end
                FSM_TRANS_GAP: begin
                    if (trans_gap_end) begin
                        if (trans_end) begin
                            nstate = FSM_PKT_LAST;
                        end else begin
                            nstate = FSM_PKT;
                        end
                    end else begin
                        nstate = FSM_TRANS_GAP;
                    end
                end
                FSM_PKT_LAST: begin
                    if (pkt_end && active) begin
                        nstate = FSM_END;
                    end else begin
                        nstate = FSM_GAP;
                    end
                end
                FSM_GAP: begin
                    if (pkt_gap_end) begin
                        nstate = FSM_PKT;
                    end else begin
                        nstate = FSM_GAP;
                    end
                end
                default: nstate = FSM_IDLE;
            endcase
        end
    end

    always @(posedge clk) begin
        if (!rstn) begin
            trans_cnt <= 0;
        end else begin
            case (nstate)
                FSM_PKT, FSM_TRANS_GAP, FSM_PKT_LAST: trans_cnt <= active ? trans_cnt + 1 : trans_cnt;
                default:                              trans_cnt <= 0;
            endcase
        end
    end

    always @(posedge clk) begin
        if (!rstn) begin
            pkt_cnt <= 0;
        end else begin
            case (nstate)
                FSM_PREPARE: pkt_cnt <= 0;
                default: begin
                    if (pkt_gap_end) begin
                        pkt_cnt <= pkt_cnt + 1;
                    end else begin
                        pkt_cnt <= pkt_cnt;
                    end
                end
            endcase
        end
    end

    always @(posedge clk) begin
        if (!rstn) begin
            trans_gap_cnt <= 0;
        end else begin
            case (nstate)
                FSM_IDLE, FSM_PREPARE: trans_gap_cnt <= 0;
                FSM_PKT:               trans_gap_cnt <= 1;
                FSM_TRANS_GAP: begin
                    if (trans_gap_cnt < trans_gap_int) begin
                        trans_gap_cnt <= trans_gap_cnt + 1;
                    end else begin
                        trans_gap_cnt <= 0;
                    end
                end
            endcase
        end
    end

    always @(posedge clk) begin
        if (!rstn) begin
            pkt_gap_cnt <= 0;
        end else begin
            case (nstate)
                FSM_IDLE, FSM_PREPARE: pkt_gap_cnt <= 0;
                default: begin
                    if (pkt_gap_cnt < pkt_gap_int) begin
                        pkt_gap_cnt <= pkt_gap_cnt + 1;
                    end else begin
                        pkt_gap_cnt <= 0;
                    end
                end
            endcase
        end
    end

    always @(posedge clk) begin
        if (!rstn) begin
            m_axis_tvalid <= 1'b0;
        end else begin
            case (nstate)
                FSM_PKT, FSM_PKT_LAST: m_axis_tvalid <= 1'b1;
                default:               m_axis_tvalid <= 1'b0;
            endcase
        end
    end

    always @(posedge clk) begin
        if (!rstn) begin
            m_axis_tdata <= 0;
        end else begin
            case (nstate)
                FSM_PREPARE:                    m_axis_tdata <= start_from_int;
                FSM_PKT, FSM_PKT_LAST, FSM_GAP: m_axis_tdata <= (~fix_int & active) ? (m_axis_tdata + inc_int) : m_axis_tdata;
                default:                        m_axis_tdata <= m_axis_tdata;
            endcase
        end
    end

    always @(posedge clk) begin
        if (!rstn) begin
            m_axis_tlast <= 1'b0;
        end else begin
            case (nstate)
                FSM_PKT_LAST: m_axis_tlast <= 1'b1;
                default:      m_axis_tlast <= 1'b0;
            endcase
        end
    end

    always @(posedge clk) begin
        if (!rstn) begin
            m_axis_tid <= 0;
        end else begin
            case (nstate)
                FSM_PREPARE:  m_axis_tid <= 0;
                FSM_PKT_LAST: m_axis_tid <= m_axis_tid + 1;
                default:      m_axis_tid <= m_axis_tid;
            endcase
        end
    end

    always @(posedge clk) begin
        if (!rstn) begin
            m_axis_tdest <= 0;
        end else begin
            case (nstate)
                FSM_PREPARE: m_axis_tdest <= pkt_dest_int;
                default:     m_axis_tdest <= m_axis_tdest;
            endcase
        end
    end

    always @(posedge clk) begin
        if (!rstn) begin
            m_axis_tkeep <= 0;
        end else begin
            m_axis_tkeep <= {TBYTE_NUM{1'b1}};
        end
    end

    always @(posedge clk) begin
        if (!rstn) begin
            stream_busy <= 1'b1;
        end else begin
            case (nstate)
                FSM_IDLE: stream_busy <= 1'b0;
                default:  stream_busy <= 1'b1;
            endcase
        end
    end

endmodule

// verilog_format: off
`resetall
// verilog_format: on
