// +FHEADER-------------------------------------------------------------------------------
// Copyright (c) 2024 john_tito. All rights reserved.
// ---------------------------------------------------------------------------------------
// Author        : john_tito
// Module Name   : util_stream_master_tb
// ---------------------------------------------------------------------------------------
// Revision      : 1.0
// Description   : add description here
// Revision 1.00 - File Created
// ---------------------------------------------------------------------------------------
// Reuse Issue   :
// Synthesizable : Yes
// Instantiations: add dependencies here
// Clock Domains : clk
// Reset Strategy: sync reset, active low Level
// Other :
// -FHEADER-------------------------------------------------------------------------------

// verilog_format: off
`resetall
`timescale 1ns / 1ps
`default_nettype none
// verilog_format: on


module util_stream_master_tb;

    // Parameters
    localparam TBYTE_NUM = 4;

    //Ports
    reg                       clk = 0;
    reg                       rstn = 0;
    reg [              4 : 0] pkt_dest = 0;
    reg [               31:0] pkt_gap = 512;
    reg [               31:0] pkt_num = 32'hFFFFFFFF;
    reg [               31:0] trans_len = 32'd8;
    reg [(TBYTE_NUM*8-1) : 0] start_from = 32'd0;
    reg [(TBYTE_NUM*8-1) : 0] inc = 32'd1;
    reg                       fix = 1'b0;
    reg                       stream_start = 1'b0;
    reg                       m_axis_tready = 1'b1;

    util_stream_master #(
        .TBYTE_NUM(TBYTE_NUM)
    ) util_stream_master_inst (
        .clk          (clk),
        .rstn         (rstn),
        .pkt_dest     (pkt_dest),
        .pkt_gap      (pkt_gap),
        .pkt_num      (pkt_num),
        .trans_len    (trans_len >> 2),
        .start_from   (start_from),
        .inc          (inc),
        .fix          (fix),
        .stream_start (stream_start),
        .stream_busy  (),
        .m_axis_tvalid(),
        .m_axis_tready(m_axis_tready),
        .m_axis_tdata (),
        .m_axis_tkeep (),
        .m_axis_tlast (),
        .m_axis_tid   (),
        .m_axis_tdest ()
    );

    always #5 clk = !clk;

    initial begin
        #50 stream_start = 1'b1;
        #1000000;
        $finish;
    end

    initial begin
        #20 rstn = 1'b1;
    end

    // record block
    initial begin
        begin
            $dumpfile("sim/test_tb.vcd");
            $dumpvars(0, util_stream_master_tb);
        end
    end

endmodule


// verilog_format: off
`resetall
// verilog_format: on
