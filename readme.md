# HDL库README

此库包含了一系列用于硬件设计的基础模块。

```txt
utils
├─sim
│      util_clk_gen_tb.v
│      util_clk_monitor_tb.v
│      util_iic_trans_tb.v
│      util_io_loop_tb.v
│      util_io_test_tb.v
│      util_metastable_tb.v
│      util_parallel_dds_tb.v
│      util_spi_trans_tb.v
│      util_stream_master_tb.v
│      util_trafic_receiver_tb.v
│      util_watch_dog_tb.v
├─src
│      sim_app_task.v
│      sim_axi_task.v
│      sim_clock_rst.v
│      util_cdc.v
│      util_clk_gen.v
│      util_clk_monitor.v
│      util_fifo_master.v
│      util_filter.v
│      util_iic_trans.v
│      util_io_loop.v
│      util_io_test.v
│      util_io_trans.v
│      util_led_blink.v
│      util_loop_checker.v
│      util_metastable.v
│      util_parallel_dds.v
│      util_pulse_dly.v
│      util_reset_controller.v
│      util_sequences_detector.v
│      util_sequences_generator.v
│      util_spi_clk_gen.v
│      util_spi_trans.v
│      util_stream_master.v
│      util_swap.v
│      util_trafic_generator.v
│      util_trafic_monitor.v
│      util_trafic_receiver.v
│      util_watch_dog.v
├─tcl
│      add_to_project.tcl
└─util_rst_cdc
    │  component.xml
    ├─bd
    │      bd.tcl
    ├─hdl
    │      util_rst_cdc.v
    └─xgui
            util_rst_cdc_v1_0.tcl
```