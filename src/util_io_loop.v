// +FHEADER-------------------------------------------------------------------------------
// Copyright (c) 2024 john_tito. All rights reserved.
// ---------------------------------------------------------------------------------------
// Author        : john_tito
// Module Name   : util_io_loop
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

module util_io_loop #(
    parameter         INPUT_IO_WIDTH  = 32,
    parameter         OUTPUT_IO_WIDTH = 32,
    parameter integer BASE_BAUD_DIV   = 8
) (
    input wire clk,
    input wire rstn,

    input wire        enable,
    input wire [11:0] baud_freq,
    input wire [15:0] baud_limit,

    input  wire [4 : 0] stream_pkt_dest,    //
    input  wire [ 31:0] stream_pkt_gap,     //
    input  wire [ 31:0] stream_pkt_num,     //
    input  wire [ 31:0] stream_trans_len,   //
    input  wire [7 : 0] stream_start_from,  //
    input  wire [7 : 0] stream_inc,         //
    input  wire         stream_fix,         //
    input  wire         stream_start,       //
    output wire         stream_busy,        //

    input  wire [OUTPUT_IO_WIDTH-1:0] io_default,
    input  wire [OUTPUT_IO_WIDTH-1:0] io_force_default,
    output reg  [OUTPUT_IO_WIDTH-1:0] io_o,
    input  wire [ INPUT_IO_WIDTH-1:0] io_i,
    output wire [ INPUT_IO_WIDTH-1:0] io_i_r,
    output wire [ INPUT_IO_WIDTH-1:0] io_state,
    output wire [ INPUT_IO_WIDTH-1:0] io_state_valid
);

    wire [                 7:0] s_tdata;
    wire                        s_tvalid;
    wire                        s_tready;
    wire                        s_tactive;

    wire [                 7:0] m_tdata            [(INPUT_IO_WIDTH-1):0];
    wire [(INPUT_IO_WIDTH-1):0] m_tvalid;
    reg  [(INPUT_IO_WIDTH-1):0] m_tready;
    wire [(INPUT_IO_WIDTH-1):0] m_tactive;
    reg  [(INPUT_IO_WIDTH-1):0] last_tx_latched;
    reg  [                 7:0] last_tx_data       [(INPUT_IO_WIDTH-1):0];

    wire [                 6:0] line_config = 7'h3;
    reg  [                 2:0] rxd_i = 3'b111;

    reg  [(INPUT_IO_WIDTH-1):0] err;
    reg  [(INPUT_IO_WIDTH-1):0] err_valid;

    wire                        txd;
    reg  [(INPUT_IO_WIDTH-1):0] rxd                [                 2:0];

    assign s_tactive      = s_tready & s_tvalid;
    assign m_tactive      = m_tready & m_tvalid;
    assign io_i_r         = rxd[2];
    assign io_state       = err;
    assign io_state_valid = err_valid;

    always @(posedge clk) begin
        if (!rstn) begin
            rxd[0] <= 0;
            rxd[1] <= 0;
            rxd[2] <= 0;
        end else begin
            rxd[0] <= io_i;
            rxd[1] <= rxd[0];
            rxd[2] <= rxd[1];
        end
    end

    util_stream_master #(
        .TBYTE_NUM(1)
    ) util_stream_master_inst (
        .clk          (clk),
        .rstn         (rstn),
        .pkt_dest     (stream_pkt_dest),
        .pkt_gap      (stream_pkt_gap),
        .pkt_num      (stream_pkt_num),
        .trans_len    (stream_trans_len),
        .start_from   (stream_start_from),
        .inc          (stream_inc),
        .fix          (stream_fix),
        .stream_start (stream_start),
        .stream_busy  (stream_busy),
        .m_axis_tvalid(s_tvalid),
        .m_axis_tready(s_tready),
        .m_axis_tdata (s_tdata)
    );

    uart_transmitter #(
        .BASE_BAUD_DIV(BASE_BAUD_DIV)
    ) uart_transmitter_inst (
        .clk       (clk),
        .rst       (~rstn),
        .enable    (enable),
        .clr       (1'b0),
        .lcr       (line_config),
        .baud_freq (baud_freq),
        .baud_limit(baud_limit),
        .sts_busy  (),
        .sts_txcnt (),
        .tx_oe     (),
        .tx_d      (txd),
        .tx_clk    (),
        .s_tdata   (s_tdata),
        .s_tvalid  (s_tvalid),
        .s_tready  (s_tready)
    );

    genvar ii;
    generate
        for (ii = 0; ii < INPUT_IO_WIDTH; ii = ii + 1) begin


            uart_receiver #(
                .BASE_BAUD_DIV(BASE_BAUD_DIV)
            ) uart_receiver_inst (
                .clk              (clk),
                .rst              (~rstn),
                .enable           (enable),
                .clr              (1'b0),
                .lcr              (line_config[5:0]),
                .baud_freq        (baud_freq),
                .baud_limit       (baud_limit),
                .srx_i            (rxd[2][ii]),
                .sts_rxcnt        (),
                .sts_overflow     (),
                .sts_break_error  (),
                .sts_parity_error (),
                .sts_framing_error(),
                .sts_busy         (),
                .m_tdata          (m_tdata[ii]),
                .m_tvalid         (m_tvalid[ii]),
                .m_tready         (m_tready[ii])
            );

            always @(posedge clk) begin
                if (~rstn || ~enable) begin
                    m_tready[ii]        <= 1'b0;
                    last_tx_data[ii]    <= 8'b0;
                    err_valid[ii]       <= 1'b0;
                    err[ii]             <= 1'b0;
                    last_tx_latched[ii] <= 1'b0;
                end else begin
                    m_tready[ii] <= 1'b1;

                    if (s_tactive) begin
                        last_tx_data[ii] <= s_tdata;
                    end

                    err_valid[ii] <= m_tactive[ii] & last_tx_latched[ii];
                    if (m_tactive[ii] & last_tx_latched[ii]) begin
                        err[ii] <= (last_tx_data[ii] != m_tdata[ii]);
                    end

                    if (s_tactive) begin
                        last_tx_latched[ii] <= 1'b1;
                    end else if (m_tactive[ii]) begin
                        last_tx_latched[ii] <= 1'b0;
                    end

                end
            end
        end
    endgenerate

    always @(posedge clk) begin
        if (!rstn) begin
            io_o <= io_default;
        end else begin
            if (enable) begin
                io_o <= (~io_force_default & {OUTPUT_IO_WIDTH{txd}}) | ((io_force_default) & io_default);
            end else begin
                io_o <= io_default;
            end
        end
    end

endmodule

// verilog_format: off
`resetall
// verilog_format: on
