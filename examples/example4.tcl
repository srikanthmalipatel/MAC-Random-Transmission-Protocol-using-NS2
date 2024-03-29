# topology 

#Create a simulator object
set ns [new Simulator]

$ns color 1 Blue
$ns color 2 Red

#Open the nam trace file
set nf [open out.nam w]
$ns namtrace-all $nf

#Define a 'finish' procedure
proc finish {} {
        global ns nf
        $ns flush-trace
	#Close the trace file
        close $nf
	#Execute nam on the trace file
        exec nam out.nam &
        exit 0
}

# Insert your own code for topology creation
# and agent definitions, etc. here

# create nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

# link properties between nodes
$ns duplex-link $n0 $n2 1Mb 10ms DropTail
$ns duplex-link $n1 $n2 1Mb 10ms DropTail
$ns duplex-link $n3 $n2 1Mb 10ms SFQ 

$ns duplex-link-op $n0 $n2 orient right-down      
$ns duplex-link-op $n1 $n2 orient right-up 
$ns duplex-link-op $n2 $n3 orient right
$ns duplex-link-op $n2 $n3 queuePos 0.5

# for each node create udp agents with cbr traffic sources
#for node 0
set udp0 [new Agent/UDP]
$udp0 set class_ 1
$ns attach-agent $n0 $udp0
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 500
$cbr0 set interval_ 0.005
$cbr0 attach-agent $udp0

# for node 1
set udp1 [new Agent/UDP]
$udp1 set class_ 2
$ns attach-agent $n1 $udp1
set cbr1 [new Application/Traffic/CBR]
$cbr1 set packetSize_ 500
$cbr1 set interval_ 0.005
$cbr1 attach-agent $udp1

# for node 3
set null0 [new Agent/Null] 
$ns attach-agent $n3 $null0

# connect two cbr agents to null agent
$ns connect $udp0 $null0 
$ns connect $udp1 $null0

# cbr timers
$ns at 0.5 "$cbr0 start" 
$ns at 1.0 "$cbr1 start"
$ns at 3.5 "$cbr1 stop"
$ns at 4.5 "$cbr0 stop"


#Call the finish procedure after 5 seconds simulation time
$ns at 5.0 "finish"

#Run the simulation
$ns run
