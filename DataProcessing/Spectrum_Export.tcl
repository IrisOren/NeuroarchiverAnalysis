#
# Spectrum Export, a Neuroarchiver Processor Script.
#
# This processor exports the discrete Fourier transform of channel n during each interval 
# to a file called Sn.txt in the same directory as the NDF file. Each line in the file
# contains the frequency in Hertz and the amplitude of the component in ADC counts. We
# convert counts to uV with the scaling factor 0.4 uV/count in most versions of the A3028
# transmitter.
#
set fn [file join [file dirname $config(play_file)] "S$info(channel_num)\.txt"]
set export_string ""
set f 0
set a_top 0
foreach {a p} $info(spectrum) {
	append export_string "$f $a\n"
	if {$f == 0} {set a_top $p}
	set f [expr $f + $info(f_step)]
}
append export_string "$f [expr abs($a_top)]\n"
set f [open $fn a]
puts -nonewline $f $export_string
close $f
append result "$info(channel_num) [expr [llength $export_string]/2] "