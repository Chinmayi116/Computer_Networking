# ===== Simulation Parameters =====
set val(stop) 10.0

# Create Simulator
set ns [new Simulator]

# Colors for flows
$ns color 1 blue
$ns color 2 red

# Trace and NAM files
set tracefile [open p1.tr w]
$ns trace-all $tracefile

set namfile [open p1.nam w]
$ns namtrace-all $namfile

# Create Nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]

# Labels
$n0 label "TCP-Source"
$n1 label "UDP-Source"
$n2 label "UDP-Dest"
$n3 label "TCP-Dest"
$n4 label "Router"

# Shapes
$n0 shape square
$n1 shape square
$n2 shape hexagon
$n3 shape hexagon
$n4 shape circle

# Colors
$n0 color green
$n1 color green
$n2 color red
$n3 color red
$n4 color black

# Links
$ns duplex-link $n0 $n4 100Mb 40ms DropTail
$ns queue-limit $n0 $n4 5

$ns duplex-link $n4 $n3 100Mb 40ms DropTail
$ns queue-limit $n4 $n3 5

$ns duplex-link $n1 $n4 100Mb 40ms DropTail
$ns queue-limit $n1 $n4 5

$ns duplex-link $n4 $n2 100Mb 40ms DropTail
$ns queue-limit $n4 $n2 5

# Orientation
$ns duplex-link-op $n4 $n0 orient left-down
$ns duplex-link-op $n1 $n4 orient left-up
$ns duplex-link-op $n3 $n4 orient left-down
$ns duplex-link-op $n2 $n4 orient right-down

# ===== Agents =====
# TCP
set tcp0 [new Agent/TCP]
$ns attach-agent $n0 $tcp0

set sink3 [new Agent/TCPSink]
$ns attach-agent $n3 $sink3

$ns connect $tcp0 $sink3
$tcp0 set packetSize_ 1000
$tcp0 set fid_ 1

# UDP
set udp1 [new Agent/UDP]
$ns attach-agent $n1 $udp1

set null2 [new Agent/Null]
$ns attach-agent $n2 $null2

$ns connect $udp1 $null2
$udp1 set packetSize_ 1000
$udp1 set fid_ 2

# ===== Applications =====
# CBR over TCP
set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $tcp0
$cbr0 set packetSize_ 1000
$cbr0 set rate_ 3Mb
$cbr0 set random_ false

# CBR over UDP
set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp1
$cbr1 set packetSize_ 1000
$cbr1 set rate_ 3Mb
$cbr1 set random_ false

# Start/Stop Traffic
$ns at 0.01 "$cbr0 start"
$ns at 0.99 "$cbr0 stop"

$ns at 0.1 "$cbr1 start"
$ns at 9.0 "$cbr1 stop"

# ===== Finish Procedure =====
proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    close $namfile
    exec nam p1.nam &
    exit 0
}

# End Simulation
$ns at $val(stop) "finish"
$ns run
