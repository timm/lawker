	{
		sub(/:/, " ");
		if ($1~"flows") { flows = $2;}
		if ($3~"total_drops") {drops = $4;}
		if ($3~"total_packets") {
			packets = $4;
			print flows, 100*drops/packets;
		}
	}
