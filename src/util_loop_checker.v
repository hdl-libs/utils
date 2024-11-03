// ---------------------------------------------------------------------------------------
// Copyright (c) 2024 john_tito All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// ---------------------------------------------------------------------------------------
// +FHEADER-------------------------------------------------------------------------------
// Author        : john_tito
// Module Name   : util_loop_checker
// ---------------------------------------------------------------------------------------
// Revision      : 1.0
// Description   : this module is a simple loop checker
// ---------------------------------------------------------------------------------------
// Synthesizable : Yes
// Clock Domains : clk
// Reset Strategy: sync reset
// -FHEADER-------------------------------------------------------------------------------

// verilog_format: off
`resetall
`timescale 1ns / 1ps
`default_nettype none
// verilog_format: on

module util_loop_checker #(
    parameter DATA_WIDTH = 8
) (
    input  wire                    clk,         //
    input  wire                    rstn,        //
    input  wire [(DATA_WIDTH-1):0] tx_data,     //
    input  wire                    tx_valid,    //
    input  wire [(DATA_WIDTH-1):0] rx_data,     //
    input  wire                    rx_valid,    //
    output reg                     check_error  //
);

    reg [(DATA_WIDTH-1):0] tx_data_reg;
    reg [(DATA_WIDTH-1):0] rx_data_reg;

    reg                    tx_valid_reg;
    reg                    rx_valid_reg;

    always @(posedge clk) begin
        if (!rstn) begin
            check_error <= 1'b0;
        end else begin
            if (tx_valid_reg & rx_valid_reg) begin
                check_error = (tx_data_reg == rx_data_reg) ? 1'b0 : 1'b1;
            end
        end
    end

    always @(posedge clk) begin
        if (!rstn) begin
            tx_valid_reg <= 1'b0;
            tx_data_reg  <= 0;
        end else begin
            if (tx_valid) begin
                tx_valid_reg <= 1'b1;
                tx_data_reg  <= tx_data;
            end else if (tx_valid_reg & rx_valid_reg) begin
                tx_valid_reg <= 1'b0;
                tx_data_reg  <= 0;
            end else begin
                tx_valid_reg <= tx_valid_reg;
                tx_data_reg  <= tx_data_reg;
            end
        end
    end

    always @(posedge clk) begin
        if (!rstn) begin
            rx_valid_reg <= 1'b0;
            rx_data_reg  <= 0;
        end else begin
            if (rx_valid) begin
                rx_valid_reg <= 1'b1;
                rx_data_reg  <= rx_data;
            end else if (tx_valid_reg & rx_valid_reg) begin
                rx_valid_reg <= 1'b0;
                rx_data_reg  <= 0;
            end else begin
                rx_valid_reg <= rx_valid_reg;
                rx_data_reg  <= rx_data_reg;
            end
        end
    end

endmodule

// verilog_format: off
`resetall
// verilog_format: on
