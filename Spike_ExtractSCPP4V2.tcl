LWDAQ_print $t "Asking for input file list..."
set fnl [LWDAQ_get_file_name 1]
set data [list]
foreach fn $fnl { 
  set f [open $fn r]
  set data [concat $data [split [read $f] \n]]
	close $f
	LWDAQ_print $t [file tail $fn]
  LWDAQ_support
}

LWDAQ_print $t "Asking for output file name..."
set ofn [LWDAQ_put_file_name]

LWDAQ_print $t "Making spike list..."
LWDAQ_update
foreach c $data {
  set archive [lindex $c 0]
  set archive_time [lindex $c 1]
  set c [lrange $c 2 end]
  foreach {id loss num_spikes num_bursts delta theta gamma1 gamma2 broadband1 broadband2} $c {
    if {($num_spikes+$num_bursts > 0) \
          && ($loss < 20) \
          && ($delta < 1000)} {
      LWDAQ_print $ofn "$archive $archive_time\
        $id $loss $num_spikes $num_bursts $delta $theta $gamma1 $gamma2 $broadband1 $broadband2"
    }
  }
}