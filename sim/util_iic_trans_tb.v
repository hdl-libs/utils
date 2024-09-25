// +FHEADER-------------------------------------------------------------------------------
// Copyright (c) 2024 john_tito. All rights reserved.
// ---------------------------------------------------------------------------------------
// Author        : john_tito
// Module Name   :
// ---------------------------------------------------------------------------------------
// Revision      : 1.0
// Description   : add description here
// Revision 1.00 - File Created
// ---------------------------------------------------------------------------------------
// Reuse Issue   :
// Synthesizable : Yes
// Instantiations: add dependencies here
// Clock Domains : clk
// Reset Strategy: Sync Reset
// Other :
// -FHEADER-------------------------------------------------------------------------------

// verilog_format: off
`resetall
`timescale 1ns / 1ps
`default_nettype none
// verilog_format: on

module util_iic_trans_tb;

    // Parameters
    localparam real TIMEPERIOD = 5;
    localparam SLAVE_NUM = 2;

    // Ports
    reg                  rstn;
    wire                 s_scl_i;
    wire                 s_sda_i;
    reg                  s_scl_o = 1'b1;
    reg                  s_scl_t = 1'b1;
    reg                  s_sda_o = 1'b1;
    reg                  s_sda_t = 1'b1;

    reg  [SLAVE_NUM-1:0] cs_n = 2'b11;
    reg  [SLAVE_NUM-1:0] m_scl_i = 2'b11;
    wire [SLAVE_NUM-1:0] m_scl_o;
    wire [SLAVE_NUM-1:0] m_scl_t;
    reg  [SLAVE_NUM-1:0] m_sda_i = 2'b11;
    wire [SLAVE_NUM-1:0] m_sda_o;
    wire [SLAVE_NUM-1:0] m_sda_t;

    util_iic_trans #(
        .SLAVE_NUM(SLAVE_NUM)
    ) dut (
        .rstn   (rstn),
        .s_scl_i(s_scl_i),
        .s_scl_o(s_scl_o),
        .s_scl_t(s_scl_t),
        .s_sda_i(s_sda_i),
        .s_sda_o(s_sda_o),
        .s_sda_t(s_sda_t),
        .cs_n   (cs_n),
        .m_scl_i(m_scl_i),
        .m_scl_o(m_scl_o),
        .m_scl_t(m_scl_t),
        .m_sda_i(m_sda_i),
        .m_sda_o(m_sda_o),
        .m_sda_t(m_sda_t)
    );

    initial begin
        begin
            cs_n = 2'b11;
            #10000;
            cs_n = 2'b10;
            #10000;
            cs_n = 2'b01;
            #10000;
            cs_n = 2'b11;
            #10000;
            $finish;
        end
    end

    initial begin
        rstn = 1'b0;
        #(TIMEPERIOD * 32);
    end

    // record block
    initial begin
        $dumpfile("sim/test_tb.vcd");
        $dumpvars(0, util_iic_trans_tb);
    end


endmodule

// verilog_format: off
`resetall
// verilog_format: on
