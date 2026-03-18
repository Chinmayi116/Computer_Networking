# Create a simulator object
set ns [new Simulator]

# Open trace file
set tf [open out.tr w]
$ns trace-all $tf

# Open NAM file (for animation)
set nf [open out.nam w]
$ns namtrace-all $nf

# Create nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]

# Create links between nodes
$ns duplex-link $n0 $n1 1Mb 10ms DropTail
$ns duplex-link $n1 $n2 1Mb 10ms DropTail

# Set queue size
$ns queue-limit $n0 $n1 50
$ns queue-limit $n1 $n2 50

# Create TCP agent
set tcp [new Agent/TCP]
$ns attach-agent $n0 $tcp

# Create Sink (receiver)
set sink [new Agent/TCPSink]
$ns attach-agent $n2 $sink

# Connect TCP and Sink
$ns connect $tcp $sink

# Create FTP application
set ftp [new Application/FTP]
$ftp attach-agent $tcp

# Define finish procedure
proc finish {} {
    global ns tf nf
    $ns flush-trace
    close $tf
    close $nf
    exec nam out.nam &
    exit 0
}

# Schedule events
$ns at 1.0 "$ftp start"
$ns at 5.0 "$ftp stop"
$ns at 6.0 "finish"

# Run simulation
$ns run
