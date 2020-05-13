vlib work

vlog -sv counter.sv
vlog -sv top_tb.sv

vsim -novopt top_tb

add log -r /*
add wave -r *
run -all
