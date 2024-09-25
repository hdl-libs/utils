// +FHEADER-------------------------------------------------------------------------------
// Copyright (c) 2024 john_tito. All rights reserved.
// ---------------------------------------------------------------------------------------
// Author        : john_tito
// Module Name   : util_spi_clk_gen
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

module util_spi_clk_gen #(
    parameter DEFAULT_CLK_DIV = 32'h00000064
) (
    input  wire        clk,
    input  wire        rstn,
    input  wire        en,
    input  wire        load,
    input  wire [31:0] baud_div,
    input  wire        CPOL,
    input  wire        CPHA,
    input  wire        ext_clk,
    output reg         sync_clk,
    output reg         shift_en,
    output reg         latch_en
);
    reg        int_sync_clk = 1'b0;
    reg [ 1:0] sync_clk_dd;
    reg        strobe;

    reg [31:0] baud_div_reg = DEFAULT_CLK_DIV;
    reg [31:0] counter;

    localparam FSM_IDLE = 8'h00;
    localparam FSM_PRE_INACTIVE = 8'h01;
    localparam FSM_ACTIVE = 8'h02;
    localparam FSM_INACTIVE = 8'h04;
    localparam FSM_POST_ACTIVE = 8'h8;
    localparam FSM_POST_INACTIVE = 8'h10;

    reg [7:0] cstate;
    reg [7:0] nstate;

    always @(posedge clk) begin
        if (!rstn) begin
            cstate <= FSM_IDLE;
        end else begin
            cstate <= nstate;
        end
    end

    always @(*) begin
        if (!rstn) begin
            nstate = FSM_IDLE;
        end else begin
            case (cstate)
                FSM_IDLE: begin
                    if (en) begin
                        if (CPHA == 1'b0) begin
                            nstate = FSM_PRE_INACTIVE;
                        end else begin
                            nstate = FSM_INACTIVE;
                        end
                    end else begin
                        nstate = FSM_IDLE;
                    end
                end
                FSM_PRE_INACTIVE: begin
                    if (strobe) begin
                        nstate = FSM_INACTIVE;
                    end else begin
                        nstate = FSM_PRE_INACTIVE;
                    end
                end
                FSM_ACTIVE: begin
                    if (strobe) begin
                        if (en) begin
                            nstate = FSM_INACTIVE;
                        end else begin
                            nstate = FSM_IDLE;
                        end
                    end else begin
                        nstate = FSM_ACTIVE;
                    end
                end
                FSM_INACTIVE: begin
                    if (strobe) begin
                        if (en) begin
                            nstate = FSM_ACTIVE;
                        end else begin
                            if (CPHA == 1'b0) begin
                                nstate = FSM_POST_ACTIVE;
                            end else begin
                                nstate = FSM_IDLE;
                            end
                        end
                    end else begin
                        nstate = FSM_INACTIVE;
                    end
                end
                FSM_POST_ACTIVE: begin
                    if (strobe) begin
                        nstate = FSM_IDLE;
                    end else begin
                        nstate = FSM_POST_ACTIVE;
                    end
                end
                default: nstate = FSM_IDLE;
            endcase
        end
    end

    always @(posedge clk) begin
        if (!rstn) begin
            sync_clk <= CPOL;
        end else begin
            case (nstate)
                FSM_ACTIVE, FSM_POST_ACTIVE: sync_clk <= ~CPOL;
                default:                     sync_clk <= CPOL;
            endcase
        end
    end

    // internal clock generate

    always @(posedge clk) begin
        if (~rstn) begin
            baud_div_reg <= DEFAULT_CLK_DIV - 1;
        end else if (load) begin
            if (baud_div > 1) begin
                baud_div_reg <= baud_div - 1;
            end
        end
    end

    always @(posedge clk) begin
        if (!rstn) begin
            counter <= 0;
        end else begin
            case (nstate)
                FSM_IDLE: begin
                    counter <= 0;
                end
                default: begin
                    if (counter >= baud_div_reg) begin
                        counter <= 0;
                    end else begin
                        counter <= counter + 1;
                    end
                end
            endcase
        end
    end

    // clk divider output
    always @(posedge clk) begin
        if (~rstn) begin
            int_sync_clk <= 1'b0;
        end else if (counter > baud_div_reg[31:1]) begin
            int_sync_clk <= 1'b1;
        end else begin
            int_sync_clk <= 1'b0;
        end
    end

    always @(posedge clk) begin
        if (~rstn) begin
            sync_clk_dd <= 2'b00;
        end else begin
            sync_clk_dd <= {sync_clk_dd[0], int_sync_clk};
        end
    end

    always @(posedge clk) begin
        if (~rstn) begin
            strobe <= 1'b0;
        end else begin
            case (nstate)
                FSM_IDLE: begin
                    strobe <= 1'b0;
                end
                default: begin
                    if ((sync_clk_dd[0] ^ (sync_clk_dd[1]))) begin
                        strobe <= 1'b1;
                    end else begin
                        strobe <= 1'b0;
                    end
                end
            endcase
        end
    end

    always @(posedge clk) begin
        if (~rstn) begin
            shift_en <= 1'b0;
        end else begin
            case (nstate)
                FSM_PRE_INACTIVE, FSM_ACTIVE: begin
                    if (CPHA == 1'b0) begin
                        if ((sync_clk_dd[0] & (~sync_clk_dd[1]))) begin
                            shift_en <= 1'b1;
                        end else begin
                            shift_en <= 1'b0;
                        end
                    end else begin
                        shift_en <= 1'b0;
                    end
                end
                FSM_INACTIVE: begin
                    if (CPHA == 1'b1) begin
                        if ((sync_clk_dd[0] & (~sync_clk_dd[1]))) begin
                            shift_en <= 1'b1;
                        end else begin
                            shift_en <= 1'b0;
                        end
                    end else begin
                        shift_en <= 1'b0;
                    end
                end
                default: begin
                    shift_en <= 1'b0;
                end
            endcase
        end
    end

    always @(posedge clk) begin
        if (~rstn) begin
            latch_en <= 1'b0;
        end else begin
            case (nstate)
                FSM_INACTIVE: begin
                    if (CPHA == 1'b0) begin
                        if ((sync_clk_dd[1] & (~sync_clk_dd[0]))) begin
                            latch_en <= 1'b1;
                        end else begin
                            latch_en <= 1'b0;
                        end
                    end else begin
                        latch_en <= 1'b0;
                    end
                end
                FSM_ACTIVE: begin
                    if (CPHA == 1'b1) begin
                        if ((sync_clk_dd[1] & (~sync_clk_dd[0]))) begin
                            latch_en <= 1'b1;
                        end else begin
                            latch_en <= 1'b0;
                        end
                    end else begin
                        latch_en <= 1'b0;
                    end
                end
                default: begin
                    latch_en <= 1'b0;
                end
            endcase
        end
    end

endmodule

// verilog_format: off
`resetall
// verilog_format: on
