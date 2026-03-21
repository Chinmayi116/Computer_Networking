set ns [new Simulator]

set tf [open drop.tr w]
$ns trace-all $tf

set nf [open drop.nam w]
$ns namtrace-all $nf

# Nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]

# Links (low bandwidth to cause drop)
$ns duplex-link $n0 $n1 1Mb 10ms DropTail
$ns duplex-link $n1 $n2 0.5Mb 20ms DropTail

# TCP
set tcp [new Agent/TCP]
$ns attach-agent $n0 $tcp

set sink [new Agent/TCPSink]
$ns attach-agent $n2 $sink

$ns connect $tcp $sink

# FTP
set ftp [new Application/FTP]
$ftp attach-agent $tcp

$ns at 0.5 "$ftp start"
$ns at 4.0 "$ftp stop"

proc finish {} {
    global ns tf nf
    $ns flush-trace
    close $tf
    close $nf
    exec nam drop.nam &
    exit 0
}

$ns at 5.0 "finish"
$ns run
