# Reference: http://www.isi.edu/nsnam/ns/tutorial/nsscript5.html
#  Project Specifications
set val(node_count)  	101		
set val(sim_time)	100
#128 bits
set val(packet_size)	16		
set val(repeatTx)	10
set val(interval)	.02
set val(X)		50
set val(Y)		50
set val(file_nam)       "smalipat_pa3.nam"
set val(file_trace)     "smalipat_pa3.tr"
set val(file_stats)     "smalipat_pa3.stats"

# Node Properties
set val(channel)           Channel/WirelessChannel
set val(prop)          	Propagation/TwoRayGround 
set val(ant)            Antenna/OmniAntenna
set val(ll)             LL
set val(ifq)            Queue/DropTail/PriQueue
set val(ifqlen)         50
set val(netif)          Phy/WirelessPhy
set val(mac)            Mac/randomMac
#set val(mac)            Mac/802_11
set val(rp)             DSDV
set val(nn)             $val(node_count)

$val(mac) set repeatTx $val(repeatTx)
$val(mac) set interval $val(interval)


# Simulator initalization
set ns 		[new Simulator]
set trace_fd 	[open $val(file_trace) w]
set nam_fd 	[open $val(file_nam) w]
set stats_fd 	[open $val(file_stats) w]
$ns namtrace-all-wireless $nam_fd $val(X) $val(Y)
$ns trace-all $trace_fd
set topology 	[new Topography]
$topology load_flatgrid $val(X) $val(Y)

# create a god, which maintains the position of all the nodes in the grid and also has routes to each node
create-god $val(nn)

# Since all the nodes in the system are equivalent with same properties except the sink, define node-config for all nodes with same base class 
$ns node-config -adhocRouting $val(rp) -llType $val(ll) -macType $val(mac) -ifqType $val(ifq) -ifqLen $val(ifqlen) -antType $val(ant) -propType $val(prop) -phyType $val(netif) -channelType $val(channel) -topoInstance $topology -agentTrace ON -routerTrace ON -macTrace ON -movementTrace OFF

# We need to place all the nodes randomly on the grid. For this we define a random variable using random number generator class
set rand [new RNG]
$rand seed 1 
set randV [new RandomVariable/Uniform]
$randV use-rng $rand
$randV set min_ -25
$randV set max_ 25

# create sink
set nodeList(0) [$ns node]
# disable motion
$nodeList(0) random-motion 0
$nodeList(0) set X_ 25
$nodeList(0) set Y_ 25
$ns initial_node_pos $nodeList(0) 10
set sink [new Agent/LossMonitor]
$ns attach-agent $nodeList(0) $sink
# attach loss monitor so that we can get statistics

# Now we create nodes, assign them positions based on random variable, an UDP agent and a data generating source CBR for each node
for {set i 1} {$i < $val(node_count)} {incr i} {
	# create node
	set nodeList($i) [$ns node] 
	# disable motion
	$nodeList($i) random-motion 0
	set posX [expr 25 + [$randV value]]
	set posY [expr 25 + [$randV value]]
	$nodeList($i) set X_ $posX
	$nodeList($i) set Y_ $posY
	puts $posX 
	puts $posY
	$ns initial_node_pos $nodeList($i) 2

	puts "create node $i" 
	# set position using random variable
	
	
	# set node size in nam

	# add agent for this node
	set agentList($i) [new Agent/UDP]
	# add color for differentiating packets generated from a source
	$ns attach-agent $nodeList($i) $agentList($i)
	# connect the agent and sink
	$ns connect $agentList($i) $sink

	# add constant bit rate traffic generator
	set cbrList($i) [new Application/Traffic/CBR]
	# set packet generation interval and packet size
	$cbrList($i) set interval_ $val(interval)
	$cbrList($i) set packet_size_ $val(packet_size)
	# attach an agent to this traffic generator
	$cbrList($i) attach-agent $agentList($i)
	# start this at 1 second
	$ns at 1 "$cbrList($i) start"
	#$ns at $val(sim_time) "$cbrList($i) stop"
}

proc finish {} {
	global ns
	global sink
	global trace_fd
	global nam_fd
	global stats_fd

	puts "simulation completed"

	set bytes [$sink set bytes_]
	set lostCount [$sink set nlost_]
	set pktCount [$sink set npkts_]
	set curTime [$ns now]
	
	puts $stats_fd "Time bytes pktCount lostCount"
	puts $stats_fd "$curTime $bytes $pktCount $lostCount"

	$ns flush-trace
	close $stats_fd
	close $nam_fd
	close $trace_fd

#	exec nam smalipat_pa3.nam &
        exit 0
}

$ns at $val(sim_time) "finish"

puts "Starting Simulation"
$ns run

