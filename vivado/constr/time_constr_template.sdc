# ----------------- Timing constraints for Linear Interpolator ----------------- #

# Clock constraint: 100 MHz (10 ns period)
set CLK_PERIOD_NS 10.0
set MIN_IO_DELAY [expr double($CLK_PERIOD_NS)/10.0]
set MAX_IO_DELAY [expr double($CLK_PERIOD_NS)/5.0]
create_clock -name clk -period $CLK_PERIOD_NS [get_ports clk]
set_false_path -from [get_ports rst_n] -to [get_clocks clk]
set_input_delay -min $MIN_IO_DELAY [all_inputs]  -clock [get_clocks clk]
set_input_delay -max $MAX_IO_DELAY [all_inputs]  -clock [get_clocks clk]
set_output_delay -min $MIN_IO_DELAY [all_outputs] -clock [get_clocks clk]
set_output_delay -max $MAX_IO_DELAY [all_outputs] -clock [get_clocks clk]
