// +FHEADER-------------------------------------------------------------------------------
// Copyright (c) 2024 john_tito. All rights reserved.
// ---------------------------------------------------------------------------------------
// Author        : john_tito
// Module Name   : util_iic_trans
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

module util_iic_trans #(
    parameter SLAVE_NUM = 1
) (
    input wire rstn,  //

    (* X_INTERFACE_INFO = "xilinx.com:interface:iic:1.0 s_iic SCL_I" *)
    output reg                  s_scl_i,  //
    (* X_INTERFACE_INFO = "xilinx.com:interface:iic:1.0 s_iic SCL_O" *)
    input  wire                 s_scl_o,  //
    (* X_INTERFACE_INFO = "xilinx.com:interface:iic:1.0 s_iic SCL_T" *)
    input  wire                 s_scl_t,  //
    (* X_INTERFACE_INFO = "xilinx.com:interface:iic:1.0 s_iic SDA_I" *)
    output reg                  s_sda_i,  //
    (* X_INTERFACE_INFO = "xilinx.com:interface:iic:1.0 s_iic SDA_O" *)
    input  wire                 s_sda_o,  //
    (* X_INTERFACE_INFO = "xilinx.com:interface:iic:1.0 s_iic SDA_T" *)
    input  wire                 s_sda_t,  //
    //
    input  wire [SLAVE_NUM-1:0] cs_n,     //
    //
    (* X_INTERFACE_INFO = "john_tito:interface:simple_iic:1.0 m_iic SCL_I" *)
    input  wire [SLAVE_NUM-1:0] m_scl_i,  //
    (* X_INTERFACE_INFO = "john_tito:interface:simple_iic:1.0 m_iic SCL_O" *)
    output wire [SLAVE_NUM-1:0] m_scl_o,  //
    (* X_INTERFACE_INFO = "john_tito:interface:simple_iic:1.0 m_iic SCL_IE" *)
    output wire [SLAVE_NUM-1:0] m_scl_ie, //

    (* X_INTERFACE_INFO = "john_tito:interface:simple_iic:1.0 m_iic SDA_I" *)
    input  wire [SLAVE_NUM-1:0] m_sda_i,  //
    (* X_INTERFACE_INFO = "john_tito:interface:simple_iic:1.0 m_iic SDA_O" *)
    output wire [SLAVE_NUM-1:0] m_sda_o,  //
    (* X_INTERFACE_INFO = "john_tito:interface:simple_iic:1.0 m_iic SDA_IE" *)
    output wire [SLAVE_NUM-1:0] m_sda_ie  //
    //
);


    generate
        genvar ii;
        for (ii = 0; ii < SLAVE_NUM; ii = ii + 1) begin
            assign m_scl_o[ii]  = cs_n[ii] | s_scl_o;
            assign m_scl_ie[ii] = cs_n[ii] | s_scl_t;

            assign m_sda_o[ii]  = cs_n[ii] | s_sda_o;
            assign m_sda_ie[ii] = cs_n[ii] | s_scl_t;
        end
    endgenerate

    always @(*) begin
        if (rstn) begin
            s_scl_i = 1'b1;
        end else if (s_scl_t == 1'b1) begin
            s_scl_i = &(cs_n | m_scl_i);
        end else begin
            s_scl_i = 1'b1;
        end
    end

    always @(*) begin
        if (rstn) begin
            s_sda_i = 1'b1;
        end else if (s_scl_t == 1'b1) begin
            s_sda_i = &(cs_n | m_sda_i);
        end else begin
            s_sda_i = 1'b1;
        end
    end

endmodule

// verilog_format: off
`resetall
// verilog_format: on
