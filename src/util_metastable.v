// +FHEADER-------------------------------------------------------------------------------
// Copyright (c) 2024 john_tito. All rights reserved.
// ---------------------------------------------------------------------------------------
// Author        : john_tito
// Module Name   : util_metastable
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

module util_metastable #(
    parameter         C_EDGE_TYPE    = "rising",  // edge type "rising","falling", "both"
    parameter integer MAINTAIN_CYCLE = 1
) (
    input  wire clk,     // input clock
    input  wire rst,     // input reset
    input  wire din,     // input signal
    output reg  dout,
    output reg  dout_r,  // output metastable
    output reg  dout_f   // output metastable
);

    wire                    p_edge;
    wire                    n_edge;
    reg  [MAINTAIN_CYCLE:0] shift_reg;

    always @(posedge clk) begin
        if (rst) begin
            shift_reg <= {(MAINTAIN_CYCLE + 1) {din}};
            dout_r    <= 1'b0;
            dout_f    <= 1'b0;
        end else begin
            shift_reg <= {shift_reg[(MAINTAIN_CYCLE-1):0], din};
            dout_r    <= p_edge;
            dout_f    <= n_edge;
        end
    end

    assign p_edge = ~(shift_reg[MAINTAIN_CYCLE]) & (&shift_reg[(MAINTAIN_CYCLE-1):0]);
    assign n_edge = (&shift_reg[MAINTAIN_CYCLE : 1]) & ~shift_reg[0];

    always @(posedge clk) begin
        if (rst) begin
            dout <= 1'b0;
        end else begin
            if (C_EDGE_TYPE == "rising") begin
                dout <= p_edge;
            end else if (C_EDGE_TYPE == "falling") begin
                dout <= n_edge;
            end else if (C_EDGE_TYPE == "both") begin
                dout <= p_edge | n_edge;
            end else begin
                dout <= 1'b0;
            end
        end
    end

endmodule


// verilog_format: off
`resetall
// verilog_format: on
