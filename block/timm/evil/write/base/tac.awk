    { Line[++N]=$0 }
END { for(I=N;I>=1;I--) 
            print Line[I] }
