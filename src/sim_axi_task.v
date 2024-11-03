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
// Module Name   : sim_axi_task
// ---------------------------------------------------------------------------------------
// Revision      : 1.0
// Description   : this module is used to write/read AXI4-Lite slave interface
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

module sim_axi_task #(
    parameter integer C_AXI_DATA_WIDTH = 32,
    parameter integer C_AXI_ADDR_WIDTH = 16
) (
    input  wire                        s_axi_aclk,
    input  wire                        s_axi_aresetn,
    // AXI interface
    output reg  [C_AXI_ADDR_WIDTH-1:0] s_axi_araddr = 0,
    output reg  [                 2:0] s_axi_arprot = 0,
    output reg                         s_axi_arvalid = 0,
    input  wire                        s_axi_arready,

    input  wire [C_AXI_DATA_WIDTH-1:0] s_axi_rdata,
    input  wire [                 1:0] s_axi_rresp,
    input  wire                        s_axi_rvalid,
    output reg                         s_axi_rready = 0,

    output reg  [C_AXI_ADDR_WIDTH-1:0] s_axi_awaddr = 0,
    output reg  [                 2:0] s_axi_awprot = 0,
    output reg                         s_axi_awvalid = 0,
    input  wire                        s_axi_awready,

    output reg  [    C_AXI_DATA_WIDTH-1:0] s_axi_wdata = 0,
    output reg  [(C_AXI_DATA_WIDTH/8)-1:0] s_axi_wstrb = 0,
    output reg                             s_axi_wvalid = 0,
    input  wire                            s_axi_wready,

    input  wire [1:0] s_axi_bresp,
    input  wire       s_axi_bvalid,
    output reg        s_axi_bready = 0
);

    localparam WR_FSM_IDLE = 8'h01;
    localparam WR_FSM_ADDR = 8'h02;
    localparam WR_FSM_DATA = 8'h04;

    localparam RD_FSM_IDLE = 8'h01;
    localparam RD_FSM_ADDR = 8'h02;
    localparam RD_FSM_DATA = 8'h04;

    reg [ 7:0] wr_cstate;
    reg [ 7:0] wr_nstate;
    reg [ 7:0] rd_cstate;
    reg [ 7:0] rd_nstate;

    reg        wr_req = 0;
    reg [15:0] wr_addr = 0;
    reg [31:0] wr_data = 0;

    reg        rd_req = 0;
    reg [15:0] rd_addr = 0;
    reg [31:0] rd_data = 0;

    task automatic axi_write;
        input [15:0] addr;
        input [31:0] data;
        begin
            wait (wr_cstate == WR_FSM_IDLE);
            @(posedge s_axi_aclk) #0.01;
            wr_addr = addr;
            wr_data = data;
            wr_req  = 1'b0;
            @(posedge s_axi_aclk) #0.01;
            wr_req = 1'b1;
            wait (wr_cstate != WR_FSM_IDLE);
            wr_req = 1'b0;
        end
    endtask

    task automatic axi_read;
        input [15:0] addr;
        output [31:0] data;
        begin
            wait (rd_cstate == RD_FSM_IDLE);
            @(posedge s_axi_aclk) #0.01;
            rd_addr = addr;
            data    = rd_data;
            rd_req  = 1'b0;
            @(posedge s_axi_aclk) #0.01;
            rd_req = 1'b1;
            wait (rd_cstate != RD_FSM_IDLE);
            rd_req = 1'b0;
        end
    endtask

    always @(posedge s_axi_aclk) begin
        if (!s_axi_aresetn) begin
            wr_cstate <= WR_FSM_IDLE;
        end else begin
            wr_cstate <= wr_nstate;
        end
    end

    always @(*) begin
        if (!s_axi_aresetn) begin
            wr_nstate = WR_FSM_IDLE;
        end else begin
            case (wr_cstate)
                WR_FSM_IDLE: begin
                    if (wr_req) begin
                        wr_nstate = WR_FSM_DATA;
                    end else begin
                        wr_nstate = WR_FSM_IDLE;
                    end
                end
                WR_FSM_DATA: begin
                    if ((s_axi_wready & s_axi_wvalid) && (s_axi_awready & s_axi_awvalid)) begin
                        wr_nstate = WR_FSM_IDLE;
                    end else begin
                        wr_nstate = WR_FSM_DATA;
                    end
                end
                default: wr_nstate = WR_FSM_IDLE;
            endcase
        end
    end

    always @(posedge s_axi_aclk) begin
        if (!s_axi_aresetn) begin
            s_axi_bready  <= 1'b1;
            s_axi_awvalid <= 1'b0;
            s_axi_awaddr  <= 16'h0000;
            s_axi_wdata   <= 32'h00000000;
            s_axi_wvalid  <= 1'b0;
            s_axi_wstrb   <= 4'h0;
        end else begin
            case (wr_nstate)
                WR_FSM_DATA: begin
                    s_axi_awvalid <= 1'b1;
                    s_axi_awaddr  <= wr_addr;
                    s_axi_wdata   <= wr_data;
                    s_axi_wvalid  <= 1'b1;
                    s_axi_wstrb   <= 4'hF;
                end
                default: begin
                    s_axi_awvalid <= 1'b0;
                    s_axi_awaddr  <= 16'h0000;
                    s_axi_wdata   <= 32'h00000000;
                    s_axi_wvalid  <= 1'b0;
                    s_axi_wstrb   <= 4'h0;
                end
            endcase
        end
    end

    // ***********************************************************************************

    always @(posedge s_axi_aclk) begin
        if (!s_axi_aresetn) begin
            rd_cstate <= RD_FSM_IDLE;
        end else begin
            rd_cstate <= rd_nstate;
        end
    end

    always @(*) begin
        if (!s_axi_aresetn) begin
            rd_nstate = RD_FSM_IDLE;
        end else begin
            case (rd_cstate)
                RD_FSM_IDLE: begin
                    if (rd_req) begin
                        rd_nstate = RD_FSM_ADDR;
                    end else begin
                        rd_nstate = RD_FSM_IDLE;
                    end
                end
                RD_FSM_ADDR: begin
                    if (s_axi_arready & s_axi_arvalid) begin
                        rd_nstate = RD_FSM_DATA;
                    end else begin
                        rd_nstate = RD_FSM_ADDR;
                    end
                end
                RD_FSM_DATA: begin
                    if (s_axi_rready & s_axi_rvalid) begin
                        rd_nstate = RD_FSM_IDLE;
                    end else begin
                        rd_nstate = RD_FSM_DATA;
                    end
                end
                default: rd_nstate = RD_FSM_IDLE;
            endcase
        end
    end

    always @(posedge s_axi_aclk) begin
        if (!s_axi_aresetn) begin
            s_axi_arvalid <= 1'b0;
            s_axi_araddr  <= 16'h0000;
        end else begin
            case (rd_nstate)
                RD_FSM_ADDR: begin
                    s_axi_arvalid <= 1'b1;
                    s_axi_araddr  <= rd_addr;
                end
                default: begin
                    s_axi_arvalid <= 1'b0;
                    s_axi_araddr  <= 16'h0000;
                end
            endcase
        end
    end

    always @(posedge s_axi_aclk) begin
        if (!s_axi_aresetn) begin
            s_axi_rready <= 1'b0;
        end else begin
            case (rd_nstate)
                RD_FSM_DATA: begin
                    s_axi_rready <= 1'b1;
                end
                default: begin
                    s_axi_rready <= 1'b0;
                end
            endcase
        end
    end

endmodule

// verilog_format: off
`resetall
// verilog_format: on
