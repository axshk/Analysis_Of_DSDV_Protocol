# A 5-node example for ad-hoc simulation with DSDV

# Define options
set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         100                         ;# max packet in ifq
set val(nn)             20                   ;# number of mobilenodes
set val(rp)             DSDV                       ;# routing protocol
set val(x)              500   			   ;# X dimension of topography
set val(y)              500   			   ;# Y dimension of topography  
set val(stop)		150			   ;# time of simulation end

set ns		  [new Simulator]
set tracefd       [open simple-dsdv.tr w]
set windowVsTime2 [open win.tr w] 
set namtrace      [open simwrls.nam w]    

$ns trace-all $tracefd
$ns use-newtrace 
$ns namtrace-all-wireless $namtrace $val(x) $val(y)

# set up topography object
set topo       [new Topography]

$topo load_flatgrid $val(x) $val(y)

create-god $val(nn)
#
# Define different colors
# for data flows (for NAM)
$ns color 1 Blue

#  Create nn mobilenodes [$val(nn)] and attach them to the channel. 
#

# configure the nodes
        $ns node-config -adhocRouting $val(rp) \
			 -llType $val(ll) \
			 -macType $val(mac) \
			 -ifqType $val(ifq) \
			 -ifqLen $val(ifqlen) \
			 -antType $val(ant) \
			 -propType $val(prop) \
			 -phyType $val(netif) \
			 -channelType $val(chan) \
			 -topoInstance $topo \
			 -agentTrace ON \
			 -routerTrace ON \
			 -movementTrace ON
			 
	for {set i 0} {$i < $val(nn) } { incr i } {
		set node_($i) [$ns node]	
		
	}

# Provide initial location of mobilenodes


#ring topology
#for {set i 0} {$i < $val(nn)} {incr i} {
#    $node_($i) set X_ [expr 250 + 200*cos(2.0*3.14159*($i)/($val(nn)))]
#    $node_($i) set Y_ [expr 250 + 200*sin(2.0*3.14159*($i)/($val(nn)))]
#    $node_($i) set Z_ 0.0
#}


#star topology
# Define the coordinates of the central node (node 0)
#$node_(0) set X_ 250.0
#$node_(0) set Y_ 250.0
#$node_(0) set Z_ 0.0

# Define the coordinates of the other nodes in a star pattern
#for {set i 1} {$i < $val(nn)} {incr i} {
#    set angle [expr 2.0 * 3.14159 * ($i-1) / ($val(nn)-1)]
#    set distance 200.0
#    set x [expr 250.0 + $distance * cos($angle)]
#    set y [expr 250.0 + $distance * sin($angle)]
#    $node_($i) set X_ $x
#    $node_($i) set Y_ $y
#    $node_($i) set Z_ 0.0
#}

#linear topology

# Define the coordinates of the nodes in a linear pattern
#for {set i 0} {$i < $val(nn)} {incr i} {
#    $node_($i) set X_ [expr 100 + ($i * 100)]
#    $node_($i) set Y_ 250.0
#    $node_($i) set Z_ 0.0
#}

#random topology 
set numNodes 20
set maxX 500
set maxY 500

# Generate random coordinates for each node
for {set i 0} {$i < $numNodes} {incr i} {
    set randX [expr {int(rand() * $maxX)}]
    set randY [expr {int(rand() * $maxY)}]
    $node_($i) set X_ $randX
    $node_($i) set Y_ $randY
    $node_($i) set Z_ 0.0
}
$node_(2) set X_ 500
    $node_(2) set Y_ 500
    $node_(2) set Z_ 0.0
# Generation of movements
set numMobileNodes 5
set maxMobileTime 50.0

for {set i 0} {$i < $numMobileNodes} {incr i} {
    set randX [expr {rand() * $maxX}]
    set randY [expr {rand() * $maxY}]
    set randTime [expr {rand() * $maxMobileTime}]
    $ns at $randTime "$node_($i) setdest $randX $randY 5.0"
}

# Set a TCP connection between node_(0) and node_(1)
set tcp [new Agent/TCP/Newreno]
$tcp set class_ 2
$tcp set packetColor_ Red 
set sink [new Agent/TCPSink]
$ns attach-agent $node_(2) $tcp
$ns attach-agent $node_([expr $val(nn) - 1]) $sink
$ns connect $tcp $sink


# Set intermediate nodes for routing
set intermediateNodes [list $node_(0) $node_(1)]

for {set i 3} {$i < $val(nn)-1} {incr i} {
    lappend intermediateNodes $node_($i)
}
# Set up routing through intermediate nodes
foreach intermediateNode $intermediateNodes {
    set tcpIntermediate [new Agent/TCP/Newreno]
    $tcpIntermediate set class_ 1
    set sinkIntermediate [new Agent/TCPSink]

    $ns attach-agent $intermediateNode $tcpIntermediate
    $ns attach-agent $intermediateNode $sinkIntermediate
    $ns connect $tcpIntermediate $sinkIntermediate
}
set ftp [new Application/FTP]
$ftp set packetSize_ 100
$ftp set interval 0.010 
$ftp attach-agent $tcp
$ns at 10.0 "$ftp start" 
 
# for udp connection
#set udp [new Agent/UDP]
#set null [new Agent/Null]
#$ns attach-agent $node_(2) $udp
#$ns attach-agent $node_(4) $null
#$ns connect $udp $null

# Set intermediate nodes for routing
#set intermediateNodes [list $node_(0) $node_(3) $node_(1)]

# Set up routing through intermediate nodes
#foreach intermediateNode $intermediateNodes {
#    set udpIntermediate [new Agent/UDP]
#    set nullIntermediate [new Agent/Null]
#    $ns attach-agent $node_(1) $udpIntermediate
#    $ns attach-agent $intermediateNode $nullIntermediate
#    $ns connect $udpIntermediate $nullIntermediate
#}

# Set up CBR application for data transfer
#set cbr0 [new Application/Traffic/CBR]
#$cbr0 set packetSize_ 100
#$cbr0 set interval 0.010 
#$cbr0 attach-agent $udp
#$ns at 10.0 "$cbr0 start" 

# Define node initial position in nam
for {set i 0} {$i < $val(nn)} { incr i } {
# 30 defines the node size for nam
$ns initial_node_pos $node_($i) 30
}

# Telling nodes when the simulation ends
for {set i 0} {$i < $val(nn) } { incr i } {
    $ns at $val(stop) "$node_($i) reset";
}

# ending nam and the simulation 
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "stop"
$ns at 150.01 "puts \"end simulation\" ; $ns halt"
proc stop {} {
    global ns tracefd namtrace
    $ns flush-trace
    close $tracefd
    close $namtrace
    exec nam simwrls.nam &
}

$ns run
