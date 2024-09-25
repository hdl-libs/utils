// +FHEADER-------------------------------------------------------------------------------
// Copyright (c) 2024 john_tito. All rights reserved.
// ---------------------------------------------------------------------------------------
// Author        : john_tito
// Module Name   : util_cdc
// ---------------------------------------------------------------------------------------
// Revision      : 1.0
// Description   : add description here
// Revision 1.00 - File Created
// ---------------------------------------------------------------------------------------
// Reuse Issue   :
// Synthesizable : Yes
// Instantiations: add dependencies here
// Clock Domains : clk
// Reset Strategy: none
// Other :
// -FHEADER-------------------------------------------------------------------------------

// verilog_format: off
`resetall
`timescale 1ns / 1ps
`default_nettype none
// verilog_format: on

module util_cdc #(
    parameter DEST_SYNC_FF   = 4,
    parameter INIT_SYNC_FF   = 0,
    parameter SIM_ASSERT_CHK = 0,
    parameter SRC_INPUT_REG  = 1,
    parameter WIDTH          = 1
) (

    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 src_clk CLK" *) (* X_INTERFACE_PARAMETER = "ASSOCIATED_RESET src_in" *)
    input wire src_clk,  //

    // Declare the attributes above the port declaration
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 dest_clk CLK" *)
    (* X_INTERFACE_PARAMETER = "ASSOCIATED_RESET dest_out" *)
    input wire dest_clk,  //

    // Declare the attributes above the port declaration
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 src_in RST" *)
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_HIGH" *)
    input wire [(WIDTH-1):0] src_in,  //

    // Declare the attributes above the port declaration
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 dest_out RST" *)
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_HIGH" *)
    output wire [(WIDTH-1):0] dest_out  //
);

    generate
        if (WIDTH >= 2) begin : g_array_single
            xpm_cdc_array_single #(
                .DEST_SYNC_FF  (DEST_SYNC_FF),
                .INIT_SYNC_FF  (INIT_SYNC_FF),
                .SIM_ASSERT_CHK(SIM_ASSERT_CHK),
                .SRC_INPUT_REG (SRC_INPUT_REG),
                .WIDTH         (WIDTH)
            ) xpm_cdc_array_single_inst (
                .dest_out(dest_out),
                .dest_clk(dest_clk),
                .src_clk (src_clk),
                .src_in  (src_in)
            );
        end else begin : g_single
            xpm_cdc_single #(
                .DEST_SYNC_FF  (DEST_SYNC_FF),
                .INIT_SYNC_FF  (INIT_SYNC_FF),
                .SIM_ASSERT_CHK(SIM_ASSERT_CHK),
                .SRC_INPUT_REG (SRC_INPUT_REG)
            ) xpm_cdc_single_inst (
                .dest_out(dest_out),
                .dest_clk(dest_clk),
                .src_clk (src_clk),
                .src_in  (src_in)
            );
        end

    endgenerate
endmodule

// verilog_format: off
`resetall
// verilog_format: on
