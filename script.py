traceLines = open("smalipat_pa3.tr", "r").readlines();
traces = []
count = 0
for line in traceLines:
	fields = line.split(' ')
	if fields[0] in ['s', 'r', 'D'] and fields[3] == 'MAC' and fields[7] == 'cbr':
    		traces.append({'event': fields[0], 'nid': fields[2], 'pktid': int(fields[6])})

copies = len(set(t['pktid'] for t in traces))
recv = len(set(t['pktid'] for t in traces if t['nid'] == '_0_' and t['event'] == 'r'))

print("copies: %d, recv: %d, P: %.2f%%" % (copies, recv, float(recv)/copies*100))
