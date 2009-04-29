{
if ($3=="loss_rate:") {
  if ($4 != 0)
    print $2, 1/$4
}
}
