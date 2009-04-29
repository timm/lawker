{
if ($3=="packetrate:") {
  rate = $4;
}
if ($1=="rounds:") {
  print rate, $2;
}
}
