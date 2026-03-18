# Create simulator
set ns [new Simulator]

# Trace files
set tf [open delay.tr w]
$ns trace-all $tf

set nf [open delay.nam w]
$ns namtrace-all $nf

# Create nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]

# Create links (different delays)
$ns duplex-link $n0 $n1 1Mb 10ms DropTail
$ns duplex-link $n1 $n2 1Mb 50ms DropTail

# UDP agent
set udp [new Agent/UDP]
$ns attach-agent $n0 $udp

# Null agent
set null [new Agent/Null]
$ns attach-agent $n2 $null

# Connect agents
$ns connect $udp $null

# CBR traffic
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set rate_ 200Kb

# Finish procedure
proc finish {} {
    global ns tf nf
    $ns flush-trace
    close $tf
    close $nf
    exec nam delay.nam &
    exit 0
}

# Schedule events
$ns at 1.0 "$cbr start"
$ns at 4.0 "$cbr stop"
$ns at 5.0 "finish"

# Run simulation
$ns run
