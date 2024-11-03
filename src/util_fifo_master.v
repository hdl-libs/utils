// ---------------------------------------------------------------------------------------
// Copyright (c) 2024 john_tito All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// ---------------------------------------------------------------------------------------
// +FHEADER-------------------------------------------------------------------------------
// Author        : john_tito
// Module Name   : util_fifo_master
// ---------------------------------------------------------------------------------------
// Revision      : 1.0
// Description   : this module is a simple FIFO master
// ---------------------------------------------------------------------------------------
// Synthesizable : Yes
// Clock Domains : clk
// Reset Strategy: sync reset
// -FHEADER-------------------------------------------------------------------------------

// verilog_format: off
`resetall
`timescale 1ns / 1ps
`default_nettype none
// verilog_format: on

module util_fifo_master #(
    parameter TBYTE_NUM = 16
) (
    input wire clk,  //
    input wire rstn, //

    input wire [               31:0] pkt_gap,     // gap between packets
    input wire [               31:0] pkt_num,     // packet number
    input wire [               31:0] trans_len,   // transaction length
    input wire [(TBYTE_NUM*8-1) : 0] start_from,  // start from
    input wire [(TBYTE_NUM*8-1) : 0] inc,         // increment
    input wire                       fix,         // fixed data

    input  wire stream_start,  // start stream
    output reg  stream_busy,   // stream busy

    input  wire                       fifo_rd,     // fifo read request
    output reg                        fifo_empty,  // fifo empty flag
    output reg  [(TBYTE_NUM*8-1) : 0] fifo_dout    // fifo data output
);

    localparam FSM_IDLE = 8'h0;
    localparam FSM_PREPARE = 8'h1;
    localparam FSM_PKT = 8'h2;
    localparam FSM_GAP = 8'h4;
    localparam FSM_END = 8'h8;

    reg  [31:0] pkt_cnt;
    wire        pkt_end;

    reg  [31:0] trans_cnt;
    wire        trans_end;

    reg  [31:0] gap_cnt;
    wire        gap_end;

    reg  [ 7:0] c_state;
    reg  [ 7:0] n_state;

    wire        active;

    assign active    = ~fifo_empty & fifo_rd;
    assign trans_end = (trans_cnt == (trans_len - 1)) ? 1'b1 : 1'b0;
    assign pkt_end   = (pkt_cnt == (pkt_num - 1)) ? 1'b1 : 1'b0;
    assign gap_end   = (gap_cnt == (pkt_gap - 1)) ? 1'b1 : 1'b0;

    always @(posedge clk) begin
        if (!rstn) begin
            c_state <= FSM_IDLE;
        end else begin
            c_state <= n_state;
        end
    end

    always @(*) begin
        if (!rstn) begin
            n_state = FSM_IDLE;
        end else begin
            case (c_state)
                FSM_IDLE: begin
                    if (stream_start) begin
                        n_state = FSM_PREPARE;
                    end else begin
                        n_state = FSM_IDLE;
                    end
                end
                FSM_PREPARE: begin
                    n_state = FSM_PKT;
                end
                FSM_PKT: begin
                    if (trans_end & active) begin
                        n_state = FSM_GAP;
                    end else begin
                        n_state = FSM_PKT;
                    end
                end
                FSM_GAP: begin
                    if (gap_end) begin
                        if (pkt_end) begin
                            n_state = FSM_END;
                        end else begin
                            n_state = FSM_PKT;
                        end
                    end else begin
                        n_state = FSM_GAP;
                    end
                end
                default: n_state = FSM_IDLE;
            endcase
        end
    end

    always @(posedge clk) begin
        if (!rstn) begin
            trans_cnt <= 0;
        end else begin
            case (n_state)
                FSM_PKT: begin
                    if (active) begin
                        trans_cnt <= trans_cnt + 1;
                    end
                end
                default: begin
                    trans_cnt <= 0;
                end
            endcase
        end
    end

    always @(posedge clk) begin
        if (!rstn) begin
            pkt_cnt <= 0;
        end else begin
            case (n_state)
                FSM_PREPARE: begin
                    pkt_cnt <= 0;
                end
                default: begin
                    if (gap_end) begin
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
            gap_cnt <= 0;
        end else begin
            case (n_state)
                FSM_GAP: begin
                    gap_cnt <= gap_cnt + 1;
                end
                default: begin
                    gap_cnt <= 0;
                end
            endcase
        end
    end

    reg [(TBYTE_NUM*8-1) : 0] dout;
    always @(posedge clk) begin
        if (!rstn) begin
            dout <= start_from;
        end else begin
            case (n_state)
                FSM_PKT: begin
                    if (fix) begin
                        dout <= start_from;
                    end else begin
                        if (active) begin
                            dout <= dout + inc;
                        end else begin
                            dout <= dout;
                        end
                    end
                end
                default: begin
                    dout <= start_from;
                end
            endcase
        end
    end

    always @(posedge clk) begin
        if (!rstn) begin
            fifo_dout <= start_from;
        end else begin
            if (active) begin
                fifo_dout <= dout;
            end
        end
    end

    always @(posedge clk) begin
        if (!rstn) begin
            fifo_empty <= 1'b1;
        end else begin
            case (n_state)
                FSM_PKT: begin
                    fifo_empty <= 1'b0;
                end
                default: begin
                    fifo_empty <= 1'b1;
                end
            endcase
        end
    end

    always @(posedge clk) begin
        if (!rstn) begin
            stream_busy <= 1'b1;
        end else begin
            case (n_state)
                FSM_IDLE: begin
                    stream_busy <= 1'b0;
                end
                default: begin
                    stream_busy <= 1'b1;
                end
            endcase
        end
    end

endmodule

// verilog_format: off
`resetall
// verilog_format: on
