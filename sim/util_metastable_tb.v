`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2023/03/03 16:23:33
// Design Name:
// Module Name: util_metastable_tb
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module util_metastable_tb;

    // Parameters
    localparam TIMEPERIOD = 10;
    localparam C_EDGE_TYPE = "both";
    localparam integer MAINTAIN_CYCLE = 1;

    // Ports
    reg  clk = 0;
    reg  rstn = 0;
    reg  din = 0;
    wire dout;
    wire dout_r;
    wire dout_f;

    util_metastable #(
        .C_EDGE_TYPE(C_EDGE_TYPE),
        .MAINTAIN_CYCLE(MAINTAIN_CYCLE)
    ) util_metastable_dut (
        .clk   (clk),
        .rstn  (rstn),
        .din   (din),
        .dout  (dout),
        .dout_r(dout_r),
        .dout_f(dout_f)
    );

    initial begin
        begin
            wait (rstn);
            #(TIMEPERIOD * 1);

            din <= 1'b0;
            #(TIMEPERIOD * 1);
            din <= 1'b1;
            #(TIMEPERIOD * 1);

            din <= 1'b0;
            #(TIMEPERIOD * 1);

            din <= 1'b0;
            #(TIMEPERIOD * MAINTAIN_CYCLE);
            din <= 1'b1;
            #(TIMEPERIOD * MAINTAIN_CYCLE);

            din <= 1'b0;
            #(TIMEPERIOD * 100);
            $finish;
        end
    end

    // ***********************************************************************************
    // clock block
    always #(TIMEPERIOD / 2) clk = !clk;

    // reset block
    initial begin
        begin
            rstn = 1'b0;
            #(TIMEPERIOD * 30);
            rstn = 1'b1;
        end
    end

    // record block
    initial begin
        begin
            $dumpfile("sim/test_tb.lxt");
            $dumpvars(0, util_metastable_tb);
        end
    end
endmodule
