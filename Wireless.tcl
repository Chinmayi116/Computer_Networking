set ns [new Simulator]

set tf [open wireless.tr w]
$ns trace-all $tf

set nf [open wireless.nam w]
$ns namtrace-all-wireless $nf 500 500

# Topography
set topo [new Topography]
$topo load_flatgrid 500 500

# Create God
create-god 3

# Node configuration
$ns node-config -adhocRouting AODV \
                -llType LL \
                -macType Mac/802_11 \
                -ifqType Queue/DropTail/PriQueue \
                -ifqLen 50 \
                -antType Antenna/OmniAntenna \
                -propType Propagation/TwoRayGround \
                -phyType Phy/WirelessPhy \
                -channelType Channel/WirelessChannel \
                -topoInstance $topo \
                -agentTrace ON \
                -routerTrace ON \
                -macTrace ON

# Create nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]

# Initial positions
$n0 set X_ 100; $n0 set Y_ 100; $n0 set Z_ 0
$n1 set X_ 200; $n1 set Y_ 200; $n1 set Z_ 0
$n2 set X_ 300; $n2 set Y_ 300; $n2 set Z_ 0

# Movement
$ns at 1.0 "$n1 setdest 400 400 10"

# UDP
set udp [new Agent/UDP]
$ns attach-agent $n0 $udp

set null [new Agent/Null]
$ns attach-agent $n2 $null

$ns connect $udp $null

# CBR
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set rate_ 200Kb

$ns at 2.0 "$cbr start"
$ns at 5.0 "$cbr stop"

proc finish {} {
    global ns tf nf
    $ns flush-trace
    close $tf
    close $nf
    exec nam wireless.nam &
    exit 0
}

$ns at 6.0 "finish"
$ns run
