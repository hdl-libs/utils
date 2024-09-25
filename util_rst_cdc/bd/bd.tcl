source [::bd::get_vlnv_dir xilinx.com:ip:ifx_util:1.1]/bd/ifx_common_debug_util.tcl
source [::bd::get_vlnv_dir xilinx.com:ip:ifx_util:1.1]/bd/ifx_common_ipi_util.tcl
source [::bd::get_vlnv_dir xilinx.com:ip:ifx_util:1.1]/bd/ifx_common_appcore_util.tcl

proc init { this args} {
  bd::mark_propagate_overrideable [get_bd_cells $this] {IN_POLARITY}
}

proc post_propagate { this args } {

  ifx_debug_proc_header

  set obj [get_bd_cells $this]

  set out_polarity [get_property CONFIG.OUT_POLARITY [get_bd_cells $obj]]
  set in_polarity  [get_property CONFIG.POLARITY [get_bd_pins $obj/src_in]]

  puts "$out_polarity"
  puts "$in_polarity"

  puts [get_bd_pins $obj/dest_out]

  set_property CONFIG.IN_POLARITY $in_polarity [get_bd_cells $obj]
  set_property CONFIG.POLARITY $out_polarity [get_bd_pins $obj/dest_out]

  ifx_debug_proc_footer
  return 0
}

ifx_debug_trace_setup
