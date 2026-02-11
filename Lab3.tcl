set val(stop) 50
set ns [new Simulator]

# Open trace file
set tracefile [open p3.tr w]
$ns trace-all $tracefile

# Open nam file
set namfile [open p3.nam w]
$ns namtrace-all $namfile

# Create nodes
set n0 [$ns node]
set n1 [$ns node]

# Labels
$n0 label "SERVER"
$n1 label "CLIENT"

# Shapes
$n0 shape square
$n1 shape square

# Colors
$n0 color red
$n1 color blue

# Attach agents
set tcp0 [new Agent/TCP]
$ns attach-agent $n0 $tcp0

set sink1 [new Agent/TCPSink]
$ns attach-agent $n1 $sink1
$ns connect $tcp0 $sink1

$tcp0 set packetSize_ 1500

# Attach application
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0

$ns at 0.01 "$ftp0 start"
$ns at 20.2 "$ftp0 stop"

# Link
$ns duplex-link $n0 $n1 100Mb 40ms DropTail
$ns queue-limit $n0 $n1 5
$ns duplex-link-op $n0 $n1 orient right

# Flow ID
$ns color 1 red
$tcp0 set fid_ 1

# Finish procedure
proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    close $namfile

    exec nam p3.nam &
    exec awk -f first.awk p3.tr &
    exec awk -f graph.awk p3.tr > p3.dat
    exec xgraph p3.dat -geometry 800x400 -t "Bytes_Received_at_Client" -x "Time_in_sec" -y "Bytes_in_bps" &
    exit 0
}

$ns at $val(stop) "finish"
$ns run
