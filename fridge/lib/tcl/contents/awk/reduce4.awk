{
if ($1=="interval:") {
  printf "drop-rate: %5.3f\n", 1/$2;
  first = 0;
}
if ($1=="time:" && $3=="packetrate:" && $2>10.08 && $4>1 && first==1) {
  if ($4 < maxrate) {
    rounds = rounds + 1;
  }
}
if ($1=="time:" && $3=="packetrate:" && $2>10.08 && $4<1 && first==1) {
  rounds = rounds + 1;
  first = 2;
  printf "rounds: %d\n", rounds;
}
if ($1=="time:" && $3=="packetrate:") {
  newtime = $2;
  newrate = $4;
  if (newtime > 10 && first == 0) {
    maxrate = packetrate; 
    printf "time: %5.3f packetrate: %5.3f\n", time, packetrate;
    rounds = 0;
    first = 1;
    if (newrate < 1) {
      printf "rounds: %d\n", 0;
      first = 2;
    }
  } 
  time = newtime;
  packetrate = $4;
}
}
