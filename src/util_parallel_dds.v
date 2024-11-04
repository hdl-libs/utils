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
// Module Name   : util_parallel_dds
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

module util_parallel_dds #(
    parameter CHANNEL_NUMS = 16,  // 通道数量
    parameter DDS_DATA_DW  = 16,  // DDS 数据宽度
    parameter DDS_PHASE_DW = 32,  // DDS 相位控制字宽度
    parameter DDS_LATENCY  = 8    // DDS 输出延迟
) (
    input  wire                                clk,
    input  wire                                rstn,
    input  wire                                dds_en,
    input  wire [            DDS_PHASE_DW-1:0] dds_phase_offse,
    input  wire [            DDS_PHASE_DW-1:0] dds_phase_incre,
    output reg                                 m_axis_valid,
    output reg  [CHANNEL_NUMS*DDS_DATA_DW-1:0] m_axis_tdata_i,
    output reg  [CHANNEL_NUMS*DDS_DATA_DW-1:0] m_axis_tdata_q
);

    reg  [(DDS_LATENCY+2):0] dds_en_dly;
    reg  [ DDS_PHASE_DW-1:0] poff                 [CHANNEL_NUMS-1:0];
    reg  [ DDS_PHASE_DW-1:0] pinc                 [CHANNEL_NUMS-1:0];
    wire [2*DDS_DATA_DW-1:0] m_axis_data_tdata    [CHANNEL_NUMS-1:0];
    wire [ CHANNEL_NUMS-1:0] m_axis_data_tvalid;
    wire [ CHANNEL_NUMS-1:0] s_axis_config_tvalid;

    always @(posedge clk) begin
        if (!rstn) begin
            dds_en_dly <= 0;
        end else begin
            if (dds_en) begin
                dds_en_dly <= dds_en_dly << 1 | 1'b1;
            end else begin
                dds_en_dly <= 0;
            end
        end
    end

    generate
        genvar index;
        for (index = 0; index < CHANNEL_NUMS; index = index + 1) begin : f_step
            always @(posedge clk) begin
                if (!rstn) begin
                    pinc[index] <= {DDS_PHASE_DW{1'b0}};
                    poff[index] <= {DDS_PHASE_DW{1'b0}};
                end else begin
                    if (dds_en_dly == 1) begin
                        pinc[index] <= dds_phase_incre * CHANNEL_NUMS;
                        poff[index] <= dds_phase_offse + (dds_phase_incre * index);
                    end
                end
            end

            assign s_axis_config_tvalid[index] = (dds_en_dly == 'd3) ? 1'b1 : 1'b0;

            dds_compiler_0 inst_dds_compiler (
                .aclk                (clk),
                .aresetn             (dds_en_dly[1]),
                .m_axis_data_tdata   (m_axis_data_tdata[index]),
                .m_axis_data_tvalid  (m_axis_data_tvalid[index]),
                .s_axis_config_tdata ({poff[index], pinc[index]}),
                .s_axis_config_tvalid(s_axis_config_tvalid[index])
            );

            always @(posedge clk) begin
                if (!rstn) begin
                    m_axis_tdata_q[DDS_DATA_DW*index+:DDS_DATA_DW] <= {DDS_DATA_DW{1'b0}};
                    m_axis_tdata_i[DDS_DATA_DW*index+:DDS_DATA_DW] <= {DDS_DATA_DW{1'b0}};
                end else begin
                    m_axis_tdata_q[DDS_DATA_DW*index+:DDS_DATA_DW] <= (m_axis_data_tdata[index][DDS_DATA_DW+:DDS_DATA_DW]) + ({DDS_DATA_DW{1'b1}} << (DDS_DATA_DW - 1));
                    m_axis_tdata_i[DDS_DATA_DW*index+:DDS_DATA_DW] <= (m_axis_data_tdata[index][0+:DDS_DATA_DW]) + ({DDS_DATA_DW{1'b1}} << (DDS_DATA_DW - 1));
                end
            end
        end
    endgenerate

    always @(posedge clk) begin
        if (!rstn) begin
            m_axis_valid <= 1'b0;
        end else begin
            m_axis_valid <= (&m_axis_data_tvalid) & (&dds_en_dly);
        end
    end

endmodule

// verilog_format: off
`resetall
// verilog_format: on
