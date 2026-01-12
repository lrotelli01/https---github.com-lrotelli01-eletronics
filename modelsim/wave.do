onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_linear_interpolator/clk_tb
add wave -noupdate /tb_linear_interpolator/rst_n_tb
add wave -noupdate /tb_linear_interpolator/run_simulation
add wave -noupdate -format Analog-Step -height 84 -max 32767.0 -min -32768.0 /tb_linear_interpolator/din_tb
add wave -noupdate -format Analog-Step -height 84 -max 32767.0 -min -32768.0 /tb_linear_interpolator/dout_tb
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {485000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {750750 ps}
