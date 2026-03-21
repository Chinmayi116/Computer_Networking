# Create simulator object
set ns [new Simulator]

# Open trace file
set tf [open out.tr w]
$ns trace-all $tf

# Create NAM file
set nf [open out.nam w]
$ns namtrace-all $nf

# Create nodes
set n0 [$ns node]
set n1 [$ns node]

# Create link between nodes
$ns duplex-link $n0 $n1 1Mb 10ms DropTail

# Attach TCP agent
set tcp [new Agent/TCP]
$ns attach-agent $n0 $tcp

# Attach Sink
set sink [new Agent/TCPSink]
$ns attach-agent $n1 $sink

# Connect agents
$ns connect $tcp $sink

# Attach FTP application
set ftp [new Application/FTP]
$ftp attach-agent $tcp

# Start and stop
$ns at 0.5 "$ftp start"
$ns at 4.0 "$ftp stop"

# Finish procedure
proc finish {} {
    global ns tf nf
    $ns flush-trace
    close $tf
    close $nf
    exec nam out.nam &
    exit 0
}

$ns at 5.0 "finish"

# Run simulation
$ns run
