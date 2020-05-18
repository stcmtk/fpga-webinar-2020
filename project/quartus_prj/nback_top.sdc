set_time_format -unit ns -decimal_places 3

create_clock -name {clk_50} -period 20.000 -waveform { 0.000 10.000 } [get_ports {clk_50_mhz_i}]

derive_clock_uncertainty
