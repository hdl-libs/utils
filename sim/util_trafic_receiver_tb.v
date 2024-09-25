// +FHEADER-------------------------------------------------------------------------------
// Copyright (c) 2024 john_tito. All rights reserved.
// ---------------------------------------------------------------------------------------
// Author        : john_tito
// Module Name   : util_trafic_receiver_tb
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


module util_trafic_receiver_tb;

    // Parameters
    // Parameters
    localparam CLK_FREQ = 100_000_000;
    localparam real TIMEPERIOD = 1000_000_000 / CLK_FREQ;
    localparam SPEED = 2500_000;
    localparam TBYTE_NUM = 8;
    localparam ID_WIDTH = 1;
    localparam DEST_WIDTH = 2;

    //Ports
    reg                        clk = 0;
    reg                        rst = 0;
    reg                        en = 0;
    wire                       axis_tvalid[1:0];
    wire                       axis_tready[1:0];
    wire [(TBYTE_NUM*8-1) : 0] axis_tdata [1:0];
    wire [  (TBYTE_NUM-1) : 0] axis_tkeep [1:0];
    wire                       axis_tlast [1:0];
    wire [   (ID_WIDTH-1) : 0] axis_tid   [1:0];
    wire [ (DEST_WIDTH-1) : 0] axis_tdest [1:0];
    wire                       error;

    util_trafic_generator #(
        .CLK_FREQ  (CLK_FREQ),
        .SPEED     (SPEED),
        .TBYTE_NUM (TBYTE_NUM),
        .ID_WIDTH  (ID_WIDTH),
        .DEST_WIDTH(DEST_WIDTH)
    ) util_trafic_generator_inst (
        .clk          (clk),
        .rst          (rst),
        .en           (en),
        .m_axis_tvalid(axis_tvalid[0]),
        .m_axis_tready(axis_tready[0]),
        .m_axis_tdata (axis_tdata[0]),
        .m_axis_tkeep (axis_tkeep[0]),
        .m_axis_tlast (axis_tlast[0]),
        .m_axis_tid   (axis_tid[0]),
        .m_axis_tdest (axis_tdest[0])
    );

    util_trafic_monitor #(
        .CLK_FREQ   (CLK_FREQ),
        .REPORT_TIME(1000_000),
        .TBYTE_NUM  (TBYTE_NUM),
        .ID_WIDTH   (ID_WIDTH),
        .DEST_WIDTH (DEST_WIDTH)
    ) util_trafic_monitor_inst (
        .clk          (clk),
        .rst          (rst),
        .en           (en),
        .trafic_flow  (),
        .s_axis_tvalid(axis_tvalid[0]),
        .s_axis_tready(axis_tready[0]),
        .s_axis_tdata (axis_tdata[0]),
        .s_axis_tkeep (axis_tkeep[0]),
        .s_axis_tlast (axis_tlast[0]),
        .s_axis_tid   (axis_tid[0]),
        .s_axis_tdest (axis_tdest[0]),
        .m_axis_tvalid(axis_tvalid[1]),
        .m_axis_tready(axis_tready[1]),
        .m_axis_tdata (axis_tdata[1]),
        .m_axis_tkeep (axis_tkeep[1]),
        .m_axis_tlast (axis_tlast[1]),
        .m_axis_tid   (axis_tid[1]),
        .m_axis_tdest (axis_tdest[1])
    );

    util_trafic_receiver #(
        .CLK_FREQ  (CLK_FREQ),
        .SPEED     (SPEED),
        .TBYTE_NUM (TBYTE_NUM),
        .ID_WIDTH  (ID_WIDTH),
        .DEST_WIDTH(DEST_WIDTH)
    ) util_trafic_receiver_inst (
        .clk          (clk),
        .rst          (rst),
        .en           (en),
        .s_axis_tvalid(axis_tvalid[1]),
        .s_axis_tready(axis_tready[1]),
        .s_axis_tdata (axis_tdata[1]),
        .s_axis_tkeep (axis_tkeep[1]),
        .s_axis_tlast (axis_tlast[1]),
        .s_axis_tid   (axis_tid[1]),
        .s_axis_tdest (axis_tdest[1]),
        .error        (error)
    );

    always #5 clk = !clk;

    initial begin
        en = 0;
        #(TIMEPERIOD * 1000);
        en = 1;
        #(TIMEPERIOD * 1000);
        en = 0;
        #(TIMEPERIOD * 1000);
        $finish;
    end

    // reset block
    initial begin
        rst = 1'b1;
        #(TIMEPERIOD * 16);
        rst = 1'b0;
    end


    // record block
    initial begin
        begin
            $dumpfile("sim/test_tb.vcd");
            $dumpvars(0, util_trafic_receiver_tb);
        end
    end
endmodule

// verilog_format: off
`resetall
// verilog_format: on
