vlib work

vlog -sv ../../rtl/lfsr_9bit.sv
vlog -sv prbs_tb.sv

vsim -novopt prbs_tb
add log -r /*
add wave -r *
run -all

