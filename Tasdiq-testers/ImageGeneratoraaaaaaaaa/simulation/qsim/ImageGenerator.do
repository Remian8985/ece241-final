onerror {quit -f}
vlib work
vlog -work work ImageGenerator.vo
vlog -work work ImageGenerator.vt
vsim -novopt -c -t 1ps -L cycloneii_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate work.ImageGenerator_vlg_vec_tst
vcd file -direction ImageGenerator.msim.vcd
vcd add -internal ImageGenerator_vlg_vec_tst/*
vcd add -internal ImageGenerator_vlg_vec_tst/i1/*
add wave /*
run -all
