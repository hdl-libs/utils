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
// Module Name   : util_parallel_dds_tb
// ---------------------------------------------------------------------------------------
// Revision      : 1.0
// Description   : File Created
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

module util_parallel_dds_tb;

    localparam USER_CLK_FREQ = 200_000_000;
    localparam TIMEPERIOD = 1000_000_000 / USER_CLK_FREQ;

    // Parameters
    localparam CHANNEL_NUMS = 16;  // 通道数量
    localparam DDS_DATA_DW = 16;  // DDS 数据宽度
    localparam DDS_PHASE_DW = 32;  // DDS 相位控制字宽度
    localparam DDS_LATENCY = 8;  // DDS 输出延迟
    localparam USE_ILA = "false";  // ILA 使能

    //Ports
    reg                                 clk = 0;
    reg                                 rstn = 0;
    reg                                 dds_en = 0;
    reg  [            DDS_PHASE_DW-1:0] dds_phase_offse = 0;
    reg  [            DDS_PHASE_DW-1:0] dds_phase_incre = 0;
    wire                                m_axis_valid;
    wire [CHANNEL_NUMS*DDS_DATA_DW-1:0] m_axis_tdata_i;
    wire [CHANNEL_NUMS*DDS_DATA_DW-1:0] m_axis_tdata_q;

    util_parallel_dds #(
        .CHANNEL_NUMS(CHANNEL_NUMS),
        .DDS_DATA_DW (DDS_DATA_DW),
        .DDS_PHASE_DW(DDS_PHASE_DW),
        .DDS_LATENCY (DDS_LATENCY),
        .USE_ILA     (USE_ILA)
    ) util_parallel_dds_inst (
        .clk            (clk),
        .rstn           (rstn),
        .dds_en         (dds_en),
        .dds_phase_offse(dds_phase_offse),
        .dds_phase_incre(dds_phase_incre),
        .m_axis_valid   (m_axis_valid),
        .m_axis_tdata_i (m_axis_tdata_i),
        .m_axis_tdata_q (m_axis_tdata_q)
    );


    initial begin
        begin
            #(TIMEPERIOD * 1000);
            dds_phase_offse = 16'h0000;
            dds_phase_incre = 16'h8000;
            dds_en          = 1;
            #(TIMEPERIOD * 1000);
            dds_en = 0;
            #(TIMEPERIOD * 1000);
            dds_phase_offse = 16'h8000;
            dds_phase_incre = 16'h0000;
            dds_en          = 1;
            #(TIMEPERIOD * 1000);
            dds_en = 0;
            #(TIMEPERIOD * 1);

            dds_en = 1;
            #(TIMEPERIOD * 1);
            dds_en = 0;
            #(TIMEPERIOD * 1);
            dds_en = 1;
            #(TIMEPERIOD * 1);
            dds_en = 0;
            #(TIMEPERIOD * 1000);
            $finish;
        end
    end

    // ***********************************************************************************
    // clock block
    always #(TIMEPERIOD / 2) clk = !clk;

    // reset block
    initial begin
        begin
            rstn = 1'b0;
            #(TIMEPERIOD * 32);
            rstn = 1'b1;
        end
    end

    // record block
    initial begin
        begin
            $dumpfile("sim/test_tb.vcd");
            $dumpvars(0, util_parallel_dds_tb);
        end
    end

endmodule

// verilog_format: off
`resetall
// verilog_format: on
