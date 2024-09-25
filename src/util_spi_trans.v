// +FHEADER-------------------------------------------------------------------------------
// Copyright (c) 2024 john_tito. All rights reserved.
// ---------------------------------------------------------------------------------------
// Author        : john_tito
// Module Name   : util_spi_trans
// ---------------------------------------------------------------------------------------
// Revision      : 1.0
// Description   : add description here
// Revision 1.00 - File Created
// ---------------------------------------------------------------------------------------
// Reuse Issue   :
// Synthesizable : Yes
// Instantiations: add dependencies here
// Clock Domains : none
// Reset Strategy: none
// Other :
// -FHEADER-------------------------------------------------------------------------------

// verilog_format: off
`resetall
`timescale 1ns / 1ps
`default_nettype none
// verilog_format: on

module util_spi_trans #(
    parameter SLAVE_NUM = 1,
    parameter CPOL      = 1'b0
) (
    (* X_INTERFACE_INFO = "xilinx.com:interface:spi:1.0 s_spi IO0_I" *)
    output wire spi_mosi_i,  //
    (* X_INTERFACE_INFO = "xilinx.com:interface:spi:1.0 s_spi IO0_O" *)
    input  wire spi_mosi_o,  //
    (* X_INTERFACE_INFO = "xilinx.com:interface:spi:1.0 s_spi IO0_T" *)
    input  wire spi_mosi_t,  //

    (* X_INTERFACE_INFO = "xilinx.com:interface:spi:1.0 s_spi IO1_I" *)
    output reg  spi_miso_i,  //
    (* X_INTERFACE_INFO = "xilinx.com:interface:spi:1.0 s_spi IO1_O" *)
    input  wire spi_miso_o,  //
    (* X_INTERFACE_INFO = "xilinx.com:interface:spi:1.0 s_spi IO1_T" *)
    input  wire spi_miso_t,  //

    (* X_INTERFACE_INFO = "xilinx.com:interface:spi:1.0 s_spi SCK_I" *)
    output wire spi_clk_i,  //
    (* X_INTERFACE_INFO = "xilinx.com:interface:spi:1.0 s_spi SCK_O" *)
    input  wire spi_clk_o,  //
    (* X_INTERFACE_INFO = "xilinx.com:interface:spi:1.0 s_spi SCK_T" *)
    input  wire spi_clk_t,  //

    (* X_INTERFACE_INFO = "xilinx.com:interface:spi:1.0 s_spi SS_I" *)
    output wire [SLAVE_NUM-1:0] spi_cs_i,  //
    (* X_INTERFACE_INFO = "xilinx.com:interface:spi:1.0 s_spi SS_O" *)
    input  wire [SLAVE_NUM-1:0] spi_cs_o,  //
    (* X_INTERFACE_INFO = "xilinx.com:interface:spi:1.0 s_spi SS_T" *)
    input  wire                 spi_cs_t,  //

    (* X_INTERFACE_INFO = "john_tito:interface:simple_spi:1.0 m_spi scsn" *)
    output wire [SLAVE_NUM-1:0] cs,    //
    (* X_INTERFACE_INFO = "john_tito:interface:simple_spi:1.0 m_spi sclk" *)
    output wire [SLAVE_NUM-1:0] sclk,  //
    (* X_INTERFACE_INFO = "john_tito:interface:simple_spi:1.0 m_spi miso" *)
    input  wire [SLAVE_NUM-1:0] miso,  //
    (* X_INTERFACE_INFO = "john_tito:interface:simple_spi:1.0 m_spi mosi" *)
    output wire [SLAVE_NUM-1:0] mosi   //
);

    assign spi_cs_i   = {{SLAVE_NUM{1'b1}}};
    assign spi_mosi_i = 1'b0;
    assign spi_clk_i  = 1'b0;

    assign mosi       = spi_mosi_t ? {SLAVE_NUM{1'b0}} : {SLAVE_NUM{spi_mosi_o}};
    assign sclk       = spi_clk_t ? {SLAVE_NUM{CPOL}} : {SLAVE_NUM{spi_clk_o}};
    assign cs         = spi_cs_t ? {SLAVE_NUM{1'b1}} : spi_cs_o;

    always @(*) begin
        if (spi_cs_t == 1'b0) begin
            spi_miso_i = |(~spi_cs_o & miso);
        end else begin
            spi_miso_i = 1'b0;
        end
    end

endmodule

// verilog_format: off
`resetall
// verilog_format: on
