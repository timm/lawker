{
if ($1=="time:" && $3=="packetrate:") print $2, $4;
}
