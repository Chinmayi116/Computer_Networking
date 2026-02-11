set ns [new Simulator] 
set tracefile [open t4.tr w] 
$ns trace-all $tracefile 
$ns color 1 red 
$ns color 2 blue 

set namfile [open t4.nam w] 
$ns namtrace-all $namfile 

set n0 [$ns node]  
set n1 [$ns node]  
set n2 [$ns node]  
set n3 [$ns node]  
set n4 [$ns node]  
set n5 [$ns node]  
set n6 [$ns node]  
set n7 [$ns node] 

$n0 shape "circle" 
$n1 shape "square" 
$n2 shape "circle" 
$n3 shape "circle" 
$n4 shape "circle" 
$n5 shape "circle" 
$n6 shape "circle" 
$n7 shape "circle" 

$n0 label "TCP-SOURCE" 
$n1 label "UDP-SOURCE" 
$n2 label "Router" 
$n3 label "Router" 
$n6 label "TCP-Sink" 
$n7 label "UDP-Null" 

set tcp0 [new Agent/TCP]
$ns attach-agent $n0 $tcp0 

set sink6 [new Agent/TCPSink] 
$ns attach-agent $n6 $sink6 
$ns connect $tcp0 $sink6 

$ns duplex-link $n0 $n2 1.0Mb 10ms DropTail 
$ns duplex-link $n1 $n2 1.0Mb 10ms DropTail 
$ns duplex-link $n2 $n3 2.0Mb 10ms DropTail 
$ns duplex-link $n3 $n4 1.0Mb 10ms DropTail 
$ns duplex-link $n3 $n5 1.0Mb 10ms DropTail 
$ns duplex-link $n4 $n6 1.0Mb 10ms DropTail 
$ns duplex-link $n5 $n7 1.0Mb 10ms DropTail 

$ns duplex-link-op $n0 $n2 orient right-down 
$ns duplex-link-op $n1 $n2 orient right-up 
$ns duplex-link-op $n2 $n3 orient right 
$ns duplex-link-op $n3 $n4 orient right-up 
$ns duplex-link-op $n3 $n5 orient right-down 
$ns duplex-link-op $n4 $n6 orient right 
$ns duplex-link-op $n5 $n7 orient right 

set udp1 [new Agent/UDP] 
$ns attach-agent $n1 $udp1 

set null7 [new Agent/Null] 
$ns attach-agent $n7 $null7 
$ns connect $udp1 $null7 

set ftp0 [new Application/FTP] 
$ftp0 attach-agent $tcp0 

set cbr0 [new Application/Traffic/CBR] 
$cbr0 attach-agent $udp1 
$cbr0 set rate_ 0.5Mb

$tcp0 set packetSize_ 1500 
$udp1 set packetSize_ 1500 
$tcp0 set fid_ 1 
$udp1 set fid_ 2 

$ns at 0.1 "$cbr0 start" 
$ns at 10.0 "$cbr0 stop" 
$ns at 0.1 "$ftp0 start" 
$ns at 10.0 "$ftp0 stop" 

proc finish {} { 
    global ns tracefile namfile 
    $ns flush-trace  
    close $tracefile  
    close $namfile 
    exec nam t4.nam & 
    exec awk -f term4.awk t4.tr & 
    exec xgraph data.dat -geometry 800x400 "Throughput" -y "Bandwidth" -bg white & 
    exit 0 
} 

$ns at 10.1 "finish" 
$ns run
