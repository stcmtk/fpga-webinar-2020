vlib work

vlog -sv ../../rtl/nback_logic.sv
vlog -sv nback_logic_tb.sv

vsim -novopt nback_logic_tb
add log -r /*
add wave -r *
run -all

