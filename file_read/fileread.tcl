# Copyright (C) 1991-2012 Altera Corporation
# Your use of Altera Corporation's design tools, logic functions 
# and other software and tools, and its AMPP partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License 
# Subscription Agreement, Altera MegaCore Function License 
# Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 
# programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the 
# applicable agreement for further details.

# Quartus II: Generate Tcl File for Project
# File: fileread.tcl
# Generated on: Mon Mar 18 14:54:53 2013

# Load Quartus II Tcl Project package
package require ::quartus::project

set need_to_close_project 0
set make_assignments 1

# Check that the right project is open
if {[is_project_open]} {
	if {[string compare $quartus(project) "fileread"]} {
		puts "Project fileread is not open"
		set make_assignments 0
	}
} else {
	# Only open if not already open
	if {[project_exists fileread]} {
		project_open -revision fileread fileread
	} else {
		project_new -revision fileread fileread
	}
	set need_to_close_project 1
}

# Make assignments
if {$make_assignments} {
	set_global_assignment -name FAMILY "Cyclone IV GX"
	set_global_assignment -name DEVICE EP4CGX15BF14C6
	set_global_assignment -name TOP_LEVEL_ENTITY intermediate_read
	set_global_assignment -name ORIGINAL_QUARTUS_VERSION 12.1
	set_global_assignment -name PROJECT_CREATION_TIME_DATE "22:50:20  MARCH 15, 2013"
	set_global_assignment -name LAST_QUARTUS_VERSION 12.1
	set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
	set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
	set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85
	set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 1
	set_global_assignment -name NOMINAL_CORE_SUPPLY_VOLTAGE 1.2V
	set_global_assignment -name EDA_SIMULATION_TOOL "ModelSim-Altera (SystemVerilog)"
	set_global_assignment -name EDA_OUTPUT_DATA_FORMAT "SYSTEMVERILOG HDL" -section_id eda_simulation
	set_global_assignment -name EDA_TIME_SCALE "1 ps" -section_id eda_simulation
	set_global_assignment -name EDA_TEST_BENCH_ENABLE_STATUS TEST_BENCH_MODE -section_id eda_simulation
	set_global_assignment -name EDA_NATIVELINK_SIMULATION_TEST_BENCH pcapparser_10gbmac_test -section_id eda_simulation
	set_global_assignment -name EDA_TEST_BENCH_NAME pcapparser_10gbmac_test -section_id eda_simulation
	set_global_assignment -name EDA_DESIGN_INSTANCE_NAME NA -section_id pcapparser_10gbmac_test
	set_global_assignment -name EDA_TEST_BENCH_MODULE_NAME pcapparser_10gbmac_test -section_id pcapparser_10gbmac_test
	set_global_assignment -name POWER_PRESET_COOLING_SOLUTION "23 MM HEAT SINK WITH 200 LFPM AIRFLOW"
	set_global_assignment -name POWER_BOARD_THERMAL_MODEL "NONE (CONSERVATIVE)"
	set_global_assignment -name VERILOG_INPUT_VERSION SYSTEMVERILOG_2005
	set_global_assignment -name VERILOG_SHOW_LMF_MAPPING_MESSAGES OFF
	set_global_assignment -name EDA_TEST_BENCH_FILE pcapparser_10gbmac_test.v -section_id pcapparser_10gbmac_test
	set_global_assignment -name VHDL_FILE file_read.vhd
	set_global_assignment -name VHDL_FILE txt_util.vhd
	set_global_assignment -name VERILOG_FILE intermediate_read.v
	set_global_assignment -name VERILOG_FILE dflipflop.v
	set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
	set_global_assignment -name PARTITION_FITTER_PRESERVATION_LEVEL PLACEMENT_AND_ROUTING -section_id Top
	set_global_assignment -name PARTITION_COLOR 16764057 -section_id Top
	set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top

	# Commit assignments
	export_assignments

	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
