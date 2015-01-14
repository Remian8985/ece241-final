onerror {quit -f}
vlib work
vlog -work work ShiftRegister.vo
vlog -work work ShiftRegister.vt
vsim -novopt -c -t 1ps -L cycloneii_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate work.ShiftRegister_vlg_vec_tst
vcd file -direction ShiftRegister.msim.vcd
vcd add -internal ShiftRegister_vlg_vec_tst/*
vcd add -internal ShiftRegister_vlg_vec_tst/i1/*
add wave /*
run -all
