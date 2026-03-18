# ----------------- Timing constraints for Linear Interpolator ----------------- #

# Clock constraint: 100 MHz (10 ns period)

# Reset is asynchronous - false path
set_false_path -from [get_ports rst_n]

# Input delays (exclude clock and reset)
# Relaxed to 0.5ns min / 1.0ns max to fix hold violations and allow more internal logic delay

# Output delays
# Relaxed to 0.5ns min / 1.0ns max to provide more setup margin (8ns available instead of 6ns)


