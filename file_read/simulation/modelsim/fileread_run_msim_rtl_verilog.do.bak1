transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+/home/user2/spring13/asc2171/Documents/TOE/file_read {/home/user2/spring13/asc2171/Documents/TOE/file_read/addsub.v}

vlog -sv -work work +incdir+/home/user2/spring13/asc2171/Documents/TOE/file_read {/home/user2/spring13/asc2171/Documents/TOE/file_read/pcapparser_10gbmac_test.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneiv_hssi_ver -L cycloneiv_pcie_hip_ver -L cycloneiv_ver -L rtl_work -L work -voptargs="+acc"  pcapparser_10gbmac_test

add wave *
view structure
view signals
run -all
