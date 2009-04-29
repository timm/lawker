{
if ($1=="interval:") printf "drop-rate: %5.3f\n", 1/$2;
if ($1=="time:" && $3=="rate:" && $2<10.08) {
  max = $4;
  half = max/2.0;
  time = $2;
  first = 1;
  rounds = 0;
}
if ($1=="time:" && $3=="rate:" && $2>10.08 && $4>max/2 && first==1) {
  if ($4 < max) {
    rounds = rounds + 1;
  }
}
if ($1=="time:" && $3=="rate:" && $2>10.08 && $4<max/2 && first==1) {
  rounds = rounds + 1;
  first = 0;
  printf "rounds: %d\n", rounds;
}
}
