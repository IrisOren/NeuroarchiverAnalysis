set fn [file join [file dirname $config(play_file)] \
  "E$info(channel_num)\.txt"]
set export_string ""
foreach {timestamp value} $info(signal) {
  append export_string "$value\n"
}
set f [open $fn a]
puts -nonewline $f $export_string
close $f
append result "$info(channel_num) [llength $export_string] "
