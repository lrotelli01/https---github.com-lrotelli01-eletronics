# -------------------------------------------------------------------------- #
# Vivado Synthesis Script
# -------------------------------------------------------------------------- #

# Create project
create_project linear_interpolator_proj ./project -part xc7a35tcpg236-1 -force

# Add VHDL source files
add_files -fileset sources_1 [glob ../model/*.vhdl]

# Add constraints
add_files -fileset constrs_1 [glob ./constr/*.sdc]

# Set top-level module
set_property top linear_interpolator [current_fileset]

# Run synthesis
launch_runs synth_1 -jobs 4
wait_on_run synth_1

# Open synthesized design
open_run synth_1

# Report utilization and timing
report_utilization -file ./utilization_report.txt
report_timing_summary -file ./timing_report.txt

puts "Synthesis completed successfully!"
