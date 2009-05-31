BEGIN {FS=":"}
	  {for(I=1;I<=NF;I++) 
			if (++Seen[$I]  == 1) {
				Out = Out Sep  $I	
				Sep = ":"}}
END   {print Out}
