// +FHEADER-------------------------------------------------------------------------------
// Copyright (c) 2024 john_tito. All rights reserved.
// ---------------------------------------------------------------------------------------
// Author        : john_tito
// Module Name   : util_rst_cdc
// ---------------------------------------------------------------------------------------
// Revision      : 1.0
// Description   : add description here
// Revision 1.00 - File Created
// ---------------------------------------------------------------------------------------
// Reuse Issue   :
// Synthesizable : Yes
// Instantiations: add dependencies here
// Clock Domains : dest_clk
// Reset Strategy: None
// Other :
// -FHEADER-------------------------------------------------------------------------------

// verilog_format: off
`resetall
`timescale 1ns / 1ps
`default_nettype none
// verilog_format: on

module util_rst_cdc #(
    parameter DEST_SYNC_FF   = 4,
    parameter INIT_SYNC_FF   = 0,
    parameter SIM_ASSERT_CHK = 0,
    parameter RST_TYPE       = "ASYNC",
    parameter IN_POLARITY    = "ACTIVE_LOW",
    parameter OUT_POLARITY   = "ACTIVE_LOW"
) (
    // Declare the attributes above the port declaration
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 dest_clk CLK" *)
    (* X_INTERFACE_PARAMETER = "ASSOCIATED_RESET dest_out" *)
    input wire dest_clk,  //

    // Declare the attributes above the port declaration
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 src_in RST" *)
    input wire src_in,  //

    // Declare the attributes above the port declaration
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 dest_out RST" *)
    output wire dest_out  //
);

    wire rst_int = (IN_POLARITY == OUT_POLARITY) ? src_in : ~src_in;

    localparam INIT = (OUT_POLARITY == "ACTIVE_HIGH") ? 1'b1 : 1'b0;

    generate
        if (RST_TYPE == "ASYNC") begin : g_async_rst
            xpm_cdc_async_rst #(
                .DEST_SYNC_FF   (DEST_SYNC_FF),
                .INIT_SYNC_FF   (INIT_SYNC_FF),
                .RST_ACTIVE_HIGH(INIT)
            ) xpm_cdc_async_rst_inst (
                .dest_arst(dest_out),
                .dest_clk (dest_clk),
                .src_arst (rst_int)
            );
        end else begin : g_sync_rst
            xpm_cdc_sync_rst #(
                .DEST_SYNC_FF  (DEST_SYNC_FF),
                .INIT          (INIT),
                .INIT_SYNC_FF  (INIT_SYNC_FF),
                .SIM_ASSERT_CHK(SIM_ASSERT_CHK)
            ) xpm_cdc_sync_rst_inst (
                .dest_rst(dest_out),
                .dest_clk(dest_clk),
                .src_rst (rst_int)
            );
        end

    endgenerate




endmodule

// verilog_format: off
`resetall
// verilog_format: on
