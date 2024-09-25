// verilog_format: off
`resetall
`timescale 1ns / 1ps
`default_nettype none
// verilog_format: on

module util_clk_gen_tb;

    // Parameters
    localparam real TIMEPERIOD = 10;
    localparam CLK_MODE_SEL = 2'b01;
    localparam DEFAULT_CLK_DIV = 32'h0000004;
    localparam [3:0] CPOL = 4'b0011;
    localparam [3:0] CPHA = 4'b0101;

    // Ports
    reg         clk = 0;
    reg         rstn = 0;
    reg         oen = 1'b1;
    reg         en = 1'b1;
    reg         load = 0;
    reg  [11:0] baud_freq;
    reg  [15:0] baud_limit;
    reg  [31:0] baud_div = 0;
    reg         ext_clk = 0;
    wire [ 3:0] sync_clk;
    wire [ 3:0] shift_en;
    wire [ 3:0] latch_en;

    reg  [ 7:0] tx_cnt;

    always @(posedge clk) begin
        if (!rstn) begin
            tx_cnt <= 0;
        end else begin
            if (latch_en) begin
                tx_cnt <= tx_cnt + 1;
            end else begin
                tx_cnt <= tx_cnt;
            end
        end
    end

    always @(posedge clk) begin
        if (!rstn) begin
            en <= 1'b1;
        end else begin
            if (latch_en) begin
                if (tx_cnt < 7) begin
                    en <= 1'b1;
                end else begin
                    en <= 1'b0;
                end
            end else begin
                en <= en;
            end

        end
    end

    generate
        genvar ii;
        for (ii = 0; ii < 4; ii = ii + 1) begin
            util_clk_gen_copy #(
                .CLK_MODE_SEL   (CLK_MODE_SEL),
                .DEFAULT_CLK_DIV(DEFAULT_CLK_DIV)
            ) dut0 (
                .clk     (clk),
                .rstn    (rstn),
                .en      (en),
                .load    (load),
                .baud_div(baud_div),
                .ext_clk (ext_clk),
                .sync_clk(sync_clk[ii]),
                .shift_en(shift_en[ii]),
                .latch_en(latch_en[ii]),
                .CPOL    (CPOL[ii]),
                .CPHA    (CPHA[ii])
            );
        end
    endgenerate

    initial begin
        begin
            #10000;
            $finish;
        end
    end

    always #(TIMEPERIOD / 2) clk = !clk;
    always #20 ext_clk = !ext_clk;

    // reset block
    initial begin
        rstn = 1'b0;
        #(TIMEPERIOD * 2);
        rstn = 1'b1;
    end


    // record block
    initial begin
        $dumpfile("sim/test_tb.lxt");
        $dumpvars(0, util_clk_gen_tb);
    end


endmodule

// verilog_format: off
`resetall
// verilog_format: on
