// verilog_format: off
`resetall
`timescale 1ns / 1ps
`default_nettype none
// verilog_format: on

module util_io_test_tb;

    // Parameters
    localparam real TIMEPERIOD = 5;
    localparam INPUT_IO_WIDTH = 32;
    localparam OUTPUT_IO_WIDTH = 32;
    localparam TEST_GAP = 512;

    // Ports
    reg                        clr = 0;
    reg                        clk = 0;
    reg                        rstn = 0;
    reg                        en = 0;
    reg                        baud_load = 0;
    reg  [               31:0] baud_div = 0;
    reg  [OUTPUT_IO_WIDTH-1:0] io_default = 0;
    reg  [OUTPUT_IO_WIDTH-1:0] io_oe = 0;
    reg  [ INPUT_IO_WIDTH-1:0] io_i = 0;
    wire [OUTPUT_IO_WIDTH-1:0] io_o;
    wire [ INPUT_IO_WIDTH-1:0] state;
    wire                       state_valid;

    util_io_test #(
        .INPUT_IO_WIDTH (INPUT_IO_WIDTH),
        .OUTPUT_IO_WIDTH(OUTPUT_IO_WIDTH),
        .TEST_GAP       (TEST_GAP)
    ) dut (
        .clk          (clk),
        .rstn         (rstn),
        .en           (en),
        .baud_load    (baud_load),
        .baud_div     (baud_div),
        .force_default(~io_oe),
        .io_default   (io_default),
        .io_o         (io_o),
        .io_i         (io_i),
        .clr          (clr),
        .state        (state),
        .state_valid  (state_valid)
    );

    initial begin
        begin
            en         = 0;
            io_default = 0;
            io_oe      = 0;
            wait (rstn);
            #10000;

            en = 1'b1;
            #10000;

            io_default = 32'h0000ffff;
            io_oe      = 32'h0000ffff;
            #5000;
            clr = 1'b1;
            #20;
            clr = 1'b0;
            #5000;
            io_oe = 32'hffff0000;
            #10000;

            io_default = 32'hffff0000;
            io_oe      = 32'h0000ffff;
            #5000;
            clr = 1'b1;
            #20;
            clr = 1'b0;
            #5000;
            io_oe = 32'hffff0000;
            #10000;

            #10000;
            io_default = 32'h0000ffff;
            io_oe      = 32'h0000ffff;
            #5000;
            clr = 1'b1;
            #20;
            clr = 1'b0;
            #5000;
            io_oe = 32'hffff0000;
            #10000;

            io_default = 32'hffff0000;
            io_oe      = 32'h0000ffff;
            #5000;
            clr = 1'b1;
            #20;
            clr = 1'b0;
            #5000;
            io_oe = 32'hffff0000;
            #10000;
            en = 1'b0;
            $finish;
        end
    end

    always @(posedge clk) begin
        if (!rstn) begin
            io_i <= 0;
        end else begin
            io_i <= io_o;
        end
    end

    always #(TIMEPERIOD / 2) clk = !clk;

    // reset block
    initial begin
        rstn = 1'b0;
        #(TIMEPERIOD * 2);
        rstn = 1'b1;
    end

    // record block
    initial begin
        $dumpfile("sim/test_tb.vcd");
        $dumpvars(0, util_io_test_tb);
    end


endmodule

// verilog_format: off
`resetall
// verilog_format: on
