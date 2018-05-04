# Spike Count and Power Processor
#
# This processor produces characteristics containing the channel number,
# the signal loss a percentage of the expected number of messages, the
# number of spikes found in the interval, the delta power of the interval
# in k-sq-counts, and the theta power in k-sq-counts. To obtain root mean
# square amplitude of the delta and theta signals, divide by two and take the
# square root of the power to obtain a value in counts, then multiply by
# 0.4 uV/count for most versions of the A3028. The spike count is expressed 
# as a real number in the result string, even though it is an integer, because
# the only integers allowed in charachteristics strings are the channel 
# numbers.
#
# In addition to the characteristics, the processor also exports each active
# channel to a separate text file in the same directory as the processor
# script. This export takes place only when the Neuroarchiver's Save option
# is selected for Processing, and when the local export flag is set below.
#
# v2 MODIFIED 09/02/18. Calculation of bands Gamma1, Gamma2, Broadband1, Broadband2.
# Gamma1 is based on Verret et al, Gamma2 excludes 
# beta bands.

# Turn on the export with 1, disable with 0.
set export 0

# Export signal to text file in same directory as processor script. The file will
# be named En.txt where n is the channel number. We export the signa only if the
# save processing option is checked.
if {$config(save_processing) && $export} {
	set fn [file join [file dirname $config(processor_file)] "E$info(channel_num)\.txt"]
	set export_string ""
	foreach {timestamp value} $info(signal) {append export_string "$value\n"}
	set f [open $fn a]
	puts -nonewline $f $export_string
	close $f
}

# Configure the processor diagnostic displays.
set show_spikiness 0
set show_theta 0
set show_delta 0
set show_gamma1 0
set show_gamma2 0
set show_broadband1 0
set show_broadband2 0

# Define the theta and reference bands.
set theta_lo 4.0
set theta_hi 12.0
set delta_lo 0.1
set delta_hi 3.9
set gamma1_lo 20 
set gamma1_hi 80
#Gamma1 is based on Verret et al
set gamma2_lo 40 
set gamma2_hi 80
set broadband1_lo 5
set broadband2_lo 0.1
set broadband_hi 160


# The feature_extent is the maximum width of a spike or burst we want
# to count. The units are samples, so specify an integer. The feature
# threshold is height of a spike or burst we want to count in multiples
# of the mean absolute step size.
set feature_threshold 20
set feature_extent 40
set burst_num_spikes 3

# We calculate spike detection threshold and extent from the feature
# threshold and extent.
set spike_threshold [expr $feature_threshold / 4.0]
set spike_extent [expr $feature_extent / 4]

# We begin this channel's section of the characteristics line with the 
# channel number.
append result "$info(channel_num) "

# If we have too much signal loss, we ignore this interval.
set max_loss 40.0

# We need to calculate the fourier transform so we can get the theta metric.
set config(af_calculate) 1

# The following code calculates the theta metric by summing the power in the
# theta band and dividing by the power in the reference band.
set theta_pwr [expr 0.001*[Neuroarchiver_band_power $theta_lo $theta_hi $show_theta 0]]
set delta_pwr [expr 0.001*[Neuroarchiver_band_power $delta_lo $delta_hi $show_delta 0]]
set gamma1_pwr [expr 0.001*[Neuroarchiver_band_power $gamma1_lo $gamma1_hi $show_gamma1 0]]
set gamma2_pwr [expr 0.001*[Neuroarchiver_band_power $gamma2_lo $gamma2_hi $show_gamma2 0]]
set broadband1_pwr [expr 0.001*[Neuroarchiver_band_power $broadband1_lo $broadband_hi $show_broadband1 0]]
set broadband2_pwr [expr 0.001*[Neuroarchiver_band_power $broadband2_lo $broadband_hi $show_broadband2 0]]

# Find spikes and count them.
set small_spikes [lwdaq spikes_x $info(values) $spike_threshold $spike_extent]

# Select solitary spikes and burst spikes.
set spikes [list]
set bursts [list]
foreach {index height} $small_spikes {
	set spike "[format %.0f $index] [format %.1f $height]"
 	if {$height >= $feature_threshold} {
		set solitary $burst_num_spikes
		foreach {i h} $small_spikes {
			if {($i != $index) && (abs($i-$index)<$feature_extent)} {
				set solitary [expr $solitary - 1]
			}
		}
		if {$solitary >= 1} {
			if {([llength $spikes] == 0) || ([lindex $spikes end 0]<$index-$feature_extent)} {
				lappend spikes $spike
				if {$show_spikiness} {
					Neuroarchiver_print "Spike: $spike" orange
				}
			}
		} {
			set unique 1
			foreach b $bursts {
				scan $b %f%f i h
				if {($i != $index) && (abs($i-$index)<$feature_extent)} {
					set unique 0
				}
			}
			if {$unique} {
				lappend bursts $spike
				if {$show_spikiness} {
					Neuroarchiver_print "Burst: $spike" darkgreen
				}
			}
		}
	}
}

# We have the number of spikes. We must format it as a real number.
set num_spikes [format %.1f [llength $spikes]]
set num_bursts [format %.1f [llength $bursts]]

# Show the spikes along the bottom if asked.
if {$show_spikiness && [winfo exists $info(window)]} {
	if {[llength $spikes] > 0} {
		set spike_marks "0 -1 "
		foreach s $spikes {
			set i [lindex $s 0]
			set h [lindex $s 1]
			append spike_marks "$i -1.0 $i 0 $i -1.0 "
		}
		append spike_marks "[llength $info(values)] -1"
		lwdaq_graph $spike_marks $info(vt_image) -color 3 \
			-y_max 0 -y_min -10.0 \
			-x_min 0.0 -x_max [expr [llength $info(values)]-1]
	}
	if {[llength $bursts] > 0} {
		set burst_marks "0 1 "
		foreach s $bursts {
			set i [lindex $s 0]
			set h [lindex $s 1]
			append burst_marks "$i 1 $i 0 $i 1 "
		}
		append burst_marks "[llength $info(values)] 1"
		lwdaq_graph $burst_marks $info(vt_image) -color 13 \
			-y_max 10 -y_min 0 \
			-x_min 0.0 -x_max [expr [llength $info(values)]-1]
	}
}

# Write the loss, the number of spikes, delta power, theta power, gamma1 power, gamma2 power and broadband power to 
# characteristics string.
append result "[format %.1f $info(loss)]\
	$num_spikes\
	$num_bursts\
	[format %.3f $delta_pwr]\
	[format %.3f $theta_pwr]\
	[format %.3f $gamma1_pwr]\
	[format %.3f $gamma2_pwr]\
	[format %.3f $broadband1_pwr]\
	[format %.3f $broadband2_pwr]"
	