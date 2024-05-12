BEGIN {
seqno = 0; 
droppedPackets = 0;
receivedPackets = 0;
count = 0;
}
{
# Trace line format: normal
	if ($2 != "-t") {
		event = $1
		time = $2
		if (event == "+" || event == "-") node_id = $3
		if (event == "r" || event == "d") node_id = $4
		flow_id = $8
		pkt_id = $12
		pkt_size = $6
		flow_t = $5
		level = "AGT"
	}
	# Trace line format: new
	if ($2 == "-t") {
		event = $1
		time = $3
		node_id = $5
		flow_id = $39
		pkt_id = $41
		pkt_size = $37
		flow_t = $45
		level = $19
	}
#packet delivery ratio
if(level == "AGT" && event == "s" && node_id==2) {
seqno++;
}
else if((level == "AGT") && (event == "r")&& node_id==4) {
 receivedPackets++;
}
}
  
END{ 
 print "GeneratedPackets = " seqno;
 print "ReceivedPackets = " receivedPackets;
print "Packet Delivery Ratio = " receivedPackets/(seqno)*100
 "%";
print "Total Dropped Packets = " seqno-receivedPackets;
 }
