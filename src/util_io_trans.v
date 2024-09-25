// +FHEADER-------------------------------------------------------------------------------
// Copyright (c) 2024 john_tito. All rights reserved.
// ---------------------------------------------------------------------------------------
// Author        : john_tito
// Module Name   : util_io_trans
// ---------------------------------------------------------------------------------------
// Revision      : 1.0
// Description   : add description here
// Revision 1.00 - File Created
// ---------------------------------------------------------------------------------------
// Reuse Issue   :
// Synthesizable : Yes
// Instantiations: add dependencies here
// Clock Domains : clk
// Reset Strategy: Sync Reset, Active High Level
// Other :
// -FHEADER-------------------------------------------------------------------------------

// verilog_format: off
`resetall
`timescale 1ns / 1ps
`default_nettype none
// verilog_format: on

module util_io_trans #(
    parameter PORT_WIDTH = 1
) (
    input wire rstn,  //

    (* X_INTERFACE_INFO = "xilinx.com:interface:gpio:1.0 s_gpio TRI_T" *)
    input  wire [PORT_WIDTH-1:0] s_gpio_t,  //
    (* X_INTERFACE_INFO = "xilinx.com:interface:gpio:1.0 s_gpio TRI_O" *)
    input  wire [PORT_WIDTH-1:0] s_gpio_o,  //
    (* X_INTERFACE_INFO = "xilinx.com:interface:gpio:1.0 s_gpio TRI_I" *)
    output wire [PORT_WIDTH-1:0] s_gpio_i,  //

    output wire [PORT_WIDTH-1:0] gpio_o,  //
    input  wire [PORT_WIDTH-1:0] gpio_i   //
);

    assign gpio_o   = s_gpio_o;
    assign s_gpio_i = gpio_i;

endmodule

// verilog_format: off
`resetall
// verilog_format: on
