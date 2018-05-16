# find ../ -name "*.ndf" -print | xargs -n1 -P2 ~/Active/LWDAQ/lwdaq --pipe config.tcl SCPP4V2.tcl
LWDAQ_run_tool Neuroarchiver.tcl
set Neuroarchiver_config(processor_file) [lindex $LWDAQ_Info(argv) 0]
set Neuroarchiver_config(play_file) [lindex $LWDAQ_Info(argv) 1]
set Neuroarchiver_info(play_control) Play
set Neuroarchiver_config(play_interval) 8
set Neuroarchiver_config(enable_processing) 1
set Neuroarchiver_config(save_processing) 1
set Neuroarchiver_config(play_stop_at_end) 1
set Neuroarchiver_config(glitch_threshold) 200
set Neuroarchiver_config(channel_select) "14:512"
LWDAQ_watch Neuroarchiver_info(play_control) Idle exit
Neuroarchiver_play
