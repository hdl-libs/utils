// +FHEADER-------------------------------------------------------------------------------
// Copyright (c) 2024 john_tito. All rights reserved.
// ---------------------------------------------------------------------------------------
// Author        : john_tito
// Module Name   : util_pulse_dly
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

module util_pulse_dly #(
    parameter DAFAULT_CFG_TYPE  = 2'b00,
    parameter DAFAULT_CFG_HOLD  = 32'd1,
    parameter DAFAULT_CFG_DELAY = 32'd0
) (
    input  wire        rstn,        // 复位信号
    input  wire        clk,         // 系统时钟
    input  wire        en,          // 使能信号
    input  wire        cfg_update,  // 配置更新
    input  wire [ 1:0] cfg_type,    // [1]:信号类型,0:固定,1:触发 ; [0]:极性配置, 固定电平/空闲电平
    input  wire [31:0] cfg_hold,    // 脉冲宽度配置
    input  wire [31:0] cfg_delay,   // 延迟配置
    input  wire        trig,        // 触发信号
    output wire        ready,       // 就绪标志
    output wire        dout         // 同步信号输出
);

    reg  [32:0] pulse_cnt;

    wire        disable_cnt;
    wire        periodic_pulse;
    reg         dout_reg;
    reg         ready_reg = 1'b0;

    reg  [ 1:0] cfg_type_reg = DAFAULT_CFG_TYPE;
    reg  [31:0] cfg_hold_reg = DAFAULT_CFG_HOLD;
    reg  [31:0] cfg_delay_reg = DAFAULT_CFG_DELAY;

    assign disable_cnt    = ~cfg_type_reg[1];
    assign periodic_pulse = trig & ready_reg;
    assign ready          = ready_reg;

    // 锁存配置参数
    always @(posedge clk) begin
        if (!rstn) begin
            cfg_type_reg  = DAFAULT_CFG_TYPE;
            cfg_hold_reg  = DAFAULT_CFG_HOLD;
            cfg_delay_reg = DAFAULT_CFG_DELAY;
        end else begin
            if (cfg_update) begin
                cfg_type_reg  = cfg_type;
                cfg_hold_reg  = cfg_hold;
                cfg_delay_reg = cfg_delay;
            end
        end
    end

    // 对脉冲延迟时间和持续时间计数
    always @(posedge clk) begin
        if (!rstn || cfg_update || disable_cnt) begin
            pulse_cnt <= 0;
        end else begin
            if (en) begin
                if (periodic_pulse) begin
                    pulse_cnt <= cfg_delay_reg + cfg_hold_reg;
                end else if (pulse_cnt > 0) begin
                    pulse_cnt <= pulse_cnt - 1;
                end else begin
                    ;
                end
            end else begin
                pulse_cnt <= 0;
            end
        end
    end

    // 根据设定的信号类型进行输出
    always @(posedge clk) begin
        if (!rstn || cfg_update) begin
            dout_reg <= cfg_type_reg[0];
        end else begin
            if (cfg_type_reg[1]) begin
                if (en) begin
                    if (pulse_cnt > 0 && pulse_cnt <= cfg_hold_reg) begin
                        dout_reg <= ~cfg_type_reg[0];
                    end else begin
                        dout_reg <= cfg_type_reg[0];
                    end
                end else begin
                    ;
                end
            end else begin
                dout_reg <= cfg_type_reg[0];
            end
        end
    end

    always @(posedge clk) begin
        if (!rstn) begin
            ready_reg <= 1'b0;
        end else begin
            ready_reg <= (pulse_cnt == 0);
        end
    end

endmodule

// verilog_format: off
`resetall
// verilog_format: on
