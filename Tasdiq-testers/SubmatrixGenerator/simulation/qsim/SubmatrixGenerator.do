onerror {quit -f}
vlib work
vlog -work work SubmatrixGenerator.vo
vlog -work work SubmatrixGenerator.vt
vsim -novopt -c -t 1ps -L cycloneii_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate work.SubmatrixGenerator_vlg_vec_tst
vcd file -direction SubmatrixGenerator.msim.vcd
vcd add -internal SubmatrixGenerator_vlg_vec_tst/*
vcd add -internal SubmatrixGenerator_vlg_vec_tst/i1/*
add wave /*
run -all
