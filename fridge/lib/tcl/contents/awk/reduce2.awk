{
if ($1=="drop-rate:") {
  rate = $2;
}
if ($1=="rounds:") {
  print rate, $2;
}
}
