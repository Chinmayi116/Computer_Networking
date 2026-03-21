set ns [new Simulator]

set tf [open udp.tr w]
$ns trace-all $tf

set nf [open udp.nam w]
$ns namtrace-all $nf

# Nodes
set n0 [$ns node]
set n1 [$ns node]

# Link
$ns duplex-link $n0 $n1 1Mb 10ms DropTail

# UDP agent
set udp [new Agent/UDP]
$ns attach-agent $n0 $udp

# Null agent
set null [new Agent/Null]
$ns attach-agent $n1 $null

# Connect
$ns connect $udp $null

# CBR traffic
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set rate_ 500Kb

# Start/Stop
$ns at 0.5 "$cbr start"
$ns at 4.0 "$cbr stop"

proc finish {} {
    global ns tf nf
    $ns flush-trace
    close $tf
    close $nf
    exec nam udp.nam &
    exit 0
}

$ns at 5.0 "finish"
$ns run
