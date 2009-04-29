	{
		if (oldtime == 0) oldtime = $1;
		time = $1;
		count += $2;
		if (int(time) > int(oldtime) ) {
		    print time, count;
		    count = 0;
		    oldtime = time;
		}
	}
