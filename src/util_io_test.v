// +FHEADER-------------------------------------------------------------------------------
// Copyright (c) 2024 john_tito. All rights reserved.
// ---------------------------------------------------------------------------------------
// Author        : john_tito
// Module Name   : util_io_test
// ---------------------------------------------------------------------------------------
// Revision      : 1.0
// Description   : add description here
// Revision 1.00 - File Created
// ---------------------------------------------------------------------------------------
// Reuse Issue   :
// Synthesizable : Yes
// Instantiations: add dependencies here
// Clock Domains : clk
// Reset Strategy: sync reset
// Other :
// -FHEADER-------------------------------------------------------------------------------

// verilog_format: off
`resetall
`timescale 1ns / 1ps
`default_nettype none
// verilog_format: on

module util_io_test #(
    parameter INPUT_IO_WIDTH  = 32,
    parameter OUTPUT_IO_WIDTH = 32
) (
    input wire        clk,
    input wire        rstn,
    input wire        en,
    input wire        clr,
    input wire        baud_load,
    input wire [31:0] baud_div,

    input  wire [OUTPUT_IO_WIDTH-1:0] io_default,
    input  wire [OUTPUT_IO_WIDTH-1:0] force_default,
    output reg  [OUTPUT_IO_WIDTH-1:0] io_o,
    input  wire [ INPUT_IO_WIDTH-1:0] io_i,
    output wire [ INPUT_IO_WIDTH-1:0] io_i_r,
    output reg  [ INPUT_IO_WIDTH-1:0] state,
    output reg                        state_valid
);

    reg        shift_en;
    reg [31:0] cnt;
    reg [31:0] baud_div_reg;
    reg [ 7:0] shift_reg    [0:INPUT_IO_WIDTH-1];
    reg [ 7:0] shift_flag;

    always @(posedge clk) begin
        if (!rstn) begin
            baud_div_reg <= 1;
        end else begin
            if (baud_load) begin
                baud_div_reg <= baud_div;
            end
        end
    end

    always @(posedge clk) begin
        if (!rstn) begin
            cnt      <= 0;
            shift_en <= 1'b0;
        end else begin
            if (baud_div_reg && en) begin
                if (cnt + 1 < baud_div_reg) begin
                    cnt <= cnt + 1;
                end else begin
                    cnt <= 0;
                end
                shift_en <= cnt + 1 >= baud_div_reg;
            end else begin
                cnt      <= 0;
                shift_en <= 1'b0;
            end
        end
    end

    always @(posedge clk) begin
        if (!rstn) begin
            shift_flag  <= 8'h01;
            state_valid <= 1'b0;
        end else begin
            if (en) begin
                if (shift_en) begin
                    shift_flag  <= shift_flag << 1 | shift_flag[7];
                    state_valid <= shift_flag[7];
                end else begin
                    state_valid <= 1'b0;
                end
            end else begin
                shift_flag  <= 8'h01;
                state_valid <= 1'b0;
            end
        end
    end

    genvar ii;
    generate
        for (ii = 0; ii < INPUT_IO_WIDTH; ii = ii + 1) begin
            assign io_i_r[ii] = shift_reg[ii][0];
            always @(posedge clk) begin
                if (!rstn) begin
                    shift_reg[ii] <= 8'h00;
                end else begin
                    if (en) begin
                        if (shift_en) shift_reg[ii] <= (shift_reg[ii] << 1) | io_i[ii];
                    end else begin
                        shift_reg[ii] <= 8'h00;
                    end
                end
            end

            always @(posedge clk) begin
                if (!rstn) begin
                    state[ii] <= 1'b0;
                end else begin
                    if (en && !clr) begin
                        if (shift_flag[7]) state[ii] <= state[ii] | ((shift_reg[ii] != 8'hAA) & (shift_reg[ii] != 8'h55));
                    end else begin
                        state[ii] <= 1'b0;
                    end
                end
            end
        end

        for (ii = 0; ii < OUTPUT_IO_WIDTH; ii = ii + 1) begin
            always @(posedge clk) begin
                if (!rstn) begin
                    io_o[ii] <= io_default[ii];
                end else begin
                    if (en && !force_default[ii]) begin
                        if (shift_en) io_o[ii] <= ~io_o[ii];
                    end else begin
                        io_o[ii] <= io_default[ii];
                    end
                end
            end
        end

    endgenerate

endmodule

// verilog_format: off
`resetall
// verilog_format: on
