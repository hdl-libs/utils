// +FHEADER-------------------------------------------------------------------------------
// Copyright (c) 2024 john_tito. All rights reserved.
// ---------------------------------------------------------------------------------------
// Author        : john_tito
// Module Name   : util_swap
// ---------------------------------------------------------------------------------------
// Revision      : 1.0
// Description   : add description here
// Revision 1.00 - File Created
// ---------------------------------------------------------------------------------------
// Reuse Issue   :
// Synthesizable : Yes
// Instantiations: add dependencies here
// Clock Domains : clk
// Reset Strategy: none
// Other :
// -FHEADER-------------------------------------------------------------------------------

// verilog_format: off
`resetall
`timescale 1ns / 1ps
`default_nettype none
// verilog_format: on

module util_swap #(
    parameter S_NUM = 4,  // symbol num
    parameter B_NUM = 8   // bit num per symbol
) (
    input  wire [(S_NUM*B_NUM)-1:0] idata,  //
    output wire [(S_NUM*B_NUM)-1:0] odata   //
);
    genvar ii;
    for (ii = 0; ii < S_NUM; ii = ii + 1) begin
        assign odata[ii*B_NUM+:B_NUM] = idata[(S_NUM-ii-1)*B_NUM+:B_NUM];
    end

endmodule

// verilog_format: off
`resetall
// verilog_format: on
