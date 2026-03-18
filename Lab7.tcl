# Simulator
set ns [new Simulator]

# Trace
set tf [open drop.tr w]
$ns trace-all $tf

set nf [open drop.nam w]
$ns namtrace-all $nf

# Nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]

# Links (small queue to force packet drop)
$ns duplex-link $n0 $n1 1Mb 10ms DropTail
$ns duplex-link $n1 $n2 1Mb 10ms DropTail

# Queue limit (small -> drop occurs)
$ns queue-limit $n1 $n2 5

# UDP agent
set udp [new Agent/UDP]
$ns attach-agent $n0 $udp

# Null agent
set null [new Agent/Null]
$ns attach-agent $n2 $null

$ns connect $udp $null

# CBR traffic (high rate to cause drop)
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set rate_ 1Mb

# Finish
proc finish {} {
    global ns tf nf
    $ns flush-trace
    close $tf
    close $nf
    exec nam drop.nam &
    exit 0
}

# Schedule
$ns at 1.0 "$cbr start"
$ns at 4.0 "$cbr stop"
$ns at 5.0 "finish"

$ns run
