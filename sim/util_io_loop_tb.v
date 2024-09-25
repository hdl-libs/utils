// +FHEADER-------------------------------------------------------------------------------
// Copyright (c) 2024 john_tito. All rights reserved.
// ---------------------------------------------------------------------------------------
// Author        : john_tito
// Module Name   : util_io_loop_tb
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

module util_io_loop_tb;

    // Parameters
    localparam real TIMEPERIOD = 13.888888;
    localparam integer BASE_BAUD_DIV = 8;
    localparam integer OUTPUT_IO_WIDTH = 8;
    localparam integer INPUT_IO_WIDTH = 8;

    //Ports
    reg                        clk = 1'b0;
    reg                        rstn = 1'b1;
    reg                        enable = 1'b0;
    reg  [               11:0] baud_freq = 1'b0;
    reg  [               15:0] baud_limit = 1'b0;
    wire                       txd;
    reg                        rxd = 1'b1;
    wire                       cmp_error;
    wire                       cmp_error_valid;

    reg  [              4 : 0] stream_pkt_dest = 0;
    reg  [               31:0] stream_pkt_gap = 512;
    reg  [               31:0] stream_pkt_num = 64;
    reg  [               31:0] stream_trans_len = 1;
    reg  [              7 : 0] stream_start_from = 0;
    reg  [              7 : 0] stream_inc = 1;
    reg                        stream_fix = 0;
    reg                        stream_start = 0;
    wire                       stream_busy;

    reg  [OUTPUT_IO_WIDTH-1:0] io_default = 5;
    reg  [OUTPUT_IO_WIDTH-1:0] io_force_default = 5;
    wire [OUTPUT_IO_WIDTH-1:0] io_o;
    reg  [ INPUT_IO_WIDTH-1:0] io_i = 0;
    wire [ INPUT_IO_WIDTH-1:0] io_i_r;
    wire [ INPUT_IO_WIDTH-1:0] io_state;
    wire                       io_state_valid;

    util_io_loop #(
        .INPUT_IO_WIDTH (INPUT_IO_WIDTH),
        .OUTPUT_IO_WIDTH(OUTPUT_IO_WIDTH),
        .BASE_BAUD_DIV  (BASE_BAUD_DIV)
    ) util_io_loop_inst (
        .clk              (clk),
        .rstn             (rstn),
        .enable           (enable),
        .baud_freq        (baud_freq),
        .baud_limit       (baud_limit),
        .stream_pkt_dest  (stream_pkt_dest),
        .stream_pkt_gap   (stream_pkt_gap),
        .stream_pkt_num   (stream_pkt_num),
        .stream_trans_len (stream_trans_len),
        .stream_start_from(stream_start_from),
        .stream_inc       (stream_inc),
        .stream_fix       (stream_fix),
        .stream_start     (stream_start),
        .stream_busy      (stream_busy),
        .io_default       (io_default),
        .io_force_default (io_force_default),
        .io_o             (io_o),
        .io_i             (io_i),
        .io_i_r           (io_i_r),
        .io_state         (io_state),
        .io_state_valid   (io_state_valid)
    );

    always #(TIMEPERIOD / 2) clk = !clk;

    always @(posedge clk, negedge rstn) begin
        if (!rstn) begin
            io_i <= {INPUT_IO_WIDTH{1'b1}};
        end else begin
            io_i <= $random();
        end
    end

    initial begin
        enable = 1'b0;
        #50;
        baud_freq  = 12'd8;
        baud_limit = 16'd1;
        #50;
        enable = 1'b1;
        #50;
        stream_start = 1'b0;
        #50;
        stream_start = 1'b1;
        #100000;
        $finish;
    end

    // reset block
    initial begin
        rstn = 1'b0;
        #(TIMEPERIOD * 16);
        rstn = 1'b1;
    end

    // record block
    initial begin
        $dumpfile("sim/test_tb.vcd");
        $dumpvars(0, util_io_loop_tb);
    end

endmodule


// verilog_format: off
`resetall
// verilog_format: on
