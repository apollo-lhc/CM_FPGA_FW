puts $argc
puts $argv
set port 2544
set ip -1
if { $argc == 2 } {
    set port [lindex $argv 1]
    set ip  [lindex $argv 0]
} elseif {$argc == 1} {
    set ip  [lindex $argv 0]
}

open_hw
connect_hw_server

if { $ip != -1 } {
    open_hw_target -xvc_url ${ip}:${port}
}
