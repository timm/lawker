	{
		sum += $2;
		num ++;
		if (num >= total) {
			print sum;
			sum = 0;
			num = 0;
		}
	}
