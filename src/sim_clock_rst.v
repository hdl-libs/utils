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
// Module Name   : sim_clock_rst
// ---------------------------------------------------------------------------------------
// Revision      : 1.0
// Description   : this module provides a clock and reset interface for the testbench
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

module sim_clock_rst #(
    parameter real TIMEPERIOD = 10  // ns
) (
    output reg clk = 1'b0,
    output reg rstn = 1'b0,
    output reg rst = 1'b1
);

    // clock block
    always #(TIMEPERIOD / 2) clk = !clk;

    reg [7:0] ii;
    // reset block
    initial begin
        begin
            rstn = 1'b0;
            rst  = 1'b1;
            for (ii = 0; ii < 32; ii = ii + 1) begin
                @(posedge clk);
                @(posedge clk);
            end
            rstn = 1'b1;
            rst  = 1'b0;
        end
    end

endmodule

// verilog_format: off
`resetall
// verilog_format: on
