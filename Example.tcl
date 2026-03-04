# Create Simulator
set ns [new Simulator]

# Open Trace Files
set tracefile [open out.tr w]
$ns trace-all $tracefile

set namfile [open out.nam w]
$ns namtrace-all $namfile

# Define Finish Procedure
proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    close $namfile
    exec nam out.nam &
    exit 0
}

# Create 8 Nodes (0 to 7) – RED
for {set i 0} {$i < 8} {incr i} {
    set n($i) [$ns node]
}

# Create Duplex Links (100 Mbps)
for {set i 0} {$i < 7} {incr i} {
    $ns duplex-link $n($i) $n([expr $i+1]) 100Mb 10ms RED
}

# Additional RED links
$ns duplex-link $n(3) $n(4) 2Mb 10ms RED
$ns duplex-link $n(2) $n(3) 1Mb 10ms RED

# Create 6 Nodes (0 to 5) – DropTail
for {set i 0} {$i < 6} {incr i} {
    set d($i) [$ns node]
}

for {set i 0} {$i < 5} {incr i} {
    $ns duplex-link $d($i) $d([expr $i+1]) 100Mb 10ms DropTail
}

# -------------------------
# TCP Connection (n0 to n5)
# -------------------------
set tcp0 [new Agent/TCP]
$ns attach-agent $n(0) $tcp0

set sink0 [new Agent/TCPSink]
$ns attach-agent $n(5) $sink0

$ns connect $tcp0 $sink0

set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0

# -------------------------
# UDP Connection (n1 to n4)
# -------------------------
set udp0 [new Agent/UDP]
$ns attach-agent $n(1) $udp0

set null0 [new Agent/Null]
$ns attach-agent $n(4) $null0

$ns connect $udp0 $null0

set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $udp0
$cbr0 set packetSize_ 1000
$cbr0 set interval_ 0.005

# -------------------------
# TCP (n2 to n7)
# -------------------------
set tcp1 [new Agent/TCP]
$ns attach-agent $n(2) $tcp1

set sink1 [new Agent/TCPSink]
$ns attach-agent $n(7) $sink1

$ns connect $tcp1 $sink1

set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1

# -------------------------
# UDP (n1 to n6)
# -------------------------
set udp1 [new Agent/UDP]
$ns attach-agent $n(1) $udp1

set null1 [new Agent/Null]
$ns attach-agent $n(6) $null1

$ns connect $udp1 $null1

set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp1
$cbr1 set packetSize_ 512
$cbr1 set interval_ 0.01

# Schedule Events
$ns at 0.5 "$ftp0 start"
$ns at 1.0 "$cbr0 start"
$ns at 1.5 "$ftp1 start"
$ns at 2.0 "$cbr1 start"

$ns at 5.0 "$ftp0 stop"
$ns at 5.5 "$cbr0 stop"
$ns at 6.0 "$ftp1 stop"
$ns at 6.5 "$cbr1 stop"

$ns at 7.0 "finish"

# Run Simulation
$ns run
