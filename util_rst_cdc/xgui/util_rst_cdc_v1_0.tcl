# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "RST_TYPE" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "IN_POLARITY" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "OUT_POLARITY" -parent ${Page_0} -widget comboBox


}

proc update_PARAM_VALUE.DEST_SYNC_FF { PARAM_VALUE.DEST_SYNC_FF } {
	# Procedure called to update DEST_SYNC_FF when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEST_SYNC_FF { PARAM_VALUE.DEST_SYNC_FF } {
	# Procedure called to validate DEST_SYNC_FF
	return true
}

proc update_PARAM_VALUE.INIT_SYNC_FF { PARAM_VALUE.INIT_SYNC_FF } {
	# Procedure called to update INIT_SYNC_FF when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INIT_SYNC_FF { PARAM_VALUE.INIT_SYNC_FF } {
	# Procedure called to validate INIT_SYNC_FF
	return true
}

proc update_PARAM_VALUE.IN_POLARITY { PARAM_VALUE.IN_POLARITY } {
	# Procedure called to update IN_POLARITY when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IN_POLARITY { PARAM_VALUE.IN_POLARITY } {
	# Procedure called to validate IN_POLARITY
	return true
}

proc update_PARAM_VALUE.OUT_POLARITY { PARAM_VALUE.OUT_POLARITY } {
	# Procedure called to update OUT_POLARITY when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OUT_POLARITY { PARAM_VALUE.OUT_POLARITY } {
	# Procedure called to validate OUT_POLARITY
	return true
}

proc update_PARAM_VALUE.RST_TYPE { PARAM_VALUE.RST_TYPE } {
	# Procedure called to update RST_TYPE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RST_TYPE { PARAM_VALUE.RST_TYPE } {
	# Procedure called to validate RST_TYPE
	return true
}

proc update_PARAM_VALUE.SIM_ASSERT_CHK { PARAM_VALUE.SIM_ASSERT_CHK } {
	# Procedure called to update SIM_ASSERT_CHK when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SIM_ASSERT_CHK { PARAM_VALUE.SIM_ASSERT_CHK } {
	# Procedure called to validate SIM_ASSERT_CHK
	return true
}


proc update_MODELPARAM_VALUE.DEST_SYNC_FF { MODELPARAM_VALUE.DEST_SYNC_FF PARAM_VALUE.DEST_SYNC_FF } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEST_SYNC_FF}] ${MODELPARAM_VALUE.DEST_SYNC_FF}
}

proc update_MODELPARAM_VALUE.INIT_SYNC_FF { MODELPARAM_VALUE.INIT_SYNC_FF PARAM_VALUE.INIT_SYNC_FF } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INIT_SYNC_FF}] ${MODELPARAM_VALUE.INIT_SYNC_FF}
}

proc update_MODELPARAM_VALUE.SIM_ASSERT_CHK { MODELPARAM_VALUE.SIM_ASSERT_CHK PARAM_VALUE.SIM_ASSERT_CHK } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SIM_ASSERT_CHK}] ${MODELPARAM_VALUE.SIM_ASSERT_CHK}
}

proc update_MODELPARAM_VALUE.RST_TYPE { MODELPARAM_VALUE.RST_TYPE PARAM_VALUE.RST_TYPE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RST_TYPE}] ${MODELPARAM_VALUE.RST_TYPE}
}

proc update_MODELPARAM_VALUE.IN_POLARITY { MODELPARAM_VALUE.IN_POLARITY PARAM_VALUE.IN_POLARITY } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.IN_POLARITY}] ${MODELPARAM_VALUE.IN_POLARITY}
}

proc update_MODELPARAM_VALUE.OUT_POLARITY { MODELPARAM_VALUE.OUT_POLARITY PARAM_VALUE.OUT_POLARITY } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OUT_POLARITY}] ${MODELPARAM_VALUE.OUT_POLARITY}
}

