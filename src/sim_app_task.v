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
// Module Name   : sim_app_task
// ---------------------------------------------------------------------------------------
// Revision      : 1.0
// Description   : this module provides a task interface to the APP register interface
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

module sim_app_task (
    input wire clk,
    input wire rst,

    output reg         app_reg_rreq = 1'b0,
    input  wire        app_reg_rack,
    output reg  [15:0] app_reg_raddr = 0,
    input  wire [31:0] app_reg_rdata,
    output reg         app_reg_wreq = 1'b0,
    input  wire        app_reg_wack,
    output reg  [15:0] app_reg_waddr = 0,
    output reg  [31:0] app_reg_wdata = 0
);

    task automatic app_write;
        input [15:0] addr;
        input [31:0] data;
        begin
            @(posedge clk);
            app_reg_wreq  = 1'b1;
            app_reg_waddr = addr;
            app_reg_wdata = data;
            @(posedge clk);
            app_reg_wreq = 1'b0;
            @(posedge clk);
        end
    endtask

    task automatic app_read;
        input [15:0] addr;
        output [31:0] data;
        begin
            @(posedge clk);
            app_reg_rreq  = 1'b1;
            app_reg_raddr = addr;
            data          = 0;
            @(posedge clk);
            app_reg_rreq = 1'b0;
            @(posedge clk);
        end
    endtask

endmodule

// verilog_format: off
`resetall
// verilog_format: on
