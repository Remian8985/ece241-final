onerror {quit -f}
vlib work
vlog -work work Grouper.vo
vlog -work work Grouper.vt
vsim -novopt -c -t 1ps -L cycloneii_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate work.Grouper_vlg_vec_tst
vcd file -direction Grouper.msim.vcd
vcd add -internal Grouper_vlg_vec_tst/*
vcd add -internal Grouper_vlg_vec_tst/i1/*
add wave /*
run -all
